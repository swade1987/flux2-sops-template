# Production Usage with AWS KMS

While `age` is a great tool for an example use-case, AWS KMS is recommended for production environments for several key reasons:

1. **Cluster-Specific Keys**: Each cluster can have its own dedicated KMS key, ensuring strict separation of secrets between environments
2. **Access Control**: Fine-grained IAM policies can restrict who can encrypt/decrypt secrets for specific clusters
3. **Audit Trail**: AWS CloudTrail provides detailed logs of all KMS key usage
4. **Key Rotation**: Automatic key rotation can be enabled for additional security
5. **High Availability**: AWS KMS is a managed service with built-in redundancy

## `.sops.yaml` changes

For production environments using KMS, your `.sops.yaml` should be structured to use different KMS keys for different clusters/environments. Here's an example configuration:

```yaml
creation_rules:
  - path_regex: secrets/us-west-2-platform-engineering-sbx
    encrypted_regex: "^(data|stringData)$"
    shamir_threshold: 1
    key_groups:
      - kms:
          - arn: arn:aws:kms:us-west-2:{ACCOUNT_ID}:key/{KMS_KEY}
            role: arn:aws:iam::{ACCOUNT_ID}:role/flux-secrets-us-west-2
```

## Flux Deployment Changes

### 1. IAM Setup

Create the necessary IAM roles and policies:

1. `flux-secrets` for uses to assume, terraform code found [here](terraform/flux-secrets.tf)
2. `flux-secrets-assume` for the flux to assume, terraform code found [here](terraform/flux-secrets-assume.tf)

### 2. Annotate the kustomize-controller service account with the role ARN

```
kubectl -n flux-system annotate serviceaccount kustomize-controller \
--field-manager=flux-client-side-apply \
eks.amazonaws.com/role-arn='arn:aws:iam::<ACCOUNT_ID>:role/flux-secrets-assume-us-west-2
```

### 3. Restart kustomize-controller for the binding to take effect:

```
kubectl -n flux-system rollout restart deployment/kustomize-controller
```

### 4. Flux Kustomization Changes

Update your Flux kustomization to not specify the decryption secret as Flux will obtain the KMS key from the IAM role:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: secrets
  namespace: flux-system
spec:
  interval: 1m0s
  path: ./secrets/us-west-2-production
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  decryption:
    provider: sops
```

## Best Practices

1. **Key Rotation**: Enable automatic key rotation for your KMS keys
2. **IAM Policies**: Use the principle of least privilege when creating IAM policies
3. **Monitoring**: Set up CloudWatch alerts for suspicious KMS key usage
4. **Backup**: Ensure your KMS key policies allow for disaster recovery scenarios
5. **Documentation**: Maintain documentation of which keys are used for which clusters

## Security Considerations

1. **Access Control**:
    - Restrict KMS key access to specific IAM roles/users
    - Use separate keys for different environments
    - Implement emergency access procedures

2. **Monitoring**:
    - Enable AWS CloudTrail for all KMS operations
    - Set up alerts for unauthorized access attempts
    - Monitor key usage patterns

3. **Compliance**:
    - Document key usage for audit purposes
    - Maintain an inventory of encrypted resources
    - Regular review of access patterns and permissions
