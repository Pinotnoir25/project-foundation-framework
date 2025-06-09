# Security Operations

## Overview

This document outlines security operations procedures for the Nexus MCP MongoDB server, including CI/CD security integration, vulnerability management, incident response, and ongoing security assessments.

## Security Scanning in CI/CD

### Pipeline Security Integration

**GitLab CI Security Pipeline:**
```yaml
stages:
  - build
  - test
  - security
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  SECURE_LOG_LEVEL: "debug"

# Static Application Security Testing (SAST)
sast:
  stage: security
  image: nexus/security-scanner:latest
  script:
    - semgrep --config=auto --json --output=sast-report.json .
    - sonarqube-scanner
      -Dsonar.projectKey=$CI_PROJECT_NAME
      -Dsonar.sources=.
      -Dsonar.host.url=$SONAR_HOST_URL
      -Dsonar.login=$SONAR_TOKEN
    - npm audit --json > npm-audit-report.json
  artifacts:
    reports:
      sast: 
        - sast-report.json
        - npm-audit-report.json
    paths:
      - sast-report.json
      - sonar-report.json
    expire_in: 1 week
  only:
    - merge_requests
    - main
    - develop

# Dependency Scanning
dependency_scanning:
  stage: security
  image: nexus/dependency-scanner:latest
  script:
    - snyk test --json > snyk-report.json
    - safety check --json > safety-report.json
    - npm audit fix --dry-run --json > npm-fix-report.json
    - retire --js --outputformat json --outputpath retire-report.json
  artifacts:
    reports:
      dependency_scanning: 
        - snyk-report.json
        - safety-report.json
    paths:
      - "*-report.json"
    expire_in: 1 week
  allow_failure: false

# Container Scanning
container_scanning:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --exit-code 1 --severity HIGH,CRITICAL 
      --format json --output trivy-report.json 
      $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - grype $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA 
      --output json > grype-report.json
  artifacts:
    reports:
      container_scanning: 
        - trivy-report.json
        - grype-report.json
    expire_in: 1 week
  only:
    - main
    - develop

# Secret Scanning
secret_detection:
  stage: security
  image: nexus/secret-scanner:latest
  script:
    - gitleaks detect --source . --report-format json --report-path gitleaks-report.json
    - trufflehog filesystem . --json > trufflehog-report.json
    - detect-secrets scan --all-files --output secrets-baseline.json
  artifacts:
    reports:
      secret_detection: 
        - gitleaks-report.json
        - trufflehog-report.json
    expire_in: 1 week
  only:
    - merge_requests
```

### Security Gates

**Automated Security Gates:**
```javascript
// security-gates.js
class SecurityGates {
  constructor() {
    this.thresholds = {
      sast: {
        critical: 0,
        high: 3,
        medium: 10
      },
      dependencies: {
        critical: 0,
        high: 0,
        medium: 5
      },
      container: {
        critical: 0,
        high: 0
      },
      secrets: {
        any: 0
      }
    };
  }
  
  async evaluateSecurityReports(reports) {
    const results = {
      passed: true,
      failures: [],
      warnings: []
    };
    
    // SAST evaluation
    const sastViolations = this.evaluateSAST(reports.sast);
    if (sastViolations.failed) {
      results.passed = false;
      results.failures.push(...sastViolations.failures);
    }
    
    // Dependency evaluation
    const depViolations = this.evaluateDependencies(reports.dependencies);
    if (depViolations.failed) {
      results.passed = false;
      results.failures.push(...depViolations.failures);
    }
    
    // Container evaluation
    const containerViolations = this.evaluateContainer(reports.container);
    if (containerViolations.failed) {
      results.passed = false;
      results.failures.push(...containerViolations.failures);
    }
    
    // Secret detection
    if (reports.secrets && reports.secrets.length > 0) {
      results.passed = false;
      results.failures.push({
        type: 'secrets',
        message: `Found ${reports.secrets.length} exposed secrets`,
        severity: 'critical'
      });
    }
    
    return results;
  }
  
  async blockDeployment(results) {
    if (!results.passed) {
      const notification = {
        status: 'BLOCKED',
        reason: 'Security gate failures',
        failures: results.failures,
        timestamp: new Date(),
        buildId: process.env.CI_BUILD_ID
      };
      
      await this.notifySecurityTeam(notification);
      throw new Error('Deployment blocked due to security violations');
    }
  }
}
```

