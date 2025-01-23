[![kustomize-checks](https://github.com/swade1987/flux2-kustomize-template/actions/workflows/kustomize-checks.yaml/badge.svg)](https://github.com/swade1987/flux2-kustomize-template/actions/workflows/kustomize-checks.yaml)

# Flux SOPs Template

This is an opinionated template to use as a starting point for managing secrets with Flux and SOPs.

## TL;DR

**Problem:** "I can manage all my Kubernetes config in git, except Secrets."

**Solution:** Encrypt your Secret using a KMS key for the cluster with SOPs.

For more information on SOPs see [here](https://github.com/getsops/sops).

## Features

- Leverages [SOPs](https://github.com/getsops/sops) for encryption/decryption
- Leverages [age](https://github.com/FiloSottile/age) for file encryption/decryption
- Commits must meet [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
    - Automated with GitHub Actions ([commit-lint](https://github.com/conventional-changelog/commitlint/#what-is-commitlint))
- Pull Request titles must meet [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
    - Automated with GitHub Actions ([pr-lint](https://github.com/amannn/action-semantic-pull-request))
- Commits must be signed with [Developer Certificate of Origin (DCO)](https://developercertificate.org/)
    - Automated with GitHub App ([DCO](https://github.com/apps/dco))

## Directory Structure

```
secrets
├── us-west-2-platform-engineering-prd
└── us-west-2-platform-engineering-sbx
```

## Getting started

Before working with the repository it is **mandatory** to execute the following command:

```
make initialise
```

The above command will install the `pre-commit` package and setup pre-commit checks for this repository including [conventional-pre-commit](https://github.com/compilerla/conventional-pre-commit) to make sure your commits match the conventional commit convention.

As well as this it validates that unencrypted secrets are not committed to the repository.

## Workflow

For an example of how to add a secret to this repository see [here](docs/usage.md).

## How does this repository work with Flux?

For more information on how this repository works with Flux, please read [here](docs/flux-integration.md).

## Contributing to the repository

To contribute, please read the [contribution guidelines](CONTRIBUTING.md). You may also [report an issue](https://github.com/swade1987/flux2-sops-template/issues/new/choose).
