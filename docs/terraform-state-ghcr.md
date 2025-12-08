# Persist Terraform state in GitHub via GHCR (OCI artifact)

## Context and goal
- We need to persist Terraform state entirely within GitHub infra.
- Do NOT commit plaintext state to git.
- Store an encrypted terraform.tfstate as an OCI artifact in GHCR, one tag per environment/branch.
- CI restores the encrypted state, decrypts, runs Terraform, re-encrypts, and pushes the new state.

## Key decisions
- Backend: local (default). No backend block in Terraform.
- Storage: GHCR (ghcr.io) using oras to push/pull a single encrypted file.
- Encryption: AES-256-CBC with a repo secret STATE_PASSPHRASE.
- Concurrency: Single run per branch/env to reduce corruption risk (no Terraform locking).
- Scope: CI-only applies to avoid state forks.

## Repo requirements
- Secrets:
  - STATE_PASSPHRASE: long random string (≥32 chars).
- Permissions:
  - packages: write (push to GHCR)
  - contents: read (checkout)
- Runners: ubuntu-latest
- Terraform version: 1.9.x (adjust as needed)

## Directory and ignore rules
- Terraform lives at repo root or ./terraform (see "Customize working directory").
- Add to .gitignore:
  - .terraform/
  - .terraform.lock.hcl
  - terraform.tfstate
  - terraform.tfstate.backup
  - tfplan
  - .tfstate_store/

## Naming
- OCI repository: ghcr.io/<OWNER>/<REPO>/terraform-state
- Tag per environment/branch:
  - main -> tag: main
  - feature branches -> tag: <sanitized-branch-name>
- Single file inside artifact: terraform.tfstate.enc

## Workflow file
Place at .github/workflows/terraform.yml

```yaml
name: Terraform via GHCR-backed state (DEMO ONLY)

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  packages: write

concurrency:
  group: terraform-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: false

env:
  # OCI ref for state. Example: ghcr.io/owner/repo/terraform-state
  STATE_IMAGE: ghcr.io/${{ github.repository }}/terraform-state
  # Tag ties state to a branch/environment. Use 'main' or sanitized branch name.
  STATE_TAG: ${{ github.ref_name }}
  # Encrypted blob name inside the OCI artifact
  STATE_BLOB: terraform.tfstate.enc
  TF_VERSION: 1.9.5

jobs:
  terraform:
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash
        # Set this if your TF code is in a subfolder:
        working-directory: terraform

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Install oras
        run: |
          set -euxo pipefail
          ORAS_VERSION=1.2.0
          curl -sL "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz" \
            | sudo tar -xz -C /usr/local/bin oras
          oras version

      # Pull existing encrypted state from GHCR (if exists)
      - name: Pull encrypted state from GHCR (if any)
        id: pull_state
        env:
          REF: ${{ env.STATE_IMAGE }}:${{ env.STATE_TAG }}
        run: |
          set -e
          mkdir -p .tfstate_store
          if oras manifest fetch "$REF" >/dev/null 2>&1; then
            oras pull "$REF" -o .tfstate_store
          else
            echo "no_state=true" >> "$GITHUB_OUTPUT"
          fi

      - name: Decrypt state if present
        if: steps.pull_state.outputs.no_state != 'true' && hashFiles('.tfstate_store/${{ env.STATE_BLOB }}') != ''
        env:
          STATE_PASSPHRASE: ${{ secrets.STATE_PASSPHRASE }}
        run: |
          openssl enc -d -aes-256-cbc -md sha256 \
            -in ".tfstate_store/${STATE_BLOB}" \
            -out terraform.tfstate \
            -pass pass:"${STATE_PASSPHRASE}"

      - name: Terraform init
        run: terraform init -input=false

      - name: Terraform validate
        run: terraform validate

      - name: Terraform plan
        run: terraform plan -input=false -out=tfplan

      - name: Terraform apply (main only)
        if: github.ref == 'refs/heads/main'
        run: terraform apply -input=false -auto-approve tfplan

      - name: Encrypt state (if changed/exists)
        env:
          STATE_PASSPHRASE: ${{ secrets.STATE_PASSPHRASE }}
        run: |
          mkdir -p .tfstate_store
          if [ -s terraform.tfstate ]; then
            openssl enc -e -aes-256-cbc -md sha256 \
              -in terraform.tfstate \
              -out ".tfstate_store/${STATE_BLOB}" \
              -pass pass:"${STATE_PASSPHRASE}"
          fi

      - name: Login to GHCR
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          echo "${GITHUB_TOKEN}" | oras login ghcr.io -u "${GITHUB_ACTOR}" --password-stdin

      - name: Push encrypted state to GHCR
        if: hashFiles('.tfstate_store/${{ env.STATE_BLOB }}') != ''
        env:
          REF: ${{ env.STATE_IMAGE }}:${{ env.STATE_TAG }}
        run: |
          oras push "$REF" \
            --artifact-type application/vnd.terraform.state.encrypted \
            ".tfstate_store/${STATE_BLOB}:application/octet-stream"
```

## Customize working directory
- If Terraform files are under terraform/, uncomment defaults.run.working-directory and ensure .gitignore paths include terraform equivalents or keep them generic.

## Multiple environments
- Use distinct tags:
  - STATE_TAG: dev, stg, prod
- Option A: Matrix strategy:
```yaml
strategy:
  matrix:
    env: [dev, stg]
env:
  STATE_TAG: ${{ matrix.env }}
```
- Option B: Different workflows per environment with fixed STATE_TAG.

## Manual destroy workflow (optional, guarded)
- Add a separate workflow with on: workflow_dispatch and an environment that requires approval. Run terraform destroy and then push updated (empty) state. Keep the same pull/decrypt before destroy.

## Locking and concurrency
- There is no real Terraform state lock with this approach. Keep the concurrency group as configured to prevent simultaneous runs per ref/tag.

## Local usage (discouraged)
- CI owns the state. If you must run locally:
  - Use a Personal Access Token with read:packages to oras login ghcr.io.
  - Pull the current state tag, decrypt with STATE_PASSPHRASE, run TF, then encrypt and push via oras with write:packages.
  - Risk: state forks if CI and local run concurrently.

## Security notes
- The state is encrypted before leaving the runner.
- Never echo or log the passphrase.
- Keep STATE_PASSPHRASE rotated periodically if needed.
- Consider adding a pre-step to fail if STATE_PASSPHRASE is missing.

## Troubleshooting
- Permission denied pushing to GHCR:
  - Ensure workflow has packages: write.
  - Repo must allow GitHub Packages for this project.
- oras not found:
  - Check install step; ensure /usr/local/bin is on PATH.
- "no_state=true" on first run:
  - Expected. State will be created after the first apply.

## Quick setup

Run the setup script to generate a passphrase and get setup instructions:

```bash
./terraform/setup-ghcr-state.sh
```

This script will:
- Generate a secure random passphrase
- Display setup instructions for GitHub secrets and permissions
- Show you the GHCR repository path for your state

## Reference variables for Copilot
- STATE_IMAGE: ghcr.io/${{ github.repository }}/terraform-state
- STATE_TAG: ${{ github.ref_name }} or fixed names per env
- STATE_BLOB: terraform.tfstate.enc
- Secrets: STATE_PASSPHRASE
- Permissions: packages: write, contents: read
- Tools: oras, openssl, terraform