### Pre-commit Security Hooks

**Git Pre-commit Configuration:**
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
        args: ['--maxkb=1000']
      - id: check-case-conflict
      - id: check-merge-conflict

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
        exclude: package-lock\.json

  - repo: https://github.com/zricethezav/gitleaks
    rev: v8.16.1
    hooks:
      - id: gitleaks

  - repo: https://github.com/returntocorp/semgrep
    rev: v1.45.0
    hooks:
      - id: semgrep
        args: ['--config=auto', '--error']

  - repo: local
    hooks:
      - id: npm-audit
        name: npm audit
        entry: npm audit --audit-level=high
        language: system
        pass_filenames: false
        files: package\.json$

      - id: eslint-security
        name: ESLint Security
        entry: npx eslint --plugin security
        language: system
        files: \.(js|jsx|ts|tsx)$
```

## Dependency Vulnerability Management

### Automated Dependency Updates

**Dependabot Configuration:**
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
      time: "05:00"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"
    commit-message:
      prefix: "chore"
      prefix-development: "chore"
      include: "scope"
    ignore:
      - dependency-name: "aws-sdk"
        versions: ["2.x"]
    groups:
      production-dependencies:
        dependency-type: "production"
      development-dependencies:
        dependency-type: "development"

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    reviewers:
      - "devops-team"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Vulnerability Response Process

**Automated Vulnerability Management:**
```javascript
class VulnerabilityManager {
  constructor() {
    this.scanners = {
      npm: new NPMAudit(),
      snyk: new SnykScanner(),
      owasp: new OWASPDependencyCheck()
    };
    
    this.severityThresholds = {
      critical: { sla: '24h', autoFix: true },
      high: { sla: '72h', autoFix: true },
      medium: { sla: '7d', autoFix: false },
      low: { sla: '30d', autoFix: false }
    };
  }
  
  async scanDependencies() {
    const results = await Promise.all([
      this.scanners.npm.scan(),
      this.scanners.snyk.scan(),
      this.scanners.owasp.scan()
    ]);
    
    const vulnerabilities = this.consolidateResults(results);
    const prioritized = this.prioritizeVulnerabilities(vulnerabilities);
    
    for (const vuln of prioritized) {
      await this.handleVulnerability(vuln);
    }
    
    return this.generateReport(vulnerabilities);
  }
  
  async handleVulnerability(vuln) {
    const threshold = this.severityThresholds[vuln.severity];
    
    // Attempt automatic fix
    if (threshold.autoFix) {
      const fixed = await this.attemptAutoFix(vuln);
      if (fixed) {
        await this.createAutomatedPR(vuln, fixed);
        return;
      }
    }
    
    // Create issue for manual intervention
    await this.createSecurityIssue(vuln, threshold.sla);
    
    // Alert if critical
    if (vuln.severity === 'critical') {
      await this.alertSecurityTeam(vuln);
    }
  }
  
  async attemptAutoFix(vuln) {
    if (vuln.fixAvailable) {
      const testResult = await this.testFix(vuln);
      if (testResult.compatible && testResult.testsPass) {
        return {
          package: vuln.package,
          currentVersion: vuln.version,
          fixedVersion: vuln.fixedIn,
          breaking: testResult.breaking
        };
      }
    }
    return null;
  }
}
```

### Supply Chain Security

**Package Verification:**
```javascript
class SupplyChainSecurity {
  async verifyPackage(packageName, version) {
    const checks = await Promise.all([
      this.checkPackageSignature(packageName, version),
      this.checkPackageProvenance(packageName, version),
      this.checkMaintainerReputation(packageName),
      this.checkDependencyTree(packageName, version),
      this.checkForTyposquatting(packageName)
    ]);
    
    const score = this.calculateTrustScore(checks);
    
    if (score < 0.7) {
      throw new Error(`Package ${packageName}@${version} failed security verification`);
    }
    
    return {
      package: packageName,
      version,
      trustScore: score,
      checks
    };
  }
  
