# Implementation Checklist: Git + GitHub Integration

**Goal:** Enable single-command project creation with independent Git repositories and optional GitHub integration.

---

## Phase 1: Core Git Integration ✅

- [ ] **1.1** Update `create-project.sh` to initialize Git automatically
  - Remove `--git` flag requirement (make it default)
  - Add `--no-git` flag for opt-out
  - Initialize Git after project creation

- [ ] **1.2** Generate smart initial commit message
  - Include archetype names and versions
  - List services and ports
  - Add template version

- [ ] **1.3** Generate comprehensive `.gitignore`
  - Base template patterns
  - Archetype-specific patterns
  - Environment-specific exclusions

---

## Phase 2: GitHub CLI Integration 🔄

- [ ] **2.1** Create `scripts/github-repo-creator.sh`
  ```bash
  create_github_repo() {
      local project_name=$1
      local github_org=$2
      local visibility=$3
      local description=$4
      # Implementation
  }
  ```

- [ ] **2.2** Add CLI flags to `create-project.sh`
  - `--github` - Create GitHub repository
  - `--github-org ORG` - Organization name
  - `--private` / `--public` - Visibility
  - `--description TEXT` - Repository description
  - `--no-push` - Skip initial push

- [ ] **2.3** Implement prerequisite checks
  - Check if `gh` CLI installed
  - Check if authenticated
  - Provide helpful error messages

- [ ] **2.4** Implement GitHub repository creation
  - Call `gh repo create`
  - Handle organization vs personal repos
  - Set visibility (public/private)
  - Add repository description

- [ ] **2.5** Configure repository settings
  - Enable issues
  - Enable projects
  - Disable wiki
  - Set merge options
  - Add topics/tags

- [ ] **2.6** Push initial commit
  - Connect local repo to remote
  - Push main branch
  - Set upstream tracking

---

## Phase 3: Error Handling & UX 🔄

- [ ] **3.1** Graceful degradation
  - Continue if GitHub CLI not found
  - Continue if not authenticated
  - Provide manual instructions

- [ ] **3.2** Conflict resolution
  - Check if repository already exists
  - Offer to use different name
  - Offer to delete existing

- [ ] **3.3** Dry run support
  - Show what will be created
  - Preview GitHub repository details
  - Ask for confirmation

- [ ] **3.4** Progress indicators
  - Show progress for each step
  - Estimate completion time
  - Display final summary

---

## Phase 4: Documentation & Templates 📝

- [x] **4.1** Create `docs/GIT_GITHUB_INTEGRATION.md`
  - Complete usage guide
  - Examples for all scenarios
  - Troubleshooting section

- [x] **4.2** Create `SINGLE_COMMAND_PROJECT_CREATION.md`
  - Quick start guide
  - Command cheat sheet
  - Comparison with traditional approach

- [ ] **4.3** Update main `README.md`
  - Add Git/GitHub integration section
  - Show example commands
  - Link to detailed guides

- [ ] **4.4** Generate project-specific README
  - Auto-generate from archetype metadata
  - Include quick start instructions
  - Add link to template

- [ ] **4.5** Generate `COMPOSITION.md`
  - Document multi-archetype setup
  - List all services and ports
  - Provide architecture diagram

---

## Phase 5: CI/CD Templates 🔄

- [ ] **5.1** Create `.github/workflows/ci.yml` template
  - Python testing
  - Linting and type checking
  - Docker builds

- [ ] **5.2** Create `.github/workflows/docker-build.yml` template
  - Build Docker images
  - Test integration
  - Optional: Push to registry

- [ ] **5.3** Make workflows archetype-aware
  - Different workflows for different archetypes
  - Conditional steps based on services

---

## Phase 6: Testing & Validation ✅

- [ ] **6.1** Test local Git initialization
  ```bash
  ./create-project.sh --name test1 --archetype rag-project
  # Verify: .git/ directory exists
  # Verify: Initial commit made
  ```

- [ ] **6.2** Test GitHub personal repo creation
  ```bash
  ./create-project.sh --name test2 --archetype rag-project --github
  # Verify: GitHub repo created
  # Verify: Commit pushed
  ```

- [ ] **6.3** Test GitHub organization repo creation
  ```bash
  ./create-project.sh --name test3 --archetype rag-project --github --github-org myorg --private
  # Verify: Org repo created
  # Verify: Private visibility
  ```

- [ ] **6.4** Test multi-archetype with GitHub
  ```bash
  ./create-project.sh --name test4 --archetype rag-project --add-features agentic-workflows --github
  # Verify: Commit message includes both archetypes
  # Verify: Repository topics include tags from both
  ```

- [ ] **6.5** Test error handling
  - Without GitHub CLI installed
  - Without authentication
  - With existing repository name
  - With network issues

- [ ] **6.6** Test dry run
  ```bash
  ./create-project.sh --name test5 --archetype rag-project --github --dry-run
  # Verify: Shows preview
  # Verify: Doesn't create anything
  ```

---

## Implementation Code Snippets

### 1. Auto Git Initialization (create-project.sh)

