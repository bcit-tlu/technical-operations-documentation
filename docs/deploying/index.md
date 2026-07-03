---
tags:
  - ci/cd pipeline
  - cdn
  - semantic-release
  - version
---
<!-- markdownlint-disable code-block-style -->
# Deploying an app

Apps are deployed to one of two environments: `latest` (staging), and `stable` (production). Deployments to `latest` are automatic when a PR is merged (merge commit) into `main`. Deployments to `stable` are made by manually merging the **chore:...** PR created by `release-please`. `release-please` is a lightweight version tracker that uses git tags and PR titles to determine a semantic version for releases.

The pipeline checks that the PR title is formatted correctly, builds and versions the app image, signs and pushes the image to GitHub's package registry, and then updates a Helm chart repository with the new version. If `cdn_enabled=true`, the pipeline also rewrites static asset URLs in the image to use a CDN, and uploads those assets to a CDN.

## 1. Checkout & Versioning

1. Source repo is checked out.
1. [`semantic-release`](https://semantic-release.gitbook.io/semantic-release/) inspects commits and determines if this is a formal release.
1. App version is computed:
    - Release :lucide-arrow-right: uses the `semantic-release` version.
    - Release candidate (RC) :lucide-arrow-right: generates a timestamp-based RC version.

## 2. Build Image

1. App image is built (not pushed).
1. Image is tagged with:
    - the computed version
    - stable (for releases)
    - latest

??? info "**3. Optional: CDN Rewrite + Upload**"

    If `cdn_enabled=true`:

    **3a. Validate CDN configuration**

    - Ensures required CDN variables and Azure token exist.

    **3b. Extract static files**

    - Creates a temporary container from the built image.
    - Copies `/usr/share/nginx/html` into `site/`.

    **3c. Compute CDN asset version**

    - Collects files matching configured extensions (css, js, png, etc.).
    - Hashes all matching files :lucide-arrow-right: produces a CDN asset version.
    - This version becomes part of the CDN path.

    **3d. Rewrite HTML asset URLs**

    - All `<img>`, `<script>`, `<link>` references that match the extensions are rewritten to:

        `<CDN_BASE_URL>/cdn/bcit-ltc/<app>/<asset_version>/<assets>`

    **3e. Commit rewritten files back into the container**

    - Copies rewritten files back into the runtime image.
    - Commits the container :lucide-arrow-right: final app image (with CDN references baked in).

    **3f. Upload assets to CDN**

    - Checks asset hash against the CDN folders to determine if asset version already exists.

    - If yes :lucide-arrow-right: skip upload.
    - If no :lucide-arrow-right: upload assets.

## 4. Push & Sign

- All computed image tags are pushed to GHCR.
- The workflow resolves their digests.
- Each unique digest is signed using cosign.

## 5. Helm Chart Update

- A GitHub App token is generated.
- A remote workflow in the helm-charts repo is triggered to bump the chart version to match the new image version.

## Visual of the workflow

``` mermaid
flowchart TD
  A[Commit] --> B[Checkout Repo]
  B --> C[Run semantic-release]
  C --> D[Compute Version]
  D --> E[Build Container Image]
  E --> F[Generate Tags & Metadata]
  F --> G{CDN Enabled?}

  G -->|No| X1[Skip CDN Steps]

  subgraph CDNENABLED[CDN Enabled]
    direction TB
    H1[Validate CDN Config]
    H1 --> I1[Extract Static Files → site/]
    I1 --> J1[Compute CDN Asset Version]
    J1 --> K1[Rewrite HTML Asset URLs]
    K1 --> L1[Commit Rewritten Files Into Image]
    L1 --> M1{Assets Already On CDN?}

    M1 -->|Yes| N1[Skip CDN Upload]
    M1 -->|No| O1[Upload Assets to CDN]

    %% Both Yes/No outcomes converge to Normalize Tags
    N1 --> P1[Normalize Image Tags]
    O1 --> P1
  end

  %% Connect the decision to the subgraph start
  G -->|Yes| H1

  %% --- Unified downstream path for BOTH branches ---
  X1 --> Q[Push Image Tags]
  P1 --> Q

  Q --> R[Sign Digests with Cosign]
  R --> S[Trigger Helm Chart Bump]
  S --> END[End]

```