  async enforcePolicy(package) {
    const policy = {
      allowedRegistries: ['https://registry.npmjs.org'],
      requireSignatures: true,
      minMaintainers: 2,
      minAge: 90, // days
      maxDependencyDepth: 5,
      bannedLicenses: ['AGPL-3.0', 'GPL-3.0'],
      requiredVulnScans: ['npm', 'snyk']
    };
    
    const violations = await this.checkPolicy(package, policy);
    
    if (violations.length > 0) {
      throw new PolicyViolationError(violations);
    }
  }
}
```

## Container Security Scanning

### Container Build Security

**Secure Dockerfile:**
```dockerfile
# Use specific version tags, not latest
FROM node:18.19.0-alpine3.18 AS builder

# Add security labels
LABEL security.scan="required" \
      security.scan-tool="trivy" \
      maintainer="security@nexus-clinical.com"

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Install security updates
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        dumb-init \
        libcap && \
    rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with security audit
RUN npm ci --only=production && \
    npm audit fix && \
    npm cache clean --force

# Copy application code
COPY --chown=nodejs:nodejs . .

# Remove unnecessary files
RUN rm -rf .git .env* *.md

# Security hardening
RUN chmod -R 550 /app && \
    find /app -type f -name "*.sh" -exec chmod 550 {} \;

# Final stage
FROM node:18.19.0-alpine3.18

# Install security updates
RUN apk update && \
    apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy from builder
COPY --from=builder --chown=nodejs:nodejs /app /app

# Use non-root user
USER nodejs

# Security headers
ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=2048 --enable-source-maps"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD node healthcheck.js

# Use dumb-init to handle signals
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "src/index.js"]
```

### Container Runtime Security

**Runtime Security Policy:**
```yaml
# pod-security-policy.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: nexus-mcp-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: true
```

### Container Scanning Automation

**Continuous Container Scanning:**
```javascript
class ContainerSecurityScanner {
  constructor() {
    this.scanners = {
      trivy: new TrivyScanner(),
      clair: new ClairScanner(),
      anchore: new AnchoreScanner()
    };
    
    this.policies = {
      production: {
        allowedBaseImages: [
          'node:18-alpine',
          'nginx:1.24-alpine'
        ],
        maxCriticalVulns: 0,
        maxHighVulns: 0,
        requireDistroless: false,
        requireSignature: true
      }
    };
  }
  
  async scanImage(imageRef, environment = 'production') {
    const policy = this.policies[environment];
    const results = await Promise.all([
      this.scanners.trivy.scan(imageRef),
      this.scanners.clair.scan(imageRef),
      this.scanners.anchore.scan(imageRef)
    ]);
    
    const consolidated = this.consolidateResults(results);
    const violations = this.checkPolicy(consolidated, policy);
    
    if (violations.length > 0) {
      await this.blockDeployment(imageRef, violations);
    }
    
    return {
      image: imageRef,
      scanDate: new Date(),
      results: consolidated,
      policy: policy,
      violations: violations,
      approved: violations.length === 0
    };
  }
  
