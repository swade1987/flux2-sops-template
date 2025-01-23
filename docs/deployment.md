# Deployment mechanism

As you are probably aware we use the GitOps controller [Flux](https://github.com/fluxcd/flux2) to sync workloads into our clusters. This repository is no different in this regard.

Flux has in-built support for [Mozilla](https://github.com/getsops/sops) for more information see [here](https://toolkit.fluxcd.io/guides/mozilla-sops/).

## Technical overview

Each cluster has been configured with a KMS key specifically for SOPs encryption. For more information on KMS, see [here](https://aws.amazon.com/kms/).

Additionally, each cluster has an IAM role `flux-secrets` which has the ability to encrypt and decrypt using this key.

### Flux configuration

When configuring our Flux instance we specify an annotation on the pod to allow it to assume the role `flux-secrets`.

```
apiVersion: kustomize.config.k8s.io/v1
kind: Kustomization
resources:
  - gotk-components.yaml
  - gotk-sync.yaml
patches:
  # Patch kustomize-controller deployment with annotation to allow assume role to import secrets
  - patch: |
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: kustomize-controller
        namespace: flux-system
      spec:
        template:
          metadata:
            annotations:
              iam.amazonaws.com/role: flux-secrets-assume-us-west-2
    target:
      kind: Deployment
      name: kustomize-controller
      namespace: flux-system
      apiVersion: kustomize.config.k8s.io/v1
```

Finally, we have to configure flux to be aware this repository leverages SOPs (see below)

```
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: k8s-secrets
  namespace: flux-repos
spec:
  interval: 10m0s
  sourceRef:
    kind: GitRepository
    name: k8s-secrets
  prune: true
  decryption:
    provider: sops
```

### Flux reconciliation

When the flux instance reconciles the repository it looks at the directory its secrets are stored within (e.g. `secrets/platform-engineering-sbx`).

It then looks in the [`.sops.yaml`](../.sops.yaml) file for a path that matches the directory it's reconciling (see below)

```
  - path_regex: secrets/us-west-2-platform-engineering-sbx
    encrypted_regex: "^(data|stringData)$"
    shamir_threshold: 1
    key_groups:
      - kms:
          - arn: arn:aws:kms:us-west-2:<redacted>:key/<redacted>
            role: arn:aws:iam::<redacted>:role/flux-secrets
```

It then uses the KMS key arn (listed above as `arn`) to decrypt the encrypted portion of the secrets within that directory.

You will notice the `role` key in the block above needs to be the ARN of the role that our flux instance assumes.
