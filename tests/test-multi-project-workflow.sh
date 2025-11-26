#!/usr/bin/env bash
# Multi-project archetype & composite build/run matrix test
# Requires WSL or Git Bash environment due to path handling.
set -euo pipefail

# Environment validation: must run inside WSL for reliable path translation.
if [ ! -d /mnt ]; then
  echo "This workflow must be executed inside WSL (\"/mnt\" not found)." >&2
  echo "Run: wsl bash tests/test-multi-project-workflow.sh" >&2
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PARENT_WIN="$(cd "$ROOT_DIR/.." && pwd)"
TEST_ROOT_WIN="$PARENT_WIN/archetype-matrix-tests"

# Path conversion helper: Windows path -> WSL path if /mnt exists, else forward-slash path
convert_path() {
  win_path="$1"
  # Normalize backslashes to forward first
  if echo "$win_path" | grep -E '^[A-Za-z]:\\' >/dev/null 2>&1; then
    drive=$(echo "$win_path" | sed -E 's|^([A-Za-z]):\\.*|\1|' | tr 'A-Z' 'a-z')
    rest=$(echo "$win_path" | sed -E 's|^[A-Za-z]:\\(.*)|\1|' | sed 's|\\|/|g')
    echo "/mnt/$drive/$rest"
  else
    echo "$win_path"
  fi
}

mkdir -p "$TEST_ROOT_WIN"

# Global cleanup: remove any leftover containers/volumes from previous runs
echo "Cleaning up any leftover containers..."
docker ps -a --filter "label=com.docker.compose.project" --format '{{.Names}}' | grep -E 'monitoring|rag|api|composite' | xargs -r docker rm -f >/dev/null 2>&1 || true
docker volume ls --filter "dangling=true" -q | xargs -r docker volume rm >/dev/null 2>&1 || true

# Archetypes & composites discovered
ARCHETYPES=(
  base
  rag-project
  api-service
  monitoring
  agentic-workflows
)
COMPOSITES=(
  composite-rag-agents
  composite-api-monitoring
  composite-full-stack
)

# Composite mapping (what features to add if using base rag-project fallback)
# If composite creation fails directly we fallback to rag-project + features.
declare -A COMPOSITE_FEATURE_MAP=(
  [composite-rag-agents]="rag-project:agentic-workflows"
  [composite-api-monitoring]="api-service:monitoring"
  [composite-full-stack]="rag-project:agentic-workflows,monitoring"
)

RESULTS=()

create_and_test() {
  local name="$1"; shift
  local archetype="$1"; shift
  local features="$1"; shift
  local tools="$1"; shift

  local project_win="$TEST_ROOT_WIN/$name"
  local project_wsl="$(convert_path "$project_win")"

  echo ""
  echo "==== Creating $name (archetype=$archetype features=$features tools=$tools) ===="
  rm -rf "$project_win"

  local feature_arg=""
  [ -n "$features" ] && feature_arg="--add-features $features"
  local tool_arg=""
  [ -n "$tools" ] && tool_arg="--tools $tools"

  echo "[DEBUG] path=$project_wsl archetype=$archetype features=$features tools=$tools" >> /tmp/create-matrix-debug.log
  set +e
  create_output=$(bash "$ROOT_DIR/create-project.sh" --path "$project_wsl" --archetype "$archetype" $feature_arg $tool_arg --no-git --no-build 2>&1)
  create_status=$?
  echo "$create_output" > /tmp/create-${name}.log
  set -e
  if [ $create_status -ne 0 ]; then
    echo "[FAIL] create-project failed for $name"; echo "--- snippet ---"; echo "$create_output" | tail -n 12; echo "--------------"; RESULTS+=("$name|CREATE_FAIL") ; return 1
  fi

  if [ ! -f "$project_win/docker-compose.yml" ]; then
    echo "[SKIP] No docker-compose.yml for $name"; RESULTS+=("$name|NO_COMPOSE") ; return 0
  fi

  # Check if docker-compose has any services defined
  local service_count=$(grep -c "^  [a-z]" "$project_win/docker-compose.yml" || echo "0")
  if [ "$service_count" -eq 0 ]; then
    echo "[SKIP] No services in docker-compose for $name"; RESULTS+=("$name|NO_SERVICES") ; return 0
  fi

  # Set PROJECT_NAME for consistent container naming
  export PROJECT_NAME="$name"
  (cd "$project_win" && docker-compose up -d --build >/tmp/dc-${name}.log 2>&1 || {
      echo "[FAIL] docker-compose up failed for $name"; RESULTS+=("$name|DOCKER_FAIL"); return 1; })

  sleep 5
  local running_ct=$(docker ps --filter "name=${name}" --format '{{.Names}}' | wc -l | tr -d ' ')
  # Fallback by counting any container with project path prefix
  if [ "$running_ct" -eq 0 ]; then
    running_ct=$(docker ps --format '{{.Names}}' | grep -ci "${name}" || true)
  fi

  if [ "$running_ct" -gt 0 ]; then
    echo "[PASS] $name running ($running_ct containers)"
    RESULTS+=("$name|PASS")
  else
    echo "[FAIL] $name no containers running"
    RESULTS+=("$name|RUNNING_ZERO")
  fi

  (cd "$project_win" && docker-compose down -v >/dev/null 2>&1 || true)
}