  async continuousScan() {
    const images = await this.getRunningImages();
    
    for (const image of images) {
      const result = await this.scanImage(image.ref);
      
      if (result.violations.length > 0) {
        await this.handleRuntimeViolation(image, result);
      }
    }
  }
}
```

## Secret Scanning in Code

### Secret Detection Configuration

**Detect-Secrets Setup:**
```json
{
  "version": "1.4.0",
  "plugins_used": [
    {
      "name": "ArtifactoryDetector"
    },
    {
      "name": "AWSKeyDetector"
    },
    {
      "name": "AzureStorageKeyDetector"
    },
    {
      "name": "Base64HighEntropyString",
      "limit": 4.5
    },
    {
      "name": "BasicAuthDetector"
    },
    {
      "name": "CloudantDetector"
    },
    {
      "name": "GitHubTokenDetector"
    },
    {
      "name": "HexHighEntropyString",
      "limit": 3.0
    },
    {
      "name": "IbmCloudIamDetector"
    },
    {
      "name": "IbmCosHmacDetector"
    },
    {
      "name": "JwtTokenDetector"
    },
    {
      "name": "KeywordDetector",
      "keyword_exclude": ""
    },
    {
      "name": "MailchimpDetector"
    },
    {
      "name": "NpmDetector"
    },
    {
      "name": "PrivateKeyDetector"
    },
    {
      "name": "SendGridDetector"
    },
    {
      "name": "SlackDetector"
    },
    {
      "name": "SoftlayerDetector"
    },
    {
      "name": "SquareOAuthDetector"
    },
    {
      "name": "StripeDetector"
    },
    {
      "name": "TwilioKeyDetector"
    }
  ],
  "filters_used": [
    {
      "path": "node_modules"
    },
    {
      "path": "\\.secrets\\.baseline$"
    },
    {
      "path": "\\.git"
    }
  ],
  "results": {},
  "generated_at": "2024-01-15T10:00:00Z",
  "exclude": {
    "files": "^(package-lock\\.json|yarn\\.lock)$",
    "lines": null
  }
}
```

### Secret Remediation

**Automated Secret Response:**
```javascript
class SecretRemediator {
  async handleExposedSecret(detection) {
    // Immediate actions
    const immediate = await Promise.all([
      this.revokeSecret(detection),
      this.notifySecurityTeam(detection),
      this.blockCommit(detection)
    ]);
    
    // Remediation
    const remediation = await this.remediateSecret(detection);
    
    // Audit
    await this.auditSecretExposure(detection, remediation);
    
    return remediation;
  }
  
  async revokeSecret(detection) {
    const revocationHandlers = {
      'AWS': () => this.revokeAWSKey(detection),
      'GitHub': () => this.revokeGitHubToken(detection),
      'MongoDB': () => this.rotateMongoCredentials(detection),
      'JWT': () => this.invalidateJWTSecret(detection),
      'API_KEY': () => this.revokeAPIKey(detection)
    };
    
    const handler = revocationHandlers[detection.type];
    if (handler) {
      await handler();
    }
    
    return {
      type: detection.type,
      revoked: true,
      timestamp: new Date()
    };
  }
  
  async preventFutureExposure(detection) {
    // Add to .gitignore
    await this.updateGitignore(detection.file);
    
    // Create environment variable
    const envVar = await this.createEnvVariable(detection);
    
    // Update code to use env var
    await this.updateCodeReference(detection, envVar);
    
    // Add to secret manager
    await this.addToSecretManager(envVar, detection.value);
  }
}
```

## Security Incident Response Plan

### Incident Response Framework

**Incident Classification:**
```javascript
class IncidentClassifier {
  classify(incident) {
    const severityMatrix = {
      dataBreech: {
        pii: 'critical',
        credentials: 'critical',
        metadata: 'high'
      },
      unauthorized: {
        adminAccess: 'critical',
        dataAccess: 'high',
        readAccess: 'medium'
      },
      availability: {
        completeOutage: 'critical',
        partialOutage: 'high',
        degradedPerformance: 'medium'
      },
      malware: {
        ransomware: 'critical',
        trojan: 'critical',
        adware: 'low'
      }
    };
    
    return {
      severity: this.calculateSeverity(incident, severityMatrix),
      category: incident.type,
      impact: this.assessImpact(incident),
      urgency: this.determineUrgency(incident)
    };
  }
}
```

### Incident Response Procedures

**Response Workflow:**
```javascript
class IncidentResponse {
  async handleIncident(incident) {
    const classification = this.classifier.classify(incident);
    
    // Phase 1: Initial Response (0-15 minutes)
    const initialResponse = await this.initialResponse(incident, classification);
    
    // Phase 2: Investigation (15-60 minutes)
    const investigation = await this.investigate(incident, initialResponse);
    
    // Phase 3: Containment (1-4 hours)
    const containment = await this.contain(incident, investigation);
    
    // Phase 4: Eradication (4-24 hours)
    const eradication = await this.eradicate(incident, containment);
    
    // Phase 5: Recovery (1-7 days)
    const recovery = await this.recover(incident, eradication);
    
    // Phase 6: Lessons Learned (7-14 days)
    const postmortem = await this.postmortem(incident, recovery);
    
    return {
      incident,
      classification,
      response: {
        initial: initialResponse,
        investigation,
        containment,
        eradication,
        recovery,
        postmortem
      }
    };
  }
  
