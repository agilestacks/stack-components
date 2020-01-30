# Apache Spark Cluster

Apache Spark is an open-source distributed general-purpose cluster-computing framework. Spark provides an interface for programming entire clusters with implicit data parallelism and fault tolerance.

## Prerequisites

The component can be deployed on AgileStacks [Platform](https://docs.agilestacks.com/article/0tikhmp5kj-deploying-a-platform-stack-to-aws) that provides the following components:

* Kubernetes
* Traefik
* Let's Encrypt (recommended, but not mandatory)
* OLM (Operator Lifecycle Manager)
* OKD Console (recommended, but not mandatory)

OLM and OKD Console can be deployed as a part of the platform or as an overlay stack. More information about AgileStacks templates and components are available [here](https://docs.agilestacks.com/category/f6intk9cy5-templates-components).
Apache Spark Cluster component uses an [operator](https://github.com/radanalyticsio) to deploy the cluster. The operator lifecycle is controlled by [OLM](https://github.com/operator-framework/operator-lifecycle-manager) (that must be present on the platform).

## Deployment

The component can be deployed using [SuperHub CLI](https://docs.agilestacks.com/category/vnrrh796qa-superhub-cli) or it can be added to the AgileStacks control-plane as a [custom component](https://docs.agilestacks.com/article/8g2yhrrmst-create-a-custom-component).

Component parameters can be adjusted in [hub-component.yaml](hub-component.yaml) file.
Once deployed, the component outputs `component.custom-spark.dashboard.url` parameter that points to the Apache Spark cluster dashboard which is SSO protected.

Additionally, an example task that calculates Pi is submitted as part of the deployment. If that is not needed disable `run-example-task` in the [Makefile](Makefile).
