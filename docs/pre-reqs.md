# Pre-requisites

## Pre-commit configured

Before working with the repository it is **mandatory** to execute the following command:

```
make initialise
```

The above command will install the `pre-commit` package and setup pre-commit checks for this repository.

## SOPS & AGE

sops is a way of encrypting files that supports YAML, JSON, ENV, INI and BINARY formats and encrypts with AWS KMS, GCP KMS, Azure Key Vault and PGP

At the time of writing this documentation, you explicitly require version 3.9.3.

To download SOPs simply execute the following command:

```
make init
```
