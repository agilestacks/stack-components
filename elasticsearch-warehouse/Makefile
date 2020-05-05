.DEFAULT_GOAL := deploy

COMPONENT_NAME   ?= $(error COMPONENT_NAME not defined)
DOMAIN_NAME      ?= $(error DOMAIN_NAME not defined)
NAMESPACE        ?= elasticsearch

kubectl ?= kubectl --context="$(DOMAIN_NAME)"
helm    ?= helm3 --namespace=$(NAMESPACE) --kube-context="$(DOMAIN_NAME)"

deploy: clean fetch rem_failed install

clean:
	rm -rf opendistro-build

fetch:
	git clone https://github.com/opendistro-for-elasticsearch/opendistro-build
	#git -C opendistro-build checkout 1.6.0

rem_failed:
	-$(helm) list --failed --pending | grep $(COMPONENT_NAME) && $(helm) delete $(COMPONENT_NAME)

install: create-assets
	$(helm) upgrade $(COMPONENT_NAME) --debug \
                --namespace $(NAMESPACE) \
		--install \
		--values values.yaml \
		opendistro-build/helm/opendistro-es

create-assets:
	$(kubectl) get namespace $(NAMESPACE) || $(kubectl) create namespace $(NAMESPACE)
	$(kubectl) -n $(NAMESPACE) delete secret rest-certs transport-certs admin-certs
	@ ./gen-certificates.sh
	$(kubectl) -n $(NAMESPACE) create secret generic rest-certs \
		--from-file=elk-rest-crt.pem=node.pem \
		--from-file=elk-rest-key.pem=node-key.pem \
		--from-file=elk-rest-root-ca.pem=root-ca.pem
	$(kubectl) -n $(NAMESPACE) create secret generic transport-certs \
		--from-file=elk-transport-crt.pem=node.pem \
		--from-file=elk-transport-key.pem=node-key.pem \
		--from-file=elk-transport-root-ca.pem=root-ca.pem
	$(kubectl) -n $(NAMESPACE) create secret generic admin-certs \
		--from-file=admin-crt.pem=admin.pem \
		--from-file=admin-key.pem=node-key.pem \
		--from-file=admin-root-ca.pem=root-ca.pem
	$(kubectl) -n $(NAMESPACE) create secret generic es-security-config --from-file=config.yml=securityconfig.yml

undeploy:
	$(helm) delete $(COMPONENT_NAME)
	$(kubectl) -n $(NAMESPACE) delete secret rest-certs transport-certs admin-certs

-include ../Mk/phonies
