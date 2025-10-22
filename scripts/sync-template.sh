#!/bin/bash

###############################################################################
# Template Sync Script
# Quick wrapper to sync project to latest template version
###############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Call the main update manager
"$SCRIPT_DIR/manage-template-updates.sh" sync "$@"