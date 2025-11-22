#!/bin/bash

#############################################################
# GitHub Repository Creator
# Part of Multi-Archetype System Phase 5
# Creates GitHub repositories and configures settings
#############################################################

set -e

# Check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo "⚠️  GitHub CLI (gh) not found - not installed."
        echo "   Install from: https://cli.github.com/"
        echo "   Skipping GitHub repository creation..."
        return 1
    fi
    return 0
}

# Check if user is authenticated with GitHub CLI
check_gh_auth() {
    if ! gh auth status &> /dev/null; then
        echo "⚠️  Not authenticated with GitHub CLI."
        echo "   Run: gh auth login"
        echo "   Skipping GitHub repository creation..."
        return 1
    fi
    return 0
}

# Create GitHub repository
create_github_repo() {
    local project_dir="$1"
    local project_name="$2"
    local org="${3:-}"
    local visibility="${4:-public}"
    local description="${5:-}"
    
    echo ""
    echo "🌐 Creating GitHub Repository..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check prerequisites
    if ! check_gh_cli; then
        return 1
    fi
    
    if ! check_gh_auth; then
        return 1
    fi
    
    # Build gh repo create command
    local repo_name="$project_name"
    local gh_cmd="gh repo create"
    
    # Add organization if specified
    if [ -n "$org" ]; then
        gh_cmd="$gh_cmd $org/$repo_name"
    else
        gh_cmd="$gh_cmd $repo_name"
    fi
    
    # Add visibility flag
    if [ "$visibility" = "private" ]; then
        gh_cmd="$gh_cmd --private"
    else
        gh_cmd="$gh_cmd --public"
    fi
    
    # Add description if provided
    if [ -n "$description" ]; then
        gh_cmd="$gh_cmd --description \"$description\""
    fi
    
    # Add source directory and push
    gh_cmd="$gh_cmd --source \"$project_dir\" --push"
    
    echo "   Repository: $repo_name"
    if [ -n "$org" ]; then
        echo "   Organization: $org"
    fi
    echo "   Visibility: $visibility"
    if [ -n "$description" ]; then
        echo "   Description: $description"
    fi
    echo ""
    
    # Check if repository already exists
    if [ -n "$org" ]; then
        local full_name="$org/$repo_name"
    else
        local current_user=$(gh api user -q .login)
        local full_name="$current_user/$repo_name"
    fi
    
    if gh repo view "$full_name" &> /dev/null; then
        echo "⚠️  Repository $full_name already exists on GitHub."
        echo "   Skipping creation but will attempt to push..."
        
        # Try to add remote and push
        cd "$project_dir"
        local remote_url=$(gh repo view "$full_name" --json sshUrl -q .sshUrl)
        
        if ! git remote get-url origin &> /dev/null; then
            git remote add origin "$remote_url"
        fi
        
        echo "   Pushing to existing repository..."
        if git push -u origin main 2>&1; then
            echo "✅ Successfully pushed to existing repository"
            local repo_url=$(gh repo view "$full_name" --json url -q .url)
            echo "   URL: $repo_url"
        else
            echo "⚠️  Failed to push. You may need to push manually:"
            echo "   cd $project_dir"
            echo "   git push -u origin main"
        fi
        
        return 0
    fi
    
    # Create the repository
    echo "   Creating repository on GitHub..."
    if eval $gh_cmd 2>&1; then
        echo "✅ GitHub repository created successfully"
        
        # Get repository URL
        local repo_url=$(gh repo view "$full_name" --json url -q .url)
        echo "   URL: $repo_url"
        
        # Configure repository settings
        configure_repo_settings "$full_name" "$project_dir"
        
        return 0
    else
        echo "❌ Failed to create GitHub repository"
        echo "   You can create it manually later with:"
        echo "   cd $project_dir"
        echo "   gh repo create $repo_name --source . --push"
        return 1
    fi
}

# Configure repository settings
configure_repo_settings() {
    local repo_full_name="$1"
    local project_dir="$2"
    
    echo ""
    echo "⚙️  Configuring repository settings..."
    
    # Extract topics from archetype metadata if available
    local topics=""
    if [ -f "$project_dir/.archetype-composition.json" ]; then
        topics=$(jq -r '.archetypes[].metadata.tags[]? // empty' "$project_dir/.archetype-composition.json" 2>/dev/null | sort -u | head -n 10 | paste -sd "," -)
    fi
    
    # Set default topics if none found
    if [ -z "$topics" ]; then
        topics="project-template,development-environment"
    fi
    
    # Enable features
    echo "   Enabling repository features..."
    
    # Enable issues
    gh repo edit "$repo_full_name" --enable-issues 2>/dev/null || true
    
    # Enable wiki
    gh repo edit "$repo_full_name" --enable-wiki 2>/dev/null || true
    
    # Enable projects
    gh repo edit "$repo_full_name" --enable-projects 2>/dev/null || true
    
    # Add topics
    if [ -n "$topics" ]; then
        echo "   Adding topics: $topics"
        # Convert comma-separated to array for gh CLI
        IFS=',' read -ra TOPIC_ARRAY <<< "$topics"
        for topic in "${TOPIC_ARRAY[@]}"; do
            gh repo edit "$repo_full_name" --add-topic "$topic" 2>/dev/null || true
        done
    fi
    
    # Set default branch to main (should already be main from git init)
    gh repo edit "$repo_full_name" --default-branch main 2>/dev/null || true
    
    echo "✅ Repository settings configured"
}

# Push to GitHub (for existing local repo)
push_to_github() {
    local project_dir="$1"
    local repo_full_name="$2"
    
    echo ""
    echo "📤 Pushing to GitHub..."
    
    cd "$project_dir"
    
    # Get remote URL
    local remote_url=$(gh repo view "$repo_full_name" --json sshUrl -q .sshUrl 2>/dev/null)
    
    if [ -z "$remote_url" ]; then
        echo "❌ Could not get repository URL"
        return 1
    fi
    
    # Add remote if it doesn't exist
    if ! git remote get-url origin &> /dev/null; then
        git remote add origin "$remote_url"
    fi
    
    # Push
    echo "   Pushing to $repo_full_name..."
    if git push -u origin main 2>&1; then
        echo "✅ Successfully pushed to GitHub"
        local repo_url=$(gh repo view "$repo_full_name" --json url -q .url)
        echo "   URL: $repo_url"
        return 0
    else
        echo "❌ Failed to push to GitHub"
        return 1
    fi
}
