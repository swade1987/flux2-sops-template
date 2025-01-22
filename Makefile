SHELL = /bin/sh
UNAME := $(shell uname -s)
SOPS_VERSION = v3.9.3
YQ_VERSION = v4.44.3

initialise: init
	pre-commit --version || brew install pre-commit
	ag -- version || brew install the_silver_searcher
	pre-commit --version || brew install pre-commit
	pre-commit install --install-hooks
	pre-commit run -a

init:
ifeq ($(UNAME),Darwin)
	wget --no-check-certificate https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.darwin
	wget --no-check-certificate https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_darwin_amd64
	sudo install -m 755 sops-${SOPS_VERSION}.darwin /usr/local/bin/sops
	sops --version
	sudo install -m 755 yq_darwin_amd64 /usr/local/bin/yq
	rm -f sops-${SOPS_VERSION}.darwin yq_darwin_amd64
endif

decrypt-%:
	./bin/decrypt-secrets.sh $*

encrypt-%:
	./bin/encrypt-secrets.sh $*

clean-%:
	rm local*/$*/*.yaml

clean:
	rm local*/*/*.yaml

check-for-unencrypted-secrets:
	./bin/check-for-unencrypted-secrets.sh
