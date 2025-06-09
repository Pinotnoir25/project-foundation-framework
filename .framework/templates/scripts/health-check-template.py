#!/usr/bin/env python3

"""
{{PROJECT_NAME}} - Health Check Script
This script verifies that the development environment is properly configured
Generated from template for {{PRIMARY_LANGUAGE}} project
"""

import os
import sys
import subprocess
import json
from pathlib import Path

# Colors for output
class Colors:
    RESET = '\033[0m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'

def log(message, color='RESET'):
    color_code = getattr(Colors, color, Colors.RESET)
    print(f"{color_code}{message}{Colors.RESET}")

def checkmark():
    return f"{Colors.GREEN}✓{Colors.RESET}"

def crossmark():
    return f"{Colors.RED}✗{Colors.RESET}"

def warning():
    return f"{Colors.YELLOW}⚠{Colors.RESET}"

def check_environment():
    log('🏥 Running health check...\n', 'BLUE')
    
    all_checks_pass = True
    
    # Check Python version
    {{#if_language_python}}
    python_version = sys.version.split()[0]
    log(f"{checkmark()} Python {python_version}")
    
    major, minor = map(int, python_version.split('.')[:2])
    if major < {{PYTHON_MAJOR}} or (major == {{PYTHON_MAJOR}} and minor < {{PYTHON_MINOR}}):
        log(f"{warning()} Python version should be {{PYTHON_MIN_VERSION}} or higher", 'YELLOW')
        all_checks_pass = False
    {{/if_language_python}}
    
    # Check environment variables
    log('\nEnvironment Variables:', 'BLUE')
    required_env_vars = [
        {{#each REQUIRED_ENV_VARS}}
        '{{this}}',
        {{/each}}
    ]
    
    for env_var in required_env_vars:
        if os.environ.get(env_var):
            log(f"{checkmark()} {env_var} is set")
        else:
            log(f"{crossmark()} {env_var} is not set")
            all_checks_pass = False
    
    # Check file system
    log('\nFile System:', 'BLUE')
    required_dirs = [
        {{#each REQUIRED_DIRECTORIES}}
        '{{this}}',
        {{/each}}
    ]
    
    for dir_path in required_dirs:
        if Path(dir_path).exists() and Path(dir_path).is_dir():
            log(f"{checkmark()} Directory {dir_path} exists")
        else:
            log(f"{crossmark()} Directory {dir_path} missing")
            all_checks_pass = False
    
    required_files = [
        {{#each REQUIRED_FILES}}
        '{{this}}',
        {{/each}}
    ]
    
    for file_path in required_files:
        if Path(file_path).exists():
            log(f"{checkmark()} File {file_path} exists")
        else:
            log(f"{crossmark()} File {file_path} missing")
            all_checks_pass = False
    
    {{#if_database_mongodb}}
    # Check MongoDB connection
    log('\nDatabase Connection:', 'BLUE')
    mongodb_uri = os.environ.get('MONGODB_URI')
    if mongodb_uri:
        try:
            from pymongo import MongoClient
            client = MongoClient(mongodb_uri, serverSelectionTimeoutMS=5000)
            client.admin.command('ping')
            log(f"{checkmark()} MongoDB connection successful")
            client.close()
        except Exception as e:
            log(f"{crossmark()} MongoDB connection failed: {str(e)}")
            all_checks_pass = False
    else:
        log(f"{crossmark()} MONGODB_URI not configured")
        all_checks_pass = False
    {{/if_database_mongodb}}
    
    {{#if_database_postgresql}}
    # Check PostgreSQL connection
    log('\nDatabase Connection:', 'BLUE')
    database_url = os.environ.get('DATABASE_URL')
    if database_url:
        try:
            import psycopg2
            conn = psycopg2.connect(database_url)
            cur = conn.cursor()
            cur.execute('SELECT 1')
            log(f"{checkmark()} PostgreSQL connection successful")
            cur.close()
            conn.close()
        except Exception as e:
            log(f"{crossmark()} PostgreSQL connection failed: {str(e)}")
            all_checks_pass = False
    else:
        log(f"{crossmark()} DATABASE_URL not configured")
        all_checks_pass = False
    {{/if_database_postgresql}}
    
    {{#if_database_mysql}}
    # Check MySQL connection
    log('\nDatabase Connection:', 'BLUE')
    mysql_host = os.environ.get('MYSQL_HOST')
    mysql_user = os.environ.get('MYSQL_USER')
    if mysql_host and mysql_user:
        try:
            import mysql.connector
            conn = mysql.connector.connect(
                host=mysql_host,
                user=mysql_user,
                password=os.environ.get('MYSQL_PASSWORD', ''),
                database=os.environ.get('MYSQL_DATABASE')
            )
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            log(f"{checkmark()} MySQL connection successful")
            cursor.close()
            conn.close()
        except Exception as e:
            log(f"{crossmark()} MySQL connection failed: {str(e)}")
            all_checks_pass = False
    else:
        log(f"{crossmark()} MySQL connection not configured")
        all_checks_pass = False
    {{/if_database_mysql}}
    
    {{#if_docker_required}}
    # Check Docker services
    log('\nDocker Services:', 'BLUE')
    try:
        result = subprocess.run(
            ['docker', 'ps', '--format', 'table {{.Names}}\t{{.Status}}'],
            capture_output=True, text=True, check=True
        )
        running_containers = [line for line in result.stdout.split('\n')[1:] if line.strip()]
        
        expected_containers = [
            {{#each DOCKER_SERVICES}}
            '{{container_name}}',
            {{/each}}
        ]
        
        for container in expected_containers:
            is_running = any(container in line for line in running_containers)
            if is_running:
                log(f"{checkmark()} {container} is running")
            else:
                log(f"{crossmark()} {container} is not running")
                all_checks_pass = False
    except Exception as e:
        log(f"{warning()} Could not check Docker services: {str(e)}", 'YELLOW')
    {{/if_docker_required}}
    
    # Check dependencies
    log('\nDependencies:', 'BLUE')
    {{#if_language_python}}
    if Path('requirements.txt').exists():
        try:
            result = subprocess.run(
                [sys.executable, '-m', 'pip', 'list', '--format', 'json'],
                capture_output=True, text=True, check=True
            )
            installed_packages = json.loads(result.stdout)
            log(f"{checkmark()} Dependencies installed ({len(installed_packages)} packages)")
        except Exception:
            log(f"{crossmark()} Could not check installed packages")
            all_checks_pass = False
    else:
        log(f"{warning()} requirements.txt not found", 'YELLOW')
    
    # Check virtual environment
    if hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
        log(f"{checkmark()} Running in virtual environment")
    else:
        log(f"{warning()} Not running in virtual environment", 'YELLOW')
    {{/if_language_python}}
    
    # Custom health checks
    {{#each CUSTOM_HEALTH_CHECKS}}
    try:
        {{check_code}}
        log(f"{checkmark()} {{success_message}}")
    except Exception as e:
        log(f"{crossmark()} {{failure_message}}: {str(e)}")
        all_checks_pass = False
    {{/each}}
    
    # Summary
    log('\n' + '=' * 50, 'BLUE')
    if all_checks_pass:
        log('🎉 All health checks passed!', 'GREEN')
        log('\nYour development environment is ready.', 'GREEN')
    else:
        log('❌ Some health checks failed', 'RED')
        log('\nPlease fix the issues above before proceeding.', 'YELLOW')
        sys.exit(1)

def main():
    # Load environment variables if .env exists
    if Path('.env').exists():
        try:
            from dotenv import load_dotenv
            load_dotenv()
        except ImportError:
            log(f"{warning()} python-dotenv not installed, skipping .env file", 'YELLOW')
    
    try:
        check_environment()
    except Exception as e:
        log(f"\n{crossmark()} Health check failed with error:", 'RED')
        print(e)
        sys.exit(1)

if __name__ == '__main__':
    main()