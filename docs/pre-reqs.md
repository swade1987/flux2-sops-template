# Pre-requisites

## Pre-commit configured

Before working with the repository it is **mandatory** to execute the following command:

```
make initialise
```

The above command will install the `pre-commit` package and setup pre-commit checks for this repository.

## SOPS

sops is a way of encrypting files that supports YAML, JSON, ENV, INI and BINARY formats and encrypts with AWS KMS, GCP KMS, Azure Key Vault and PGP

At the time of writing this documentation, you explicitly require version 3.9.3.

To download SOPs simply execute the following command:

```
make init
```

## AWS CLI configured

As we are using KMS to encrypt our secrets you need to have your local AWS CLI configured correctly.

All IAM roles that are required to be assumed by this repository need be assumed by any user using this repository.

Once you have obtained credentials for your user you will need to perform the following steps

### 1. ~/.aws/credentials

You need to add your credentials for your user to `~/.aws/credentials` (see example below).

```
[users]
aws_access_key_id=XXXXXXXXX
aws_secret_access_key=XXXXXXXXX
```

### 2. ~/.aws/config

You need to add a profile for `users` to `~/.aws/config` (see example below).

```
[users]
region=eu-west-1
```

### 3. Export your profile

To use this repository you need to export the `users` profile locally (see command below).

```
export AWS_PROFILE=users
```
