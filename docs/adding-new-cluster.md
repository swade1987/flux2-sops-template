# Adding a new environment

The following page describes the steps required to add a new cluster to this repository.

## 1. Adding a new directory within our .sops.yaml file

The majority of the configuration is within the [`.sops.yaml`](../.sops.yaml) file.

For you to add a new cluster it is recommended you copy a `path_regex` block that is already existing.

The following changes are required within the [`.sops.yaml`](../.sops.yaml) file.

### Change location

Change the location to look within to be `secrets/<new directory>`.

The directory can should follow the naming convention `<region>-<team>-<environment>` e.g. `us-west-2-platform-engineering-prd`.

### Configure the correct IAM role arn

The `arn` under `kms` needs to be the arn for the specific KMS key used for encryption/decryption.