```bash
# After project creation and file copying

initialize_git_repository() {
    local project_path=$1
    local project_name=$2
    local archetypes=$3

    print_header "Initializing Git Repository"

    cd "$project_path"

    # Initialize Git
    git init
    print_success "Git initialized"

    # Generate commit message
    local commit_msg=$(generate_commit_message "$project_name" "$archetypes")

    # Initial commit
    git add .
    git commit -m "$commit_msg"
    print_success "Initial commit created"

    cd - > /dev/null
}

generate_commit_message() {
    local project_name=$1
    local archetypes=$2

    cat << EOF
Initial commit: $project_name

Archetypes:
$(echo "$archetypes" | while read arch; do
    version=$(get_archetype_version "$arch")
    echo "- $arch ($version)"
done)

Services:
$(list_services_from_archetypes "$archetypes")

Generated by dev-environment-template $(get_template_version)
EOF
}
```

### 2. GitHub Repository Creator (scripts/github-repo-creator.sh)

```bash
#!/bin/bash

create_github_repo() {
    local project_name=$1
    local github_org=$2
    local visibility=$3  # public or private
    local description=$4
    local project_path=$5

    print_header "Creating GitHub Repository"

    # Check prerequisites
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not found"
        print_info "Install: https://cli.github.com/"
        print_info "Or create repository manually later:"
        echo "  cd $project_name"
        echo "  gh repo create"
        return 1
    fi

    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated"
        print_info "Run: gh auth login"
        return 1
    fi

    cd "$project_path"

    # Create repository
    local repo_name="$project_name"
    if [ -n "$github_org" ]; then
        repo_name="$github_org/$project_name"
    fi

    print_info "Creating repository: $repo_name"

    gh repo create "$repo_name" \
        --$visibility \
        --description "$description" \
        --source=. \
        --remote=origin \
        --push

    if [ $? -eq 0 ]; then
        print_success "GitHub repository created!"

        # Get repository URL
        local repo_url=$(gh repo view --json url -q .url)
        print_info "Repository URL: $repo_url"

        # Configure repository settings
        configure_repo_settings "$repo_name"

        return 0
    else
        print_error "Failed to create GitHub repository"
        return 1
    fi

    cd - > /dev/null
}

configure_repo_settings() {
    local repo_name=$1

    print_info "Configuring repository settings..."

    # Enable issues and projects
    gh repo edit "$repo_name" \
        --enable-issues \
        --enable-projects \
        --delete-branch-on-merge

    # Add topics (from archetype metadata)
    # gh repo edit "$repo_name" --add-topic rag --add-topic ai

    print_success "Repository configured"
}
```

### 3. Updated create-project.sh Main Flow

```bash
main() {
    parse_args "$@"

    # Validate
    validate_project_name "$PROJECT_NAME"

    # Load archetypes
    load_archetypes "$BASE_ARCHETYPE" "${FEATURE_ARCHETYPES[@]}"

    # Resolve conflicts
    resolve_conflicts

    # Create project
    create_project_structure "$PROJECT_NAME"
    copy_archetype_files "$BASE_ARCHETYPE" "${FEATURE_ARCHETYPES[@]}"
    merge_configurations
    generate_documentation

    # Initialize Git (automatic, unless --no-git)
    if [ "$SKIP_GIT" != true ]; then
        initialize_git_repository "$PROJECT_PATH" "$PROJECT_NAME" "$ALL_ARCHETYPES"
    fi

    # Create GitHub repository (if requested)
    if [ "$CREATE_GITHUB_REPO" = true ]; then
        source "$SCRIPT_DIR/scripts/github-repo-creator.sh"

        create_github_repo \
            "$PROJECT_NAME" \
            "$GITHUB_ORG" \
            "$GITHUB_VISIBILITY" \
            "$GITHUB_DESCRIPTION" \
            "$PROJECT_PATH"
    fi

    # Display success message
    display_success_summary
}
```

---

## Quick Start (After Implementation)

```bash
# 1. Create project locally
./create-project.sh --name my-rag-system --archetype rag-project

# 2. Create project with GitHub
./create-project.sh --name my-rag-system --archetype rag-project --github

# 3. Create multi-archetype with GitHub in organization
./create-project.sh --name customer-search \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring \
  --github \
  --github-org acme-corp \
  --private
```

---

## Success Criteria

- [ ] **One command** creates fully functional project
- [ ] **Git initialized** automatically in every project
- [ ] **GitHub repository** created optionally with `--github`
- [ ] **Complete independence** - no link to template repo
- [ ] **Smart commit messages** - include archetype metadata
- [ ] **CI/CD workflows** - auto-generated and pushed
- [ ] **Documentation** - comprehensive and auto-generated
- [ ] **Error handling** - graceful with helpful messages
- [ ] **Team ready** - collaborators can clone immediately

---

## Timeline

- **Week 1:** Phase 1 & 2 (Core Git + GitHub CLI)
- **Week 2:** Phase 3 & 4 (Error handling + Documentation)
- **Week 3:** Phase 5 & 6 (CI/CD + Testing)

**Total:** 3 weeks to production-ready

---

## Next Steps

1. ✅ Review design documents
2. ⏳ Implement Phase 1 (Git integration)
3. ⏳ Implement Phase 2 (GitHub CLI)
4. ⏳ Test with real scenarios
5. ⏳ Document and release

**Start with:** `scripts/github-repo-creator.sh` implementation