  async initialResponse(incident, classification) {
    const actions = [];
    
    // Alert incident response team
    actions.push(await this.alertTeam(classification.severity));
    
    // Create incident ticket
    actions.push(await this.createIncidentTicket(incident));
    
    // Start incident log
    actions.push(await this.startIncidentLog(incident));
    
    // Preserve evidence
    if (classification.severity >= 'high') {
      actions.push(await this.preserveEvidence(incident));
    }
    
    // Initial containment
    if (classification.severity === 'critical') {
      actions.push(await this.emergencyContainment(incident));
    }
    
    return {
      timestamp: new Date(),
      actions,
      responders: await this.getResponders(classification.severity)
    };
  }
}
```

### Incident Communication Plan

**Communication Templates:**
```javascript
class IncidentCommunication {
  getStakeholderMatrix(severity) {
    return {
      critical: {
        internal: ['ciso', 'cto', 'ceo', 'legal', 'pr'],
        external: ['customers', 'partners', 'regulators'],
        timeline: 'immediate'
      },
      high: {
        internal: ['security-team', 'engineering-lead', 'cto'],
        external: ['affected-customers'],
        timeline: '1-hour'
      },
      medium: {
        internal: ['security-team', 'engineering'],
        external: [],
        timeline: '4-hours'
      }
    };
  }
  
  async notifyStakeholders(incident, severity) {
    const matrix = this.getStakeholderMatrix(severity);
    const stakeholders = matrix[severity];
    
    for (const group of ['internal', 'external']) {
      for (const stakeholder of stakeholders[group]) {
        await this.sendNotification(
          stakeholder,
          this.getTemplate(incident, stakeholder)
        );
      }
    }
  }
}
```

## Penetration Testing Schedule

### Annual Security Assessment Plan

**Testing Schedule:**
```yaml
penetration_testing_schedule:
  q1:
    - type: external_network
      scope: [public_apis, web_applications]
      duration: 2_weeks
      vendor: approved_vendor_1
      
    - type: social_engineering
      scope: [phishing, vishing]
      duration: 1_week
      vendor: internal_red_team
      
  q2:
    - type: internal_network
      scope: [infrastructure, databases]
      duration: 2_weeks
      vendor: approved_vendor_2
      
    - type: application_security
      scope: [web_app, mobile_app, apis]
      duration: 3_weeks
      vendor: approved_vendor_1
      
  q3:
    - type: cloud_security
      scope: [aws, mongodb_atlas]
      duration: 2_weeks
      vendor: cloud_specialist
      
    - type: physical_security
      scope: [data_centers, offices]
      duration: 1_week
      vendor: physical_security_firm
      
  q4:
    - type: red_team_exercise
      scope: [full_scope]
      duration: 4_weeks
      vendor: elite_red_team
      
    - type: purple_team_exercise
      scope: [detection_improvement]
      duration: 2_weeks
      vendor: internal_teams
```

### Penetration Testing Procedures

**Testing Framework:**
```javascript
class PenetrationTestManager {
  async preparePentest(test) {
    // Pre-engagement
    const preparation = {
      scope: await this.defineScope(test),
      rules: await this.setRulesOfEngagement(test),
      authorization: await this.getAuthorization(test),
      contacts: await this.establishContacts(test),
      outOfScope: await this.defineOutOfScope(test)
    };
    
    // Environment setup
    await this.prepareEnvironment(test);
    
    // Baseline
    await this.captureBaseline(test);
    
    return preparation;
  }
  
  async monitorPentest(test) {
    const monitoring = {
      realTime: await this.setupRealTimeMonitoring(test),
      alerts: await this.configureAlerts(test),
      communication: await this.setupCommunication(test),
      escalation: await this.defineEscalation(test)
    };
    
    // Monitor for critical findings
    monitoring.criticalHandler = async (finding) => {
      if (finding.severity === 'critical' && finding.exploitable) {
        await this.handleCriticalFinding(finding);
      }
    };
    
    return monitoring;
  }
  
