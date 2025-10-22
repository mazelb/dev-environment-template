# Secrets Management Guide

**Version:** 2.0  
**Last Updated:** October 20, 2025  

Complete guide to managing secrets (API keys, credentials, tokens) across all environments in your dev environment template.

---

## 📖 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Local Development](#local-development)
- [GitHub Codespaces](#github-codespaces)
- [GitHub Actions (CI/CD)](#github-actions-cicd)
- [Docker Secrets](#docker-secrets)
- [AWS Secrets Manager](#aws-secrets-manager)
- [Azure Key Vault](#azure-key-vault)
- [Best Practices](#best-practices)
- [Security Guidelines](#security-guidelines)
- [Troubleshooting](#troubleshooting)

---

## Overview

### What Are Secrets?

Secrets are sensitive information that should never be committed to version control:

- **API Keys:** Anthropic, OpenAI, Google, etc.
- **Database Credentials:** Passwords, connection strings
- **Service Tokens:** GitHub, Slack, AWS
- **Encryption Keys:** JWT secrets, encryption keys
- **Certificates:** SSL/TLS certificates, private keys

### Why Secrets Management Matters

**❌ Without proper secrets management:**
- API keys exposed in git history
- Credentials leaked to public repositories
- Security breaches and data theft
- Compliance violations
- Unauthorized access to services

**✅ With proper secrets management:**
- Secrets never in version control
- Encrypted at rest and in transit
- Role-based access control
- Audit logging of secret access
- Easy rotation and revocation
- Compliance with security standards

### Six Methods Supported

| Method | Environment | Security | Complexity | Cost |
|--------|-------------|----------|------------|------|
| [.env.local](#local-development) | Local dev | Medium | Easy | Free |
| [GitHub Codespaces](#github-codespaces) | Cloud dev | High | Easy | Free |
| [GitHub Actions](#github-actions-cicd) | CI/CD | High | Easy | Free |
| [Docker Secrets](#docker-secrets) | Docker Swarm | High | Medium | Free |
| [AWS Secrets Manager](#aws-secrets-manager) | AWS Prod | Very High | Medium | $0.40/mo |
| [Azure Key Vault](#azure-key-vault) | Azure Prod | Very High | Medium | $0.03/10k |

---

## Quick Start

### Interactive Setup

The easiest way to configure secrets:

```bash
# Run the interactive setup wizard
./scripts/setup-secrets.sh

# Choose your method:
# 1) Local Development (.env.local)
# 2) GitHub Codespaces
# 3) GitHub Actions
# 4) Docker Secrets
# 5) AWS Secrets Manager
# 6) Azure Key Vault
# 7) All of the above

# Follow prompts to configure
```

### Manual Quick Setup

**Local development (2 minutes):**
```bash
# 1. Copy template
cp .env.local.example .env.local

# 2. Add your keys
nano .env.local

# 3. Done!
```

**GitHub Codespaces (3 minutes):**
```bash
# 1. Go to: https://github.com/settings/codespaces
# 2. Click "New secret"
# 3. Add: ANTHROPIC_API_KEY, OPENAI_API_KEY
# 4. Done!
```

---

## Local Development

### Setup with .env.local

**Best for:** Individual developers working locally

#### Step 1: Create .env.local

```bash
# Copy template
cp .env.local.example .env.local

# Or create from scratch
cat > .env.local << 'EOF'
# Anthropic API Key (Claude)
ANTHROPIC_API_KEY=sk-ant-your_key_here

# OpenAI API Key (GPT)
OPENAI_API_KEY=sk-your_key_here

# Google API Key (Gemini)
GOOGLE_API_KEY=your_google_key_here

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
POSTGRES_PASSWORD=your_secure_password

# Redis
REDIS_URL=redis://localhost:6379

# Other Services
GITHUB_TOKEN=ghp_your_token_here
SLACK_TOKEN=xoxb-your_token_here
EOF
```

#### Step 2: Verify .gitignore

```bash
# Ensure .env.local is ignored
grep ".env.local" .gitignore

# If not present, add it
echo ".env.local" >> .gitignore
```

#### Step 3: Load in Application

**Python:**
```python
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv('.env.local')

# Access secrets
api_key = os.getenv('ANTHROPIC_API_KEY')
db_url = os.getenv('DATABASE_URL')

# Use in your code
from anthropic import Anthropic
client = Anthropic(api_key=api_key)
```

**Node.js:**
```javascript
require('dotenv').config({ path: '.env.local' });

// Access secrets
const apiKey = process.env.ANTHROPIC_API_KEY;
const dbUrl = process.env.DATABASE_URL;

// Use in your code
const Anthropic = require('@anthropic-ai/sdk');
const client = new Anthropic({ apiKey });
```

**Shell scripts:**
```bash
#!/bin/bash

# Source .env.local
set -a
source .env.local
set +a

# Use secrets
echo "API Key loaded: ${ANTHROPIC_API_KEY:0:10}..."
```

#### Step 4: Load in Docker Container

**Method 1: Docker Compose (Recommended)**

Edit `docker-compose.yml`:
```yaml
services:
  dev:
    # ... other config
    env_file:
      - .env.local
    environment:
      # Optional: Override specific variables
      - DATABASE_URL=postgresql://postgres:password@db:5432/app
```

**Method 2: Command Line**
```bash
# Start with .env.local
docker-compose --env-file .env.local up -d dev

# Verify secrets loaded
docker-compose exec dev bash
echo $ANTHROPIC_API_KEY
```

### Advantages

✅ Simple and fast  
✅ Works offline  
✅ No external dependencies  
✅ Easy to update  
✅ Developer has full control  

### Disadvantages

⚠️ File can be accidentally committed  
⚠️ Not encrypted on disk  
⚠️ Each developer manages their own  
⚠️ Harder to rotate for teams  

### Security Tips

```bash
# Restrict file permissions (Linux/macOS)
chmod 600 .env.local

# Never commit .env.local
git status  # Should not show .env.local

# Use different keys for each developer
# Don't share production keys
```

---

## GitHub Codespaces

### Setup GitHub Codespaces Secrets

**Best for:** Cloud-based development, team collaboration

#### Step 1: Add Repository Secrets

```bash
# 1. Go to your repository on GitHub
# 2. Navigate to: Settings → Secrets and variables → Codespaces
# 3. Click "New repository secret"

# 4. Add each secret:
Name: ANTHROPIC_API_KEY
Value: sk-ant-your_key_here

Name: OPENAI_API_KEY
Value: sk-your_key_here

Name: GOOGLE_API_KEY
Value: your_google_key_here

# 5. Secrets are encrypted by GitHub
# 6. Available in all Codespaces for this repo
```

#### Step 2: Configure Auto-loading

The template includes `.devcontainer/load-secrets.sh` that automatically loads Codespaces secrets.

**Verify it's configured:**

```bash
# Check .devcontainer/devcontainer.json
cat .devcontainer/devcontainer.json

# Should include:
{
  "postCreateCommand": "bash .devcontainer/post-create.sh"
}
```

**The load-secrets.sh script:**
```bash
#!/bin/bash
# Automatically loads GitHub Codespaces secrets
# into .env file in the container

# Script checks for these environment variables:
# - ANTHROPIC_API_KEY
# - OPENAI_API_KEY
# - GOOGLE_API_KEY
# - DATABASE_URL
# - And many more...

# Creates .env file with all found secrets
# Exports them to environment
```

#### Step 3: Use in Codespace

```bash
# 1. Create or open Codespace
# 2. Secrets automatically loaded
# 3. Check environment:
echo $ANTHROPIC_API_KEY

# 4. Use in code - no changes needed!
python your_script.py
```

#### Organization-wide Secrets

**For teams:**
```bash
# 1. Go to: https://github.com/organizations/LeMazOrg/settings/secrets/codespaces
# 2. Add organization secrets
# 3. Select repository access
# 4. All org members get these secrets in Codespaces
```

### Advantages

✅ Encrypted by GitHub  
✅ Automatic loading  
✅ No local files to manage  
✅ Works across machines  
✅ Easy team secret sharing  
✅ Free for public repos  

### Disadvantages

⚠️ Requires GitHub account  
⚠️ Internet connection required  
⚠️ Limited to 60 hours/month (free tier)  

---

## GitHub Actions (CI/CD)

### Setup GitHub Actions Secrets

**Best for:** Continuous Integration/Deployment

#### Step 1: Add Actions Secrets

```bash
# 1. Go to: https://github.com/mazelb/dev-environment-template/settings/secrets/actions
# 2. Click "New repository secret"

# 3. Add secrets for CI/CD:
Name: ANTHROPIC_API_KEY_TEST
Value: sk-ant-test_key_here

Name: DATABASE_URL_TEST
Value: postgresql://test:test@localhost:5432/test_db

# Use separate test keys, not production!
```

#### Step 2: Use in Workflows

**Create `.github/workflows/test.yml`:**

```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    env:
      # Load secrets
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY_TEST }}
      DATABASE_URL: ${{ secrets.DATABASE_URL_TEST }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Run tests
        run: |
          pytest tests/
          # Secrets available as environment variables
```

**Example: Deploy with secrets:**

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to server
        env:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          SERVER_HOST: ${{ secrets.SERVER_HOST }}
        run: |
          # Setup SSH
          mkdir -p ~/.ssh
          echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          
          # Deploy
          ssh user@$SERVER_HOST 'cd /app && git pull && docker-compose up -d'
```

#### Environment-specific Secrets

```yaml
jobs:
  deploy-staging:
    environment: staging
    env:
      API_KEY: ${{ secrets.STAGING_API_KEY }}
      
  deploy-production:
    environment: production
    env:
      API_KEY: ${{ secrets.PRODUCTION_API_KEY }}
```

### Advantages

✅ Encrypted by GitHub  
✅ Automatic masking in logs  
✅ Environment-specific secrets  
✅ Required checks  
✅ Audit logging  
✅ Free for public repos  

### Security

- Secrets are masked in logs automatically
- Use environment protection rules
- Require approvals for production
- Rotate keys regularly
- Use separate keys per environment

---

## Docker Secrets

### Setup Docker Swarm Secrets

**Best for:** Production with Docker Swarm

#### Prerequisites

```bash
# Initialize Docker Swarm
docker swarm init
```

#### Step 1: Create Secrets

```bash
# Create secret from file
echo "sk-ant-your_key_here" | docker secret create anthropic_api_key -

# Create from existing file
docker secret create postgres_password ./postgres_password.txt

# Create multiple secrets
cat secrets.txt | while read line; do
  key=$(echo $line | cut -d= -f1)
  value=$(echo $line | cut -d= -f2)
  echo $value | docker secret create $key -
done
```

#### Step 2: Use in Docker Compose

**docker-compose.yml:**
```yaml
version: '3.7'

services:
  app:
    image: my-app:latest
    secrets:
      - anthropic_api_key
      - postgres_password
    environment:
      # Secret files are mounted at:
      - ANTHROPIC_API_KEY_FILE=/run/secrets/anthropic_api_key
      - POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

secrets:
  anthropic_api_key:
    external: true
  postgres_password:
    external: true
```

#### Step 3: Read Secrets in Application

**Python:**
```python
import os

def read_secret(secret_name):
    """Read Docker secret from file"""
    secret_path = f'/run/secrets/{secret_name}'
    try:
        with open(secret_path, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        # Fallback to environment variable
        return os.getenv(secret_name.upper())

# Use secrets
api_key = read_secret('anthropic_api_key')
db_password = read_secret('postgres_password')
```

**Node.js:**
```javascript
const fs = require('fs');

function readSecret(secretName) {
  const secretPath = `/run/secrets/${secretName}`;
  try {
    return fs.readFileSync(secretPath, 'utf8').trim();
  } catch (err) {
    // Fallback to environment variable
    return process.env[secretName.toUpperCase()];
  }
}

// Use secrets
const apiKey = readSecret('anthropic_api_key');
const dbPassword = readSecret('postgres_password');
```

#### Manage Secrets

```bash
# List secrets
docker secret ls

# Inspect secret (doesn't show value)
docker secret inspect anthropic_api_key

# Remove secret
docker secret rm anthropic_api_key

# Update secret (remove and recreate)
docker secret rm anthropic_api_key
echo "new_key_value" | docker secret create anthropic_api_key -

# Rotate secret
./scripts/rotate-docker-secret.sh anthropic_api_key new_value
```

### Advantages

✅ Encrypted at rest and in transit  
✅ Never written to disk unencrypted  
✅ Scoped to specific services  
✅ Immutable (must recreate to update)  
✅ Free with Docker Swarm  

### Disadvantages

⚠️ Requires Docker Swarm  
⚠️ More complex than .env files  
⚠️ Harder to update (immutable)  

---

## AWS Secrets Manager

### Setup AWS Secrets Manager

**Best for:** Production deployments on AWS

#### Prerequisites

```bash
# Install AWS CLI
pip install awscli

# Configure AWS credentials
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
```

#### Step 1: Create Secrets

**Via AWS CLI:**
```bash
# Create secret
aws secretsmanager create-secret \
  --name dev-env/anthropic-api-key \
  --description "Anthropic API key for Claude" \
  --secret-string "sk-ant-your_key_here"

# Create secret from file
aws secretsmanager create-secret \
  --name dev-env/database-config \
  --secret-string file://database-config.json

# Create with JSON structure
aws secretsmanager create-secret \
  --name dev-env/all-api-keys \
  --secret-string '{
    "anthropic": "sk-ant-xxx",
    "openai": "sk-xxx",
    "google": "xxx"
  }'
```

**Via AWS Console:**
```bash
# 1. Go to: https://console.aws.amazon.com/secretsmanager/
# 2. Click "Store a new secret"
# 3. Select secret type (Other)
# 4. Add key-value pairs
# 5. Name: dev-env/anthropic-api-key
# 6. Enable automatic rotation (optional)
# 7. Create secret
```

#### Step 2: Set IAM Permissions

**Create IAM policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:dev-env/*"
    }
  ]
}
```

**Attach to IAM role:**
```bash
# Attach to EC2 instance role
aws iam attach-role-policy \
  --role-name MyEC2Role \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/SecretsManagerReadOnly
```

#### Step 3: Load Secrets in Application

**Python (boto3):**
```python
import boto3
import json

def get_secret(secret_name):
    """Retrieve secret from AWS Secrets Manager"""
    client = boto3.client('secretsmanager')
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        
        # Parse secret
        if 'SecretString' in response:
            secret = response['SecretString']
            return json.loads(secret) if secret.startswith('{') else secret
        else:
            return response['SecretBinary']
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return None

# Use secret
api_key = get_secret('dev-env/anthropic-api-key')

# Or get JSON structure
all_keys = get_secret('dev-env/all-api-keys')
anthropic_key = all_keys['anthropic']
openai_key = all_keys['openai']
```

**Node.js:**
```javascript
const AWS = require('aws-sdk');

async function getSecret(secretName) {
  const client = new AWS.SecretsManager();
  
  try {
    const data = await client.getSecretValue({ SecretId: secretName }).promise();
    
    if ('SecretString' in data) {
      const secret = data.SecretString;
      return secret.startsWith('{') ? JSON.parse(secret) : secret;
    }
  } catch (err) {
    console.error('Error retrieving secret:', err);
    return null;
  }
}

// Use secret
const apiKey = await getSecret('dev-env/anthropic-api-key');
```

#### Step 4: Load on Container Startup

**Create startup script:**
```bash
#!/bin/bash
# scripts/load-aws-secrets.sh

# Load secrets from AWS Secrets Manager
export ANTHROPIC_API_KEY=$(aws secretsmanager get-secret-value \
  --secret-id dev-env/anthropic-api-key \
  --query SecretString \
  --output text)

export OPENAI_API_KEY=$(aws secretsmanager get-secret-value \
  --secret-id dev-env/openai-api-key \
  --query SecretString \
  --output text)

# Start application
python app.py
```

**Update Dockerfile:**
```dockerfile
FROM python:3.11

# Install AWS CLI
RUN pip install awscli boto3

# Copy application
COPY . /app
WORKDIR /app

# Load secrets and start
CMD ["bash", "scripts/load-aws-secrets.sh"]
```

#### Enable Automatic Rotation

**Create rotation Lambda:**
```python
# lambda_function.py
import boto3

def lambda_handler(event, context):
    secret_id = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']
    
    client = boto3.client('secretsmanager')
    
    if step == "createSecret":
        # Generate new secret
        new_secret = generate_new_api_key()
        client.put_secret_value(
            SecretId=secret_id,
            ClientRequestToken=token,
            SecretString=new_secret,
            VersionStages=['AWSPENDING']
        )
    
    elif step == "setSecret":
        # Update service with new secret
        update_service_api_key(new_secret)
    
    elif step == "testSecret":
        # Test new secret
        test_api_key(new_secret)
    
    elif step == "finishSecret":
        # Mark new secret as current
        client.update_secret_version_stage(
            SecretId=secret_id,
            VersionStage='AWSCURRENT',
            MoveToVersionId=token
        )
```

**Enable rotation:**
```bash
aws secretsmanager rotate-secret \
  --secret-id dev-env/anthropic-api-key \
  --rotation-lambda-arn arn:aws:lambda:region:account:function:rotate-secret \
  --rotation-rules AutomaticallyAfterDays=30
```

### Advantages

✅ Encrypted with AWS KMS  
✅ Automatic rotation  
✅ Fine-grained IAM permissions  
✅ CloudTrail audit logging  
✅ Cross-region replication  
✅ Versioning of secrets  

### Cost

- $0.40 per secret per month
- $0.05 per 10,000 API calls
- Example: 5 secrets = $2/month

---

## Azure Key Vault

### Setup Azure Key Vault

**Best for:** Production deployments on Azure

#### Prerequisites

```bash
# Install Azure CLI
pip install azure-cli

# Login to Azure
az login
```

#### Step 1: Create Key Vault

```bash
# Create resource group
az group create \
  --name dev-env-secrets \
  --location eastus

# Create Key Vault
az keyvault create \
  --name dev-env-keyvault \
  --resource-group dev-env-secrets \
  --location eastus
```

#### Step 2: Add Secrets

**Via Azure CLI:**
```bash
# Add secret
az keyvault secret set \
  --vault-name dev-env-keyvault \
  --name anthropic-api-key \
  --value "sk-ant-your_key_here"

# Add from file
az keyvault secret set \
  --vault-name dev-env-keyvault \
  --name database-config \
  --file database-config.json
```

**Via Azure Portal:**
```bash
# 1. Go to: https://portal.azure.com
# 2. Navigate to Key Vaults
# 3. Select your vault
# 4. Click Secrets → Generate/Import
# 5. Name: anthropic-api-key
# 6. Value: sk-ant-xxx
# 7. Create
```

#### Step 3: Set Access Policy

```bash
# Grant access to service principal
az keyvault set-policy \
  --name dev-env-keyvault \
  --spn YOUR_APP_ID \
  --secret-permissions get list

# Grant access to managed identity
az keyvault set-policy \
  --name dev-env-keyvault \
  --object-id YOUR_MANAGED_IDENTITY_ID \
  --secret-permissions get list
```

#### Step 4: Load Secrets in Application

**Python:**
```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

# Initialize client
credential = DefaultAzureCredential()
vault_url = "https://dev-env-keyvault.vault.azure.net/"
client = SecretClient(vault_url=vault_url, credential=credential)

# Get secret
secret = client.get_secret("anthropic-api-key")
api_key = secret.value

# List all secrets
secrets = client.list_properties_of_secrets()
for secret in secrets:
    print(f"Secret: {secret.name}")
```

**Node.js:**
```javascript
const { DefaultAzureCredential } = require('@azure/identity');
const { SecretClient } = require('@azure/keyvault-secrets');

// Initialize client
const credential = new DefaultAzureCredential();
const vaultUrl = 'https://dev-env-keyvault.vault.azure.net/';
const client = new SecretClient(vaultUrl, credential);

// Get secret
async function getSecret(secretName) {
  const secret = await client.getSecret(secretName);
  return secret.value;
}

// Use secret
const apiKey = await getSecret('anthropic-api-key');
```

#### Step 5: Use with Managed Identity

**In Azure VM or App Service:**
```python
# No credentials needed - uses Managed Identity automatically
from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient

credential = ManagedIdentityCredential()
client = SecretClient(
    vault_url="https://dev-env-keyvault.vault.azure.net/",
    credential=credential
)

api_key = client.get_secret("anthropic-api-key").value
```

### Advantages

✅ Azure AD authentication  
✅ Role-Based Access Control (RBAC)  
✅ Soft-delete and purge protection  
✅ Audit logging  
✅ HSM-backed options  
✅ Integrated with Azure services  

### Cost

- $0.03 per 10,000 transactions
- Premium (HSM): $1.00 per month per key
- Example: 50,000 API calls/month = $0.15

---

## Best Practices

### General Guidelines

**✅ DO:**
- Use different keys for dev/staging/prod
- Rotate keys regularly (every 90 days)
- Use secret management for all environments
- Document which secrets are needed
- Provide .env.example with dummy values
- Use environment-specific prefixes
- Enable audit logging
- Set up alerts for unauthorized access
- Use least privilege access
- Backup secrets securely

**❌ DON'T:**
- Commit secrets to version control
- Hardcode secrets in code
- Share production keys
- Use same key across environments
- Log secret values
- Send secrets in emails/Slack
- Store secrets in wikis/docs
- Skip encryption
- Use weak passwords
- Ignore rotation schedules

### Environment Strategy

**Use this pattern:**
```bash
# Development
ANTHROPIC_API_KEY_DEV=sk-ant-dev_xxx

# Staging
ANTHROPIC_API_KEY_STAGING=sk-ant-staging_xxx

# Production
ANTHROPIC_API_KEY_PROD=sk-ant-prod_xxx
```

### Secret Naming Conventions

```bash
# Good naming
ANTHROPIC_API_KEY          # Clear, concise
DATABASE_URL               # Standard convention
POSTGRES_PASSWORD          # Specific
AWS_ACCESS_KEY_ID          # Official name

# Bad naming
KEY1                       # Too vague
my_key                     # Inconsistent case
secret                     # Not descriptive
password                   # Too generic
```

### Rotation Schedule

| Secret Type | Rotation Frequency |
|-------------|-------------------|
| API Keys (dev) | 90 days |
| API Keys (prod) | 60 days |
| Database Passwords | 90 days |
| SSH Keys | 180 days |
| Encryption Keys | 365 days |
| Certificates | 90 days before expiry |

### Team Workflow

**For individuals:**
```bash
# Each developer:
1. Create .env.local with personal keys
2. Never share .env.local
3. Use separate dev keys
4. Document in .env.example
```

**For teams:**
```bash
# Team lead:
1. Create GitHub Codespaces secrets (shared dev keys)
2. Document in README
3. Add team members to repository
4. Rotate keys quarterly

# Team members:
1. Use Codespaces for shared development
2. Create .env.local for local testing
3. Use separate keys from production
```

---

## Security Guidelines

### Never Commit Secrets

**Check before every commit:**
```bash
# Search for potential secrets
git diff | grep -i "api_key\|password\|secret\|token"

# Use git-secrets tool
git secrets --scan

# Pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
if git diff --cached | grep -i "sk-ant\|sk-\|api_key"; then
  echo "Error: Potential secret detected"
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit
```

### If Secrets Are Committed

**Immediate response:**
```bash
# 1. Revoke compromised keys immediately
# Go to provider dashboard and revoke

# 2. Remove from git history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch .env.local' \
  --prune-empty --tag-name-filter cat -- --all

# 3. Force push (caution!)
git push --force --all

# 4. Generate new keys
# Create new keys from provider

# 5. Update secrets
# Update in all secret management systems

# 6. Notify team
# Let everyone know keys were rotated
```

### Least Privilege Access

```bash
# AWS IAM policy - minimal permissions
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["secretsmanager:GetSecretValue"],
    "Resource": "arn:aws:secretsmanager:*:*:secret:dev-env/app-*"
  }]
}

# Azure RBAC - minimal permissions
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee $APP_ID \
  --scope /subscriptions/$SUB_ID/resourceGroups/$RG/providers/Microsoft.KeyVault/vaults/$VAULT
```

### Monitoring and Alerts

**AWS CloudWatch:**
```bash
# Create alarm for unauthorized access
aws cloudwatch put-metric-alarm \
  --alarm-name secrets-unauthorized-access \
  --metric-name UnauthorizedAPICall \
  --namespace AWS/SecretsManager \
  --statistic Sum \
  --period 60 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold
```

**Azure Monitor:**
```bash
# Create alert for secret access
az monitor metrics alert create \
  --name secret-access-alert \
  --resource-group dev-env-secrets \
  --scopes $VAULT_ID \
  --condition "total UnauthorizedAccess > 0"
```

---

## Troubleshooting

### Common Issues

**Issue: Secret not loading**
```bash
# Check if .env.local exists
ls -la .env.local

# Check if variable is set
echo $ANTHROPIC_API_KEY

# Reload environment
source .env.local

# In Python
from dotenv import load_dotenv
load_dotenv('.env.local', override=True)
```

**Issue: GitHub secret not available**
```bash
# Verify secret name matches exactly (case-sensitive)
# Check repository access in secret settings
# Rebuild Codespace or re-run Action
# Check environment selection (if using environments)
```

**Issue: Docker secret not found**
```bash
# List secrets
docker secret ls

# Check service has access
docker service inspect myapp | grep -A 5 Secrets

# Recreate secret
docker secret rm anthropic_api_key
echo "new_key" | docker secret create anthropic_api_key -
```

**Issue: AWS secret access denied**
```bash
# Check IAM permissions
aws secretsmanager get-secret-value \
  --secret-id dev-env/anthropic-api-key

# Update IAM policy
aws iam put-role-policy \
  --role-name MyRole \
  --policy-name SecretsAccess \
  --policy-document file://policy.json
```

**Issue: Azure Key Vault 403 Forbidden**
```bash
# Check access policy
az keyvault show \
  --name dev-env-keyvault \
  --query properties.accessPolicies

# Add access policy
az keyvault set-policy \
  --name dev-env-keyvault \
  --object-id $OBJECT_ID \
  --secret-permissions get list
```

### Debugging Tips

**Verify secrets are loaded:**
```bash
# Check all environment variables
env | grep API_KEY

# Check specific variable
echo $ANTHROPIC_API_KEY | cut -c1-10

# In Python
import os
print(f"Key loaded: {os.getenv('ANTHROPIC_API_KEY', 'NOT FOUND')[:10]}...")

# In Node.js
console.log(`Key loaded: ${process.env.ANTHROPIC_API_KEY?.substring(0, 10)}...`);
```

**Test secret access:**
```bash
# Test API key
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
  https://api.anthropic.com/v1/messages

# Test with Python
python -c "
from anthropic import Anthropic
client = Anthropic()
print('API key works!')
"
```

---

## Summary

### Quick Decision Guide

**Choose your method:**

| If you're... | Use... |
|--------------|--------|
| Developing alone locally | .env.local |
| Using GitHub Codespaces | Codespaces Secrets |
| Running CI/CD | GitHub Actions Secrets |
| Deploying with Docker Swarm | Docker Secrets |
| On AWS production | AWS Secrets Manager |
| On Azure production | Azure Key Vault |

### Setup Time Comparison

| Method | Setup Time | Maintenance |
|--------|-----------|-------------|
| .env.local | 2 min | Low |
| GitHub Codespaces | 3 min | Low |
| GitHub Actions | 5 min | Low |
| Docker Secrets | 10 min | Medium |
| AWS Secrets Manager | 15 min | Medium |
| Azure Key Vault | 15 min | Medium |

### Essential Commands

```bash
# Local
cp .env.local.example .env.local && nano .env.local

# GitHub Codespaces
# Go to: github.com/settings/codespaces → New secret

# GitHub Actions  
# Go to: github.com/USER/REPO/settings/secrets/actions

# Docker
echo "secret" | docker secret create name -

# AWS
aws secretsmanager create-secret --name key --secret-string value

# Azure
az keyvault secret set --vault-name vault --name key --value value
```

---

**Keep your secrets safe!** 🔐

---

## Related Documentation

- [Complete Setup Guide](SETUP_GUIDE.md) - Full environment setup
- [Usage Guide](USAGE_GUIDE.md) - Daily development workflows
- [Updates Guide](UPDATES_GUIDE.md) - Keep template current
- [Troubleshooting](TROUBLESHOOTING.md) - Fix common issues

---

**Last Updated:** October 20, 2025  
**Version:** 2.0
