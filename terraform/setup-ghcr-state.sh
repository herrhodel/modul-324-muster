#!/bin/bash
# Setup script for GHCR Terraform state management
set -euo pipefail

echo "🚀 Setting up GHCR Terraform state management..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: This script must be run from within a git repository"
    exit 1
fi

# Get repository information
REPO_OWNER=$(git remote get-url origin | sed -n 's/.*github.com[:/]\([^/]*\)\/\([^/]*\)\.git/\1/p')
REPO_NAME=$(git remote get-url origin | sed -n 's/.*github.com[:/]\([^/]*\)\/\([^/]*\)\.git/\2/p')

if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "❌ Error: Could not determine repository owner/name from git remote"
    echo "   Make sure you have a GitHub remote configured"
    exit 1
fi

echo "📍 Repository: ${REPO_OWNER}/${REPO_NAME}"

# Generate a random passphrase
PASSPHRASE=$(openssl rand -base64 48)

echo ""
echo "🔐 Generated STATE_PASSPHRASE: ${PASSPHRASE}"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Add the following secret to your GitHub repository:"
echo "   Go to: https://github.com/${REPO_OWNER}/${REPO_NAME}/settings/secrets/actions"
echo ""
echo "   Secret name: STATE_PASSPHRASE"
echo "   Secret value: ${PASSPHRASE}"
echo ""
echo "2. Ensure GitHub Actions have 'packages: write' permission:"
echo "   Go to: https://github.com/${REPO_OWNER}/${REPO_NAME}/settings/actions"
echo "   Set 'Workflow permissions' to 'Read and write permissions'"
echo ""
echo "3. Enable GitHub Packages (if not already enabled):"
echo "   Go to: https://github.com/${REPO_OWNER}/${REPO_NAME}/settings"
echo "   Under 'Features', ensure 'Packages' is enabled"
echo ""
echo "4. Your Terraform state will be stored at:"
echo "   ghcr.io/${REPO_OWNER}/${REPO_NAME}/terraform-state"
echo ""
echo "✅ Setup complete! You can now use the GHCR-backed Terraform workflows."
echo ""
echo "💡 Tip: Save the passphrase securely - you'll need it for local Terraform operations"
echo "    (though CI-only usage is recommended)"