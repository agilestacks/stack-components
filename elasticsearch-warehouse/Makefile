.DEFAULT_GOAL := deploy

COMPONENT_NAME   ?= $(error COMPONENT_NAME not defined)
DOMAIN_NAME      ?= $(error DOMAIN_NAME not defined)
NAMESPACE        ?= elasticsearch

kubectl ?= kubectl --context="$(DOMAIN_NAME)" --namespace="$(NAMESPACE)"
helm    ?= helm3 --namespace=$(NAMESPACE) --kube-context="$(DOMAIN_NAME)"

fetch:
	git clone https://github.com/opendistro-for-elasticsearch/opendistro-build

deploy:
	helm3 upgrade $(COMPONENT_NAME) \
		--install \
		--values values.yaml \
		opendistro-build/helm/opendistro-es

undeploy:
	helm3 delete $(COMPONENT_NAME)

-include ../Mk/phonies
