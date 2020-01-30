.DEFAULT_GOAL := deploy

DOMAIN_NAME       ?= dev.test.superhub.io
NAMESPACE         ?= spark
NAME 				      ?= spark
NUMBER_OF_MASTERS ?= 1
IMAGE 						?=

kubectl ?= kubectl --context="$(DOMAIN_NAME)" -n "$(NAMESPACE)"

RETRIES = 20

EXAMPLE_POD_NAME = example-task
EXAMPLE_POD_IMAGE = bde2020/spark-base:2.4.4-hadoop2.7
EXAMPLE_SERVICE_NAME = spark-client

namespace:
	-$(kubectl) create ns "$(NAMESPACE)"

spark-operator-subscription:
	$(kubectl) apply -f templates/operator-group.yaml
	$(kubectl) apply -f templates/subscription.yaml
	$(eval csv_name=$(kubectl) get subscription \
		$(NAME)-subscription -o json | jq -cr .status.installedCSV)
	@for i in $$(seq 1 $(RETRIES)); do \
		if [ "$$($(kubectl) get clusterserviceversion `$(csv_name)` -o json | jq -cr '.status.phase')" = "Succeeded" ]; then \
			echo "Operator `$(csv_name)` provisioned / updated"; \
			exit 0; \
		fi; \
		if [ $$i -eq $(RETRIES) ]; then \
			echo "Operator failed to provision"; \
			exit 1; \
		fi; \
		echo "Operator not provisioned. Retrying check..."; \
		sleep 3; \
	done;

spark-cluster:
	$(kubectl) apply -f templates/spark-cluster.yaml
	$(eval check_masters=$(kubectl) get pods -l 'radanalytics.io/SparkCluster=$(NAME),radanalytics.io/podType=master' \
		--output=jsonpath='{.items..containerStatuses[?(@.ready==true)].containerID}' | wc -w | xargs)
	@for i in $$(seq 1 $(RETRIES)); do \
		if [ `$(check_masters)` -eq $(NUMBER_OF_MASTERS) ]; then \
			echo "$(NAME) is up"; \
			exit 0; \
		fi; \
		if [ $$i -eq $(RETRIES) ]; then \
			echo "$(NAME) failed to deploy"; \
			exit 1; \
		fi; \
		echo "$(NAME) is not up. Retrying check..."; \
		sleep 3; \
	done;

ingress:
	$(kubectl) apply -f templates/ingress.yaml

run-example-task:
	$(kubectl) create service clusterip $(EXAMPLE_SERVICE_NAME) --clusterip='None'
	$(kubectl) run --generator=run-pod/v1 --labels="app=$(EXAMPLE_SERVICE_NAME)" \
		--image $(EXAMPLE_POD_IMAGE) -i $(EXAMPLE_POD_NAME) -- \
			./spark/bin/spark-submit \
					--deploy-mode client \
					--conf spark.driver.host=$(EXAMPLE_SERVICE_NAME) \
					--master spark://$(NAME):7077 \
					--class org.apache.spark.examples.SparkPi \
					--executor-memory 512M /spark/examples/jars/spark-examples_2.11-2.4.4.jar
	$(kubectl) delete service $(EXAMPLE_SERVICE_NAME)
	$(kubectl) delete pod $(EXAMPLE_POD_NAME)

deploy: namespace spark-operator-subscription spark-cluster ingress run-example-task

undeploy:
	-$(kubectl) delete -f templates/ingress.yaml
	-$(kubectl) delete -f templates/spark-cluster.yaml
	-$(kubectl) delete -f templates/subscription.yaml
	-$(kubectl) delete -f templates/operator-group.yaml
