# Usage

The following sections walks through the steps of creating different types of secrets.

## How do I create a generic secret?

[See here](generic-secret-creation.md).

## How can I encrypt a lot of secrets at once?

To encrypt secrets for all clusters run

```
make encrypt-all
```

## How can I decrypt a lot of secrets at once?

```
make decrypt-all
```

## How can I clean out my local directory?

To clean out local secrets for a single cluster run:

```
$ make clean-<env>
```

To clean out all local secrets run:

```
$ make clean
```