  async processResults(test, results) {
    // Validate findings
    const validated = await this.validateFindings(results.findings);
    
    // Risk assessment
    const risks = await this.assessRisks(validated);
    
    // Remediation plan
    const remediation = await this.createRemediationPlan(risks);
    
    // Report generation
    const report = await this.generateReport({
      test,
      findings: validated,
      risks,
      remediation
    });
    
    // Track remediation
    await this.trackRemediation(remediation);
    
    return report;
  }
}
```

## Security Training Requirements

### Security Awareness Program

**Training Curriculum:**
```yaml
security_training_program:
  onboarding:
    - course: security_fundamentals
      duration: 2_hours
      mandatory: true
      
    - course: data_protection_basics
      duration: 1_hour
      mandatory: true
      
    - course: phishing_awareness
      duration: 30_minutes
      mandatory: true
      
  role_specific:
    developers:
      - secure_coding_practices
      - owasp_top_10
      - dependency_management
      - secret_management
      
    operations:
      - infrastructure_security
      - incident_response
      - security_monitoring
      - access_management
      
    management:
      - security_governance
      - risk_management
      - compliance_overview
      - incident_communication
      
  annual_refresh:
    - security_update_2024
    - emerging_threats
    - policy_changes
    - lessons_learned
```

### Training Tracking System

**Training Management:**
```javascript
class SecurityTrainingTracker {
  async assignTraining(userId, role) {
    const curriculum = this.getCurriculum(role);
    const assignments = [];
    
    for (const course of curriculum) {
      assignments.push({
        userId,
        courseId: course.id,
        assignedDate: new Date(),
        dueDate: this.calculateDueDate(course.priority),
        status: 'assigned',
        mandatory: course.mandatory
      });
    }
    
    await this.saveAssignments(assignments);
    await this.notifyUser(userId, assignments);
    
    return assignments;
  }
  
  async trackCompletion(userId, courseId, assessment) {
    const completion = {
      userId,
      courseId,
      completedDate: new Date(),
      score: assessment.score,
      passed: assessment.score >= 80,
      certificate: await this.generateCertificate(userId, courseId),
      expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
    };
    
    await this.recordCompletion(completion);
    
    if (!completion.passed) {
      await this.scheduleRetake(userId, courseId);
    }
    
    return completion;
  }
  
  async generateComplianceReport() {
    const report = {
      date: new Date(),
      totalUsers: await this.getTotalUsers(),
      compliance: {
        onboarding: await this.getOnboardingCompliance(),
        annual: await this.getAnnualCompliance(),
        roleSpecific: await this.getRoleSpecificCompliance()
      },
      overdue: await this.getOverdueTraining(),
      upcoming: await this.getUpcomingExpiry()
    };
    
    return report;
  }
}
```

## Third-Party Security Assessments

### Vendor Security Requirements

**Vendor Assessment Framework:**
```javascript
class VendorSecurityAssessment {
  async assessVendor(vendor) {
    const assessment = {
      vendor,
      date: new Date(),
      categories: {}
    };
    
    // Security controls
    assessment.categories.security = await this.assessSecurityControls(vendor);
    
    // Compliance
    assessment.categories.compliance = await this.assessCompliance(vendor);
    
    // Data protection
    assessment.categories.dataProtection = await this.assessDataProtection(vendor);
    
    // Incident response
    assessment.categories.incidentResponse = await this.assessIncidentResponse(vendor);
    
    // Business continuity
    assessment.categories.continuity = await this.assessContinuity(vendor);
    
    // Calculate risk score
    assessment.riskScore = this.calculateRiskScore(assessment.categories);
    
    // Determine approval
    assessment.approved = assessment.riskScore >= 0.7;
    
    return assessment;
  }
  
  async continuousMonitoring(vendor) {
    const monitoring = {
      securityPosture: await this.monitorSecurityPosture(vendor),
      compliance: await this.monitorCompliance(vendor),
      incidents: await this.monitorIncidents(vendor),
      slaCompliance: await this.monitorSLA(vendor)
    };
    
    if (monitoring.incidents.length > 0 || monitoring.slaCompliance < 0.95) {
      await this.escalateVendorIssue(vendor, monitoring);
    }
    
    return monitoring;
  }
}
```

### Third-Party Integration Security

**Integration Security Checklist:**
```yaml
integration_security_checklist:
  pre_integration:
    - vendor_security_assessment
    - data_flow_mapping
    - risk_assessment
    - legal_review
    - security_requirements_definition
    
  technical_controls:
    - api_authentication: oauth2_required
    - data_encryption: tls_1.3_minimum
    - ip_whitelisting: required
    - rate_limiting: enforced
    - audit_logging: mandatory
    
  operational_controls:
    - access_reviews: quarterly
    - security_monitoring: continuous
    - incident_response: integrated
    - change_management: coordinated
    
  contractual_controls:
    - security_addendum: required
    - audit_rights: annual
    - breach_notification: 24_hours
    - liability_caps: defined
    - termination_rights: immediate_for_breach
