.DEFAULT_GOAL := deploy

COMPONENT_NAME   ?= $(error COMPONENT_NAME not defined)
DOMAIN_NAME      ?= $(error DOMAIN_NAME not defined)
NAMESPACE        ?= elasticsearch
kubectl ?= kubectl --context="$(DOMAIN_NAME)" --namespace="$(NAMESPACE)"
helm    ?= helm3 --namespace=$(NAMESPACE) --kube-context="$(DOMAIN_NAME)"
DEBUG   := #--debug

PRIOR_FAILED := $(shell $(helm) list -q --pending --failed | grep $(COMPONENT_NAME))
PRIOR_INSTALL := $(shell $(helm) list -q | grep $(COMPONENT_NAME))

clean:
	rm -rf opendistro-build
	-rm *.pem

fetch:
	git clone https://github.com/opendistro-for-elasticsearch/opendistro-build
	#git -C opendistro-build checkout $(CHART_BRANCH)

deploy: clean fetch create-certs
ifneq ($(PRIOR_FAILED),)
deploy: undeploy
endif

ifeq ($(PRIOR_INSTALL),)
deploy: create-assets
endif

deploy: install

install:
	$(helm) upgrade $(COMPONENT_NAME) $(DEBUG) \
                --namespace $(NAMESPACE) \
		--install \
		--values values.yaml \
		opendistro-build/helm/opendistro-es

create-certs:
	./gen-certificates.sh

create-assets:
	kubectl --context="$(DOMAIN_NAME)" get namespace $(NAMESPACE) || kubectl --context="$(DOMAIN_NAME)" create namespace $(NAMESPACE)
	-$(kubectl) delete secret rest-certs transport-certs admin-certs es-security-config
	$(kubectl) create secret generic rest-certs \
		--from-file=elk-rest-crt.pem=node.pem \
		--from-file=elk-rest-key.pem=node-key.pem \
		--from-file=elk-rest-root-ca.pem=root-ca.pem
	$(kubectl) create secret generic transport-certs \
		--from-file=elk-transport-crt.pem=node.pem \
		--from-file=elk-transport-key.pem=node-key.pem \
		--from-file=elk-transport-root-ca.pem=root-ca.pem
	$(kubectl) create secret generic admin-certs \
		--from-file=admin-crt.pem=admin.pem \
		--from-file=admin-key.pem=node-key.pem \
		--from-file=admin-root-ca.pem=root-ca.pem
	$(kubectl) create secret generic es-security-config \
		--from-file=config.yml=securityconfig.yaml \
		--from-file=roles_mapping.yml=role-mappings.yaml \
		--from-file=roles.yml=roles.yaml \
		--from-file=action_groups.yml=action-groups.yaml \
		--from-file=tenants.yml=tenants.yaml \
                --from-file=internal_users.yml=internal-users.yaml

post-install:
	$(kubectl) exec $(COMPONENT_NAME)-opendistro-es-master-0 -- bash /usr/share/elasticsearch/plugins/opendistro_security/tools/securityadmin.sh -cacert /usr/share/elasticsearch/config/admin-root-ca.pem -cert /usr/share/elasticsearch/config/admin-crt.pem -key /usr/share/elasticsearch/config/admin-key.pem -cd /usr/share/elasticsearch/plugins/opendistro_security/securityconfig/ -nhnv

undeploy:
	-$(helm) delete $(COMPONENT_NAME)
	-$(kubectl) delete secrets rest-certs transport-certs admin-certs es-security-config

-include ../Mk/phonies
