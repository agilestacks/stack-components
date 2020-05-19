.DEFAULT_GOAL := deploy

COMPONENT_NAME   ?= $(error COMPONENT_NAME not defined)
DOMAIN_NAME      ?= $(error DOMAIN_NAME not defined)
NAMESPACE        ?= elasticsearch
kubectl ?= kubectl --context="$(DOMAIN_NAME)" --namespace="$(NAMESPACE)"
helm    ?= helm3 --namespace=$(NAMESPACE) --kube-context="$(DOMAIN_NAME)"
DEBUG   := #--debug

PRIOR_FAILED := $(shell $(helm) list -q --pending --failed | grep $(COMPONENT_NAME))

clean:
	rm -rf helm-charts
fetch:
	git clone https://github.com/elastic/helm-charts.git

deploy: clean fetch
ifneq ($(PRIOR_FAILED),)
deploy: undeploy
endif

deploy: install

install:
	kubectl --context="$(DOMAIN_NAME)" get namespace $(NAMESPACE) || kubectl --context="$(DOMAIN_NAME)" create namespace $(NAMESPACE)
	$(helm) upgrade $(COMPONENT_NAME)-masters      --wait --timeout=10m --install --values values-master.yaml helm-charts/elasticsearch
	$(helm) upgrade $(COMPONENT_NAME)-datanodes    --wait --timeout=10m --install --values values-data.yaml helm-charts/elasticsearch
	$(helm) upgrade $(COMPONENT_NAME)-coordinators --wait --timeout=10m --install --values values-coordinator.yaml helm-charts/elasticsearch
	$(helm) upgrade $(COMPONENT_NAME)-ingests      --wait --timeout=10m --install --values values-ingest.yaml helm-charts/elasticsearch
	$(helm) upgrade $(COMPONENT_NAME)-kibana       --wait --timeout=10m --install --values values-kibana.yaml helm-charts/kibana

undeploy:
	-$(helm) delete $(COMPONENT_NAME)-masters
	-$(helm) delete $(COMPONENT_NAME)-datanodes
	-$(helm) delete $(COMPONENT_NAME)-coordinators
	-$(helm) delete $(COMPONENT_NAME)-ingests
	-$(helm) delete $(COMPONENT_NAME)-kibana
	-$(kubectl) delete pvc --all

-include ../Mk/phonies
