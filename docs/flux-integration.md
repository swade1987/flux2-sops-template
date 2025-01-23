# Deployment mechanism

As you are probably aware we use the GitOps controller [Flux](https://github.com/fluxcd/flux2) to sync workloads into our clusters. This repository is no different in this regard.

Flux has in-built support for [SOPs](https://github.com/getsops/sops) for more information see [here](https://toolkit.fluxcd.io/guides/mozilla-sops/).

## Technical overview

Create a secret with the age private key, the key name must end with .agekey to be detected as an age key:

```
cat example/age-key.txt |
kubectl create secret generic sops-age \
--namespace=flux-system \
--from-file=age.agekey=/dev/stdin
```

Finally set the decryption secret in the Flux Kustomization to `sops-age`.

```
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: k8s-secrets
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  secretRef:
    name: automator-ssh-keypair
  timeout: 60s
  url: ssh://git@github.com/swade1987/flux2-sops-template
---

apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: k8s-secrets
  namespace: flux-system
spec:
  interval: 10m0s
  sourceRef:
    kind: GitRepository
    name: k8s-secrets
  prune: true
  # THIS IS THE IMPORTANT SECTION BELOW
  decryption:
    provider: sops
    secretRef:
      name: sops-age
```