```

## Security Metrics and Reporting

### Security KPIs

**Key Performance Indicators:**
```javascript
class SecurityMetrics {
  async calculateKPIs() {
    return {
      vulnerabilityManagement: {
        meanTimeToDetect: await this.calculateMTTD(),
        meanTimeToRemediate: await this.calculateMTTR(),
        criticalVulnsOpen: await this.getCriticalVulnsCount(),
        patchCompliance: await this.getPatchCompliance()
      },
      
      incidentResponse: {
        incidentsPerMonth: await this.getIncidentRate(),
        meanTimeToContain: await this.getMTTC(),
        falsePositiveRate: await this.getFalsePositiveRate(),
        lessonLearnedImplementation: await this.getLessonsImplemented()
      },
      
      compliance: {
        auditFindings: await this.getAuditFindings(),
        complianceScore: await this.getComplianceScore(),
        trainingCompletion: await this.getTrainingCompletion(),
        policyAdherence: await this.getPolicyAdherence()
      },
      
      accessControl: {
        orphanedAccounts: await this.getOrphanedAccounts(),
        privilegedAccountUsage: await this.getPrivilegedUsage(),
        mfaAdoption: await this.getMFAAdoption(),
        accessReviewCompletion: await this.getAccessReviews()
      }
    };
  }
  
  async generateExecutiveReport() {
    const kpis = await this.calculateKPIs();
    const trends = await this.calculateTrends(kpis);
    const risks = await this.getTopRisks();
    const initiatives = await this.getSecurityInitiatives();
    
    return {
      executive_summary: this.generateSummary(kpis, trends),
      risk_posture: this.assessRiskPosture(risks),
      compliance_status: this.getComplianceStatus(),
      security_investments: this.getROI(initiatives),
      recommendations: this.generateRecommendations(kpis, risks)
    };
  }
}
```

### Security Dashboard

**Real-time Security Monitoring:**
```yaml
security_dashboard:
  real_time_metrics:
    - active_threats: 0
    - blocked_attacks: 142
    - failed_logins: 23
    - suspicious_activities: 5
    
  vulnerability_status:
    critical: 0
    high: 2
    medium: 15
    low: 47
    
  compliance_status:
    gdpr: compliant
    hipaa: compliant
    soc2: audit_pending
    
  system_health:
    waf_status: active
    ids_status: active
    siem_status: active
    backup_status: healthy
    
  recent_incidents:
    - type: brute_force_attempt
      status: mitigated
      time: 2_hours_ago
      
    - type: suspicious_query
      status: investigating
      time: 30_minutes_ago
```

## Implementation Roadmap

### Phase 1: CI/CD Security (Week 1)
- [ ] Implement SAST in pipeline
- [ ] Configure dependency scanning
- [ ] Set up container scanning
- [ ] Deploy secret detection

### Phase 2: Vulnerability Management (Week 2)
- [ ] Deploy vulnerability scanners
- [ ] Configure automated patching
- [ ] Set up vulnerability tracking
- [ ] Implement remediation workflow

### Phase 3: Incident Response (Week 3)
- [ ] Document IR procedures
- [ ] Set up incident tracking
- [ ] Configure alerting
- [ ] Conduct tabletop exercise

### Phase 4: Continuous Improvement (Week 4)
- [ ] Deploy security metrics
- [ ] Set up dashboards
- [ ] Schedule penetration tests
- [ ] Plan security training

## References

- NIST Cybersecurity Framework
- ISO 27001:2022
- OWASP DevSecOps Guideline
- CIS Controls v8
- SANS Incident Response Guide