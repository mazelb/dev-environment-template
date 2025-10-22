# Updates Guide: Keep Template and Projects in Sync

**Version:** 2.0  
**Last Updated:** October 20, 2025  

Complete guide to continuously update your dev environment template and sync all existing projects with minimal effort.

---

## 📖 Table of Contents

- [Overview](#overview)
- [Update Strategy](#update-strategy)
- [Version Management](#version-management)
- [Updating the Template](#updating-the-template)
- [Syncing Existing Projects](#syncing-existing-projects)
- [Automation Scripts](#automation-scripts)
- [Update Workflows](#update-workflows)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Overview

### The Challenge

You've created a great dev environment template. Now you have:
- **1 template repository** on GitHub
- **10+ active projects** using the template
- **5+ team members** working on different projects
- **Continuous improvements** to add to the template

**Question:** How do you keep everything in sync without redoing setup for every project?

### The Solution

A **three-tier update system** that lets you:
1. Update template once
2. New projects auto-get latest version
3. Existing projects opt-in to updates
4. Critical updates push to all projects

**Key insight:** Don't force updates on existing projects. Let them pull changes when ready.

---

## Update Strategy

### Three Levels of Updates

#### 1. **Critical Updates** (Security, Breaking Changes)
**Apply immediately to all projects**

Examples:
- Security patches (base OS, dependencies)
- Breaking API changes
- Critical bug fixes

**Distribution:**
```bash
# Template: Create release
git tag -a v1.0.1 -m "Security: Update base image"

# Projects: Required update notification
"⚠️ CRITICAL: Security update v1.0.1 must be applied"
./scripts/sync-template.sh --version v1.0.1
```

#### 2. **Recommended Updates** (New Features, Improvements)
**Projects opt-in on their schedule**

Examples:
- New language versions (Python 3.12)
- New development tools
- Performance improvements
- New VS Code extensions

**Distribution:**
```bash
# Template: Create release
git tag -a v1.1.0 -m "Feature: Add Python 3.12"

# Projects: Optional update
"💡 RECOMMENDED: Template v1.1.0 available"
./scripts/check-template-updates.sh    # See changes
./scripts/sync-template.sh             # Apply when ready
```

#### 3. **Optional Updates** (Experimental, Project-Specific)
**Projects choose individually**

Examples:
- New Docker services (PostgreSQL, Redis)
- Additional language support
- Experimental tools
- Project-specific configurations

**Distribution:**
```bash
# Template: Feature branch or separate branch
git checkout -b feature/add-postgres

# Projects: Manually cherry-pick if needed
git cherry-pick abc123
```

### Update Flow Diagram

```
Template Repository (v1.2.0)
         │
         ├─→ New Projects (automatically v1.2.0)
         │
         └─→ Existing Projects
                 │
                 ├─→ Critical: Must update (v1.0.1)
                 ├─→ Recommended: Should update (v1.1.0)
                 └─→ Optional: May update (v1.2.0)
```

---

## Version Management

### Semantic Versioning

Use semantic versioning: **MAJOR.MINOR.PATCH**

```
v1.2.3
│ │ │
│ │ └─→ PATCH: Bug fixes, security patches (v1.2.4)
│ └───→ MINOR: New features, backwards-compatible (v1.3.0)
└─────→ MAJOR: Breaking changes (v2.0.0)
```

**Examples:**
- `v1.0.0` → Initial release
- `v1.0.1` → Security patch
- `v1.1.0` → Add Python 3.12
- `v1.2.0` → Add PostgreSQL service
- `v2.0.0` → Complete restructure

### Version Tracking

Each project tracks which template version it uses:

```bash
# .template-version file
cat .template-version
v1.2.0
```

This file is:
- ✅ Tracked in git
- ✅ Updated by sync script
- ✅ Used to compare versions
- ✅ Part of every project

---

## Updating the Template

### Step 1: Make Changes

```bash
# Navigate to template
cd dev-environment-template

# Create feature branch
git checkout -b feature/add-python-312

# Make changes
nano Dockerfile
nano docker-compose.yml
nano README.md

# Test locally
docker-compose build --no-cache dev
docker-compose up dev
# Verify everything works
```

### Step 2: Document Changes

```bash
# Update CHANGELOG.md
cat >> CHANGELOG.md << 'EOF'

## [1.2.0] - 2025-10-20

### Added
- Python 3.12 support
- New debugging tools
- VS Code Python extension v2023.20.0

### Changed
- Updated base image to Ubuntu 24.04
- Improved Docker build time by 30%

### Fixed
- Fixed issue with Git configuration in container

EOF

# Update README.md
nano README.md
# Document new Python version
```

### Step 3: Test Thoroughly

```bash
# Build from scratch
docker-compose build --no-cache dev

# Test all languages
docker-compose exec dev python3 --version  # 3.12.x
docker-compose exec dev node --version     # v20.x.x
docker-compose exec dev g++ --version      # 13.x

# Test creating new project
./create-project.sh --name test-v1.2.0
cd test-v1.2.0
docker-compose up -d dev
docker-compose exec dev bash

# Run sample code
# Verify everything works
```

### Step 4: Commit and Push

```bash
# Add all changes
git add .

# Commit with clear message
git commit -m "feat: add Python 3.12 support

- Update Dockerfile to use Python 3.12
- Add new debugging tools
- Update VS Code extensions
- Improve documentation

BREAKING CHANGES: None
MIGRATION: Projects can opt-in when ready
"

# Push feature branch
git push origin feature/add-python-312
```

### Step 5: Create Pull Request

```bash
# On GitHub:
# 1. Create Pull Request from feature/add-python-312 to main
# 2. Add description:
#    - What changed
#    - Why it changed
#    - How to test
#    - Migration notes
# 3. Request review from team
# 4. Merge when approved
```

### Step 6: Create Release

```bash
# Checkout main and pull
git checkout main
git pull origin main

# Create tag
git tag -a v1.2.0 -m "Release v1.2.0: Python 3.12 support

Major changes:
- Python upgraded to 3.12
- New debugging tools
- Improved Docker build performance

Migration:
- Existing projects: Run ./scripts/sync-template.sh
- New projects: Automatically use v1.2.0
"

# Push tag
git push origin v1.2.0

# Verify tag
git tag -l
git show v1.2.0
```

### Step 7: Create GitHub Release

```bash
# On GitHub:
# 1. Go to Releases → Draft a new release
# 2. Choose tag: v1.2.0
# 3. Title: "v1.2.0: Python 3.12 Support"
# 4. Description:

## What's New

### Added
- Python 3.12 support with latest features
- Enhanced debugging tools (pdb, ipdb)
- New VS Code extensions for Python

### Improved
- Docker build time reduced by 30%
- Container image size reduced by 15%

### How to Update

**For new projects:**
```bash
./create-project.sh --name my-project
```

**For existing projects:**
```bash
cd existing-project
./scripts/check-template-updates.sh
./scripts/sync-template.sh
```

### Breaking Changes
None - fully backwards compatible

### Migration Guide
See [MIGRATION.md](docs/MIGRATION.md) for details

# 5. Attach any release artifacts
# 6. Publish release
```

### Step 8: Notify Team

**Slack/Email notification:**
```
🚀 Dev Template v1.2.0 Released!

Python 3.12 is now available! 

✨ New features:
- Python 3.12 with latest performance improvements
- Enhanced debugging tools
- Faster Docker builds

📖 How to update:
- New projects: Use create-project.sh (automatic)
- Existing projects: Run ./scripts/check-template-updates.sh

🔗 Release notes: https://github.com/org/template/releases/tag/v1.2.0
🆘 Questions? Check #dev-environment channel

Happy coding! 🎉
```

---

## Syncing Existing Projects

### Method 1: Using Automation Script (Recommended)

**Check for updates:**
```bash
cd my-existing-project

# Check what's new
./scripts/check-template-updates.sh

# Output shows:
# Current version: v1.1.0
# Latest version: v1.2.0
# Changes:
#   - Dockerfile (Python 3.12)
#   - docker-compose.yml (new services)
#   - README.md (documentation)
```

**Sync to latest:**
```bash
# Sync to latest version
./scripts/sync-template.sh

# Or sync to specific version
./scripts/sync-template.sh --version v1.2.0

# Script does:
# 1. Fetches latest template
# 2. Creates update branch
# 3. Merges changes intelligently
# 4. Shows what changed
# 5. Asks for confirmation
# 6. Updates .template-version
```

**Review and test:**
```bash
# Review changes
git diff main...update/template-v1.2.0

# Test in container
docker-compose build --no-cache dev
docker-compose up -d dev

# Verify Python version
docker-compose exec dev python3 --version
# Should show: Python 3.12.x

# Run project tests
docker-compose exec dev npm test
docker-compose exec dev pytest

# If all good, merge
git checkout main
git merge update/template-v1.2.0
git push origin main
```

### Method 2: Manual Sync

**Step 1: Add template remote (one-time setup)**
```bash
cd my-existing-project

# Add template as remote
git remote add template https://github.com/mazelb/dev-environment-template.git

# Fetch template
git fetch template

# Verify
git remote -v
```

**Step 2: Create update branch**
```bash
# Create branch from current main
git checkout main
git checkout -b update/template-v1.2.0

# Merge template changes
git merge template/main --allow-unrelated-histories

# Or merge specific tag
git merge v1.2.0 --allow-unrelated-histories
```

**Step 3: Resolve conflicts**
```bash
# If conflicts occur
git status

# Conflicted files are marked
# Edit each file, resolve conflicts
# Remove conflict markers: <<<<<<<, =======, >>>>>>>

# Keep your custom changes
# Accept template changes for core files

# Stage resolved files
git add <resolved-file>

# Continue merge
git merge --continue
```

**Step 4: Update version file**
```bash
# Update .template-version
echo "v1.2.0" > .template-version

# Commit
git add .template-version
git commit -m "chore: update template to v1.2.0"
```

**Step 5: Test and merge**
```bash
# Test
docker-compose build --no-cache dev
docker-compose up -d dev

# Verify
docker-compose exec dev python3 --version

# Merge to main
git checkout main
git merge update/template-v1.2.0
git push origin main
```

### Method 3: Selective Update (Cherry-pick)

**For specific changes only:**
```bash
cd my-existing-project

# Fetch template
git fetch template

# View template commits
git log template/main --oneline

# Cherry-pick specific commits
git cherry-pick abc1234  # Just the Python update

# Or cherry-pick range
git cherry-pick abc1234..def5678

# Test and commit
docker-compose build --no-cache dev
git push origin main
```

---

## Automation Scripts

### Script: `manage-template-updates.sh`

**Full-featured update management:**

```bash
# In template repository:

# Create new release
./scripts/manage-template-updates.sh release v1.2.0 \
  --message "Add Python 3.12 support"

# View changelog
./scripts/manage-template-updates.sh changelog

# Check status
./scripts/manage-template-updates.sh status
```

```bash
# In project repository:

# Check for updates
./scripts/manage-template-updates.sh check

# Sync to latest
./scripts/manage-template-updates.sh sync

# Sync to specific version
./scripts/manage-template-updates.sh sync --version v1.2.0

# View project status
./scripts/manage-template-updates.sh status
```

### Script: `check-template-updates.sh`

**Quick update checker:**

```bash
./scripts/check-template-updates.sh

# Output:
# ✓ Template: dev-environment-template
# ✓ Current version: v1.1.0
# ✓ Latest version: v1.2.0
# ℹ Updates available
#
# Changed files:
#   M Dockerfile
#   M docker-compose.yml
#   M README.md
#
# To update: ./scripts/sync-template.sh
```

### Script: `sync-template.sh`

**Simple sync wrapper:**

```bash
# Sync to latest
./scripts/sync-template.sh

# Sync to specific version
./scripts/sync-template.sh v1.2.0

# Force sync (skip confirmation)
./scripts/sync-template.sh --force
```

---

## Update Workflows

### Workflow 1: Regular Updates (Monthly)

**Template maintainer:**
```bash
# Every month:

# 1. Review feedback and issues
# Check GitHub issues, team feedback

# 2. Plan changes
# Create milestone for next version

# 3. Implement changes
git checkout -b feature/monthly-updates
# Make improvements

# 4. Test thoroughly
docker-compose build --no-cache dev

# 5. Release
./scripts/manage-template-updates.sh release v1.X.0

# 6. Notify team
# Post in Slack, send email
```

**Project teams:**
```bash
# Once per month or quarter:

# 1. Check for updates
./scripts/check-template-updates.sh

# 2. Review changes
# Read changelog, release notes

# 3. Sync when convenient
./scripts/sync-template.sh

# 4. Test thoroughly
docker-compose build dev
# Run full test suite

# 5. Deploy
git push origin main
```

### Workflow 2: Critical Security Update

**Template maintainer:**
```bash
# Immediate response:

# 1. Create hotfix branch
git checkout -b hotfix/security-CVE-2024-XXXX

# 2. Apply fix
nano Dockerfile
# Update vulnerable package

# 3. Test
docker-compose build --no-cache dev

# 4. Emergency release
./scripts/manage-template-updates.sh release v1.0.1 \
  --message "Security: Fix CVE-2024-XXXX"

# 5. Urgent notification
# Email: "⚠️ CRITICAL SECURITY UPDATE"
# Slack: @channel ping
```

**Project teams:**
```bash
# Same day:

# 1. Get notification
# "⚠️ Critical security update v1.0.1"

# 2. Sync immediately
./scripts/sync-template.sh v1.0.1

# 3. Quick test
docker-compose build dev

# 4. Emergency deploy
git push origin main
# Bypass normal review process for security
```

### Workflow 3: Feature Addition

**Template maintainer:**
```bash
# Feature development:

# 1. Create feature branch
git checkout -b feature/add-postgres

# 2. Implement feature
# Add PostgreSQL to docker-compose.yml

# 3. Document
# Update README, add usage examples

# 4. Test
docker-compose up -d postgres
# Verify integration

# 5. PR and review
git push origin feature/add-postgres
# Create PR on GitHub

# 6. Release
./scripts/manage-template-updates.sh release v1.2.0
```

**Project teams:**
```bash
# Optional update:

# 1. See announcement
# "New feature: PostgreSQL support in v1.2.0"

# 2. Decide if needed
# Team discusses: Do we need PostgreSQL?

# 3. Update if useful
./scripts/sync-template.sh v1.2.0

# OR cherry-pick just PostgreSQL
git cherry-pick abc1234
```

---

## Best Practices

### For Template Maintainers

**✅ DO:**
- **Version consistently** - Use semantic versioning
- **Test thoroughly** - Build from scratch before releasing
- **Document changes** - Clear changelog and migration guides
- **Communicate clearly** - Announce updates with details
- **Support old versions** - Keep documentation for v1.x while on v2.x
- **Make updates backward compatible** - When possible
- **Tag releases** - Always tag versions in git
- **Create GitHub releases** - With detailed notes
- **Automate testing** - CI/CD for template validation
- **Listen to feedback** - Track issues and feature requests

**❌ DON'T:**
- **Force updates** - Let projects opt-in
- **Break without warning** - Announce breaking changes early
- **Skip testing** - Always test before releasing
- **Ignore security** - Prioritize security patches
- **Abandon documentation** - Keep guides up to date
- **Rush releases** - Quality over speed

### For Project Teams

**✅ DO:**
- **Track template version** - Know which version you're on
- **Update regularly** - Stay within 1-2 versions of latest
- **Test updates** - Full test suite after syncing
- **Review changes** - Read changelog before updating
- **Backup before updates** - Commit current state first
- **Update critical patches immediately** - Security first
- **Communicate updates** - Tell team about template changes
- **Provide feedback** - Report issues to template maintainers

**❌ DON'T:**
- **Ignore updates** - Don't fall too far behind
- **Update blindly** - Review changes first
- **Skip testing** - Always test after sync
- **Modify core files** - Preserve template structure
- **Forget to commit** - Track updates in version control

### Version Strategy

**Recommended update schedule:**

| Update Type | Frequency | Example |
|-------------|-----------|---------|
| **Security patches** | Immediate | Within 24 hours |
| **Bug fixes** | As needed | Within 1 week |
| **Feature updates** | Monthly | Review and sync monthly |
| **Major versions** | Quarterly | Plan and test carefully |

**Template release schedule:**

| Version | Schedule | Contents |
|---------|----------|----------|
| **Patch** (v1.0.x) | As needed | Bug fixes, security |
| **Minor** (v1.x.0) | Monthly | New features, improvements |
| **Major** (vx.0.0) | Yearly | Breaking changes, redesign |

---

## Troubleshooting

### Common Issues

**Issue: Merge conflicts during sync**

```bash
# Conflict in Dockerfile
git status
# both modified: Dockerfile

# Option 1: Accept template version
git checkout --theirs Dockerfile

# Option 2: Keep your version
git checkout --ours Dockerfile

# Option 3: Manual merge
nano Dockerfile
# Edit to combine both versions
# Remove conflict markers

# Continue merge
git add Dockerfile
git merge --continue
```

**Issue: Template remote not found**

```bash
# Add template remote
git remote add template https://github.com/mazelb/dev-environment-template.git

# Fetch
git fetch template

# Verify
git remote -v
```

**Issue: Docker build fails after update**

```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache dev

# Check logs
docker-compose logs dev

# Verify Dockerfile syntax
docker-compose config
```

**Issue: Lost custom changes**

```bash
# View what changed in merge
git log --merge

# Find your changes
git log --all --grep="your custom feature"

# Restore from backup branch
git checkout backup-branch -- path/to/file

# Or restore specific commit
git cherry-pick abc1234
```

**Issue: Version file out of sync**

```bash
# Check current version
cat .template-version

# Check git history
git log --all --grep="template-v"

# Update version file
echo "v1.2.0" > .template-version
git add .template-version
git commit -m "fix: update template version to v1.2.0"
```

### Recovery Procedures

**Undo sync (before pushing):**
```bash
# Abort merge in progress
git merge --abort

# Reset to before sync
git reset --hard origin/main

# Start over
./scripts/sync-template.sh
```

**Undo sync (after pushing):**
```bash
# Revert merge commit
git revert -m 1 HEAD

# Or reset to before sync
git reset --hard HEAD~1
git push --force origin main  # Caution!
```

**Start fresh with new template:**
```bash
# Backup current project
cp -r my-project my-project-backup

# Remove template tracking
cd my-project
git remote remove template

# Re-add with new URL
git remote add template https://github.com/NEW_ORG/new-template.git
git fetch template

# Sync
./scripts/sync-template.sh
```

---

## Summary

### Update Strategy Overview

**Three tiers:**
1. **Critical** → Must update immediately
2. **Recommended** → Should update monthly
3. **Optional** → May update when needed

**Key commands:**
```bash
# Template: Create release
./scripts/manage-template-updates.sh release v1.2.0

# Projects: Check updates
./scripts/check-template-updates.sh

# Projects: Sync updates
./scripts/sync-template.sh
```

**Best practices:**
- Version with semantic versioning
- Test thoroughly before releasing
- Document all changes
- Communicate updates clearly
- Support backward compatibility
- Let projects opt-in to updates

### Quick Reference

| Task | Command |
|------|---------|
| Create release | `./scripts/manage-template-updates.sh release v1.2.0` |
| View changelog | `./scripts/manage-template-updates.sh changelog` |
| Check updates | `./scripts/check-template-updates.sh` |
| Sync latest | `./scripts/sync-template.sh` |
| Sync version | `./scripts/sync-template.sh v1.2.0` |
| View status | `./scripts/manage-template-updates.sh status` |

---

**Next Steps:**
- Set up template remote in projects
- Create your first release
- Sync one project as test
- Roll out to team

**Related Documentation:**
- [Complete Setup Guide](SETUP_GUIDE.md) - Initial setup
- [Usage Guide](USAGE_GUIDE.md) - Daily workflows
- [Secrets Management](SECRETS_MANAGEMENT.md) - API keys
- [Troubleshooting](TROUBLESHOOTING.md) - Fix issues

---

**Keep your environment current!** 🚀
