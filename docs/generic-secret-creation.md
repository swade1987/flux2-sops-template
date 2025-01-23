# How to create a generic secret

## 1. Create an env file.

An example can be found in [example/test.env](../example/test.env).

## 2. Generate the generic secret.

Then create a generic secret using the following command:

```
kubectl create secret generic test-secret \
--namespace=default \
--from-env-file=example/test.env \
--dry-run=client -o yaml > secrets/<platform>/dev/default-test-secret.yaml
```

The filename structure is extremely important see below:

```
kubectl create secret generic <secret name> \
--namespace=<namespace> \
--from-env-file=<env file> \
--dry-run -o yaml > <namespace>-<secret name>.yaml
```

## 3. Locate the file in the appropriate directory.

Place this file in `secrets/<env>`

## 4. Encrypt the secret.

To encrypt secrets for an cluster (e.g. dev) simply execute `make encrypt-<directory>`.

## 5. Commit changes.

This part is self-explanatory.
