# Security Policy

## Supported versions

This template ships one rolling `latest` semantic-release version; there's no long-term-support branch to track. Fixes land on `main` and are published as the next tagged release.

## Reporting a vulnerability

Please report security issues privately rather than opening a public GitHub issue: use [GitHub's private vulnerability reporting](https://github.com/swade1987/flux2-sops-template/security/advisories/new) for this repository (Security tab → Report a vulnerability).

Include what you'd include in any good bug report: the affected version or commit, what you found, and how to reproduce it. We'll acknowledge new reports within 5 business days and aim to have a fix or mitigation plan within 30 days, depending on severity.

## Scope

This is a GitOps repository template for managing SOPS-encrypted secrets with Flux - the CI check that scans for accidentally-unencrypted secrets, the `bin/` encrypt/decrypt/check scripts, and the Terraform under `docs/terraform/` are in scope. `example/age-key.txt` is a deliberately public, throwaway demo keypair for trying the workflow (paired with `example/test.env`) - it never protects real content, so reporting it as "leaked" isn't a valid finding.
