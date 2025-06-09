#!/usr/bin/env node

/**
 * {{PROJECT_NAME}} - Health Check Script
 * This script verifies that the development environment is properly configured
 * Generated from template for {{PRIMARY_LANGUAGE}} project
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Colors for output
const colors = {
    reset: '\x1b[0m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m'
};

// Utility functions
function log(message, color = 'reset') {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

function checkmark() {
    return `${colors.green}✓${colors.reset}`;
}

function crossmark() {
    return `${colors.red}✗${colors.reset}`;
}

function warning() {
    return `${colors.yellow}⚠${colors.reset}`;
}

async function checkEnvironment() {
    log('🏥 Running health check...\n', 'blue');
    
    let allChecksPass = true;
    
    // Check runtime version
    {{#if_language_nodejs}}
    const nodeVersion = process.version;
    log(`${checkmark()} Node.js ${nodeVersion}`);
    
    const majorVersion = parseInt(nodeVersion.split('.')[0].substring(1));
    if (majorVersion < {{NODE_MAJOR_VERSION}}) {
        log(`${warning()} Node.js version should be {{NODE_MIN_VERSION}} or higher`, 'yellow');
        allChecksPass = false;
    }
    {{/if_language_nodejs}}
    
    // Check environment variables
    log('\nEnvironment Variables:', 'blue');
    const requiredEnvVars = [
        {{#each REQUIRED_ENV_VARS}}
        '{{this}}',
        {{/each}}
    ];
    
    for (const envVar of requiredEnvVars) {
        if (process.env[envVar]) {
            log(`${checkmark()} ${envVar} is set`);
        } else {
            log(`${crossmark()} ${envVar} is not set`);
            allChecksPass = false;
        }
    }
    
    // Check file system
    log('\nFile System:', 'blue');
    const requiredDirs = [
        {{#each REQUIRED_DIRECTORIES}}
        '{{this}}',
        {{/each}}
    ];
    
    for (const dir of requiredDirs) {
        if (fs.existsSync(dir)) {
            log(`${checkmark()} Directory ${dir} exists`);
        } else {
            log(`${crossmark()} Directory ${dir} missing`);
            allChecksPass = false;
        }
    }
    
    const requiredFiles = [
        {{#each REQUIRED_FILES}}
        '{{this}}',
        {{/each}}
    ];
    
    for (const file of requiredFiles) {
        if (fs.existsSync(file)) {
            log(`${checkmark()} File ${file} exists`);
        } else {
            log(`${crossmark()} File ${file} missing`);
            allChecksPass = false;
        }
    }
    
    {{#if_database_mongodb}}
    // Check MongoDB connection
    log('\nDatabase Connection:', 'blue');
    if (process.env.MONGODB_URI) {
        try {
            const { MongoClient } = require('mongodb');
            const client = new MongoClient(process.env.MONGODB_URI);
            await client.connect();
            await client.db().admin().ping();
            log(`${checkmark()} MongoDB connection successful`);
            await client.close();
        } catch (error) {
            log(`${crossmark()} MongoDB connection failed: ${error.message}`);
            allChecksPass = false;
        }
    } else {
        log(`${crossmark()} MONGODB_URI not configured`);
        allChecksPass = false;
    }
    {{/if_database_mongodb}}
    
    {{#if_database_postgresql}}
    // Check PostgreSQL connection
    log('\nDatabase Connection:', 'blue');
    if (process.env.DATABASE_URL) {
        try {
            const { Client } = require('pg');
            const client = new Client({
                connectionString: process.env.DATABASE_URL
            });
            await client.connect();
            await client.query('SELECT 1');
            log(`${checkmark()} PostgreSQL connection successful`);
            await client.end();
        } catch (error) {
            log(`${crossmark()} PostgreSQL connection failed: ${error.message}`);
            allChecksPass = false;
        }
    } else {
        log(`${crossmark()} DATABASE_URL not configured`);
        allChecksPass = false;
    }
    {{/if_database_postgresql}}
    
    {{#if_database_mysql}}
    // Check MySQL connection
    log('\nDatabase Connection:', 'blue');
    if (process.env.MYSQL_HOST && process.env.MYSQL_USER) {
        try {
            const mysql = require('mysql2/promise');
            const connection = await mysql.createConnection({
                host: process.env.MYSQL_HOST,
                user: process.env.MYSQL_USER,
                password: process.env.MYSQL_PASSWORD,
                database: process.env.MYSQL_DATABASE
            });
            await connection.ping();
            log(`${checkmark()} MySQL connection successful`);
            await connection.end();
        } catch (error) {
            log(`${crossmark()} MySQL connection failed: ${error.message}`);
            allChecksPass = false;
        }
    } else {
        log(`${crossmark()} MySQL connection not configured`);
        allChecksPass = false;
    }
    {{/if_database_mysql}}
    
    {{#if_docker_required}}
    // Check Docker services
    log('\nDocker Services:', 'blue');
    try {
        const dockerPs = execSync('docker ps --format "table {{.Names}}\t{{.Status}}"', { encoding: 'utf-8' });
        const runningContainers = dockerPs.split('\n').slice(1).filter(line => line.trim());
        
        const expectedContainers = [
            {{#each DOCKER_SERVICES}}
            '{{container_name}}',
            {{/each}}
        ];
        
        for (const container of expectedContainers) {
            const isRunning = runningContainers.some(line => line.includes(container));
            if (isRunning) {
                log(`${checkmark()} ${container} is running`);
            } else {
                log(`${crossmark()} ${container} is not running`);
                allChecksPass = false;
            }
        }
    } catch (error) {
        log(`${warning()} Could not check Docker services: ${error.message}`, 'yellow');
    }
    {{/if_docker_required}}
    
    // Check dependencies
    log('\nDependencies:', 'blue');
    {{#if_language_nodejs}}
    if (fs.existsSync('node_modules')) {
        const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf-8'));
        const installedCount = fs.readdirSync('node_modules').filter(d => !d.startsWith('.')).length;
        const expectedCount = Object.keys(packageJson.dependencies || {}).length + 
                            Object.keys(packageJson.devDependencies || {}).length;
        
        if (installedCount > 0) {
            log(`${checkmark()} Dependencies installed (${installedCount} packages)`);
        } else {
            log(`${crossmark()} No dependencies installed`);
            allChecksPass = false;
        }
    } else {
        log(`${crossmark()} node_modules directory not found`);
        allChecksPass = false;
    }
    {{/if_language_nodejs}}
    
    // Custom health checks
    {{#each CUSTOM_HEALTH_CHECKS}}
    try {
        {{check_code}}
        log(`${checkmark()} {{success_message}}`);
    } catch (error) {
        log(`${crossmark()} {{failure_message}}: ${error.message}`);
        allChecksPass = false;
    }
    {{/each}}
    
    // Summary
    log('\n' + '='.repeat(50), 'blue');
    if (allChecksPass) {
        log('🎉 All health checks passed!', 'green');
        log('\nYour development environment is ready.', 'green');
    } else {
        log('❌ Some health checks failed', 'red');
        log('\nPlease fix the issues above before proceeding.', 'yellow');
        process.exit(1);
    }
}

// Load environment variables if .env exists
if (fs.existsSync('.env')) {
    require('dotenv').config();
}

// Run health check
checkEnvironment().catch(error => {
    log(`\n${crossmark()} Health check failed with error:`, 'red');
    console.error(error);
    process.exit(1);
});