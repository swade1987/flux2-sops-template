# Usage

The following sections walks through the steps of creating different types of secrets.

## How do I create a generic secret?

[See here](generic-secret-creation.md).

## How can I encrypt a lot of secrets at once?

To encrypt secrets for all clusters run

```
make encrypt-all
```

This uses the `age` key defined in the [.sops.yaml](../.sops.yaml) file for each cluster.

## How can I decrypt a lot of secrets at once?

```
make decrypt-all
```

This uses the `age` key defined in the [.sops.yaml](../.sops.yaml) file for each cluster.

## How can I clean out my local directory?

To clean out local secrets for a single cluster run:

```
$ make clean-<env>
```

To clean out all local secrets run:

```
$ make clean
```