# Test base & feature archetypes
limit_count=0
for a in "${ARCHETYPES[@]}"; do
  if [ -n "${MATRIX_LIMIT:-}" ] && [ $limit_count -ge $MATRIX_LIMIT ]; then break; fi
  tools=""
  case "$a" in
    rag-project) tools="fastapi,postgresql" ;;
    api-service) tools="fastapi" ;;
  esac
  # If feature-only (agentic-workflows) test composition with rag-project
  if [ "$a" = "agentic-workflows" ]; then
    create_and_test "agentic-workflows-composed" "rag-project" "agentic-workflows" "fastapi" || true
  else
    create_and_test "$a" "$a" "" "$tools" || true
  fi
  # monitoring standalone already included; also test as feature composition
  if [ "$a" = "monitoring" ]; then
    create_and_test "rag-with-monitoring" "rag-project" "monitoring" "fastapi" || true
  fi
  limit_count=$((limit_count+1))
done

# Test composite archetypes directly; fallback if fails
for c in "${COMPOSITES[@]}"; do
  if [ -n "${MATRIX_LIMIT:-}" ] && [ $limit_count -ge $MATRIX_LIMIT ]; then break; fi
  echo ""
  echo "==== Composite: $c ===="
  if ! create_and_test "$c" "$c" "" "fastapi"; then
    echo "[INFO] Attempting fallback composition for $c"
    map="${COMPOSITE_FEATURE_MAP[$c]}"
    if [ -n "$map" ]; then
      base="${map%%:*}"; feats="${map#*:}"
      create_and_test "${c}-fallback" "$base" "$feats" "fastapi" || true
    fi
  fi
  limit_count=$((limit_count+1))
done

# Summary
echo ""
echo "================ Summary ================"
printf "%s\n" "${RESULTS[@]}" | awk -F'|' '{printf "%-30s : %s\n", $1, $2}'

# Count passes and failures
pass_count=$(printf "%s\n" "${RESULTS[@]}" | grep -c "|PASS" || echo "0")
total_count=${#RESULTS[@]}
echo ""
echo "Results: $pass_count/$total_count passed"

# Exit non-zero if core archetypes failed (rag-project, api-service with features)
if printf "%s\n" "${RESULTS[@]}" | grep -E "^(rag-project|api-service|.*-composed|rag-with-)" | grep -qE "FAIL|RUNNING_ZERO"; then
  echo "Core archetype tests failed."; exit 1
fi

echo "Core archetype tests passed."
exit 0
