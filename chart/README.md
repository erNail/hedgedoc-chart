# hedgedoc

A lightweight Helm chart for [HedgeDoc](https://github.com/hedgedoc/hedgedoc) that prioritizes
transparency and flexibility.

Linted with [`kube-score`](https://github.com/zegl/kube-score),
[`kube-linter`](https://github.com/stackrox/kube-linter)
and [`yamllint`](https://github.com/stackrox/kube-linter).
Tested with [`helm-unittest`](https://github.com/helm-unittest/helm-unittest).

## Design Philosophy

### Transparency and Flexibility over Abstraction and Convenience

This chart may diverge from some common chart conventions.
It favors transparency and flexibility over abstraction and convenience:

- **Values-Driven:** The goal is to provide a chart that can be understood just by looking at the values file.
  There should be no need to look into the templates to understand what the chart does and how it works.
- **Minimal Abstraction:** The chart avoids hidden logic and magic behavior as much as possible.
  A lot of what you see in the values file is what gets rendered in the templates.
- **Flexibility over Convenience:** The chart is designed to be flexible and understandable.
  But this comes at the cost of convenience.
  For example, if you want to use a config file instead of environment variables to configure your application,
  you can do so via editing the values file.
  But you'd have to make edits in multiple places. You'd have to set `.Values.configMap.enabled` to `true`,
  add the config to `.Values.configMap.data`
  and mount the ConfigMap by adapting `.Values.volumes` and `.Values.volumeMounts`.
  Another example, if you want to change the ports the application is using, you can do so. You'd have to set or adapt
  the environment variable that sets the port in `.Values.app.env`, and adapt `.Values.containerPorts` accordingly.

### No Dependencies

This chart does not bundle any databases (e.g., Postgres, Valkey) as a dependency.
While this may seem inconvenient, it keeps the chart lightweight, and ensures users actively design their setup.
Which database should be used? Is one already deployed? Should a new one be deployed? Is it deployed via helm chart or
operator? Which helm chart should be used? Is a managed database service used?
These are all questions that should be answered by the user, not the chart.

## Getting Started

### Deploy the Helm Chart

If the default values in the [`values.yaml`](./values.yaml) fit your needs,
you can deploy the helm chart using this command:

```shell
helm install hedgedoc oci://ghcr.io/ernail/charts/hedgedoc \
--namespace hedgedoc \
--create-namespace
```

### Configure the Helm Chart

Helm provides different ways to [configure helm charts via values](https://helm.sh/docs/helm/helm_install/#synopsis).
A common way is to create your own values file,
which overrides values of the charts default [`values.yaml`](./values.yaml):

```shell
helm install hedgedoc oci://ghcr.io/ernail/charts/hedgedoc \
--namespace hedgedoc \
--create-namespace \
--values values-base.yaml
```

You can also pass in multiple values files. For example if you need seperate configuration for your `dev` environment:

```shell
helm install hedgedoc oci://ghcr.io/ernail/charts/hedgedoc \
--namespace hedgedoc \
--create-namespace \
--values values-base.yaml
--values values-dev.yaml
```

All configuration options are documented in [this README](#values).
You can also check the [`values.yaml`](./values.yaml).

### Key Configuration Options

#### Database

The chart does not bundle any database, so you need to provide your own database.
You can configure the database connection via the `app.env` values. An example config is available in the
[`values.yaml`](./chart/values.yaml).

#### Image Upload

With the default configuration, HedgeDoc will use the local filesystem to store uploaded images.
This behavior can be be changed via the `app.env` values. When doing so, you don't need the `volumes` and `volumeMounts`
configured in the [`values.yaml`](./chart/values.yaml).

To persist the uploaded images, `persistence.enabled` must be set to `true`.

#### Miscellaneous

Other important configuration options that should be reviewed are:

- `app.env[].CMD_DOMAIN` - The domain where HedgeDoc is reachable.
- `ingress` - The ingress configuration for HedgeDoc.
- `metrics` - The metrics configuration for HedgeDoc.
- `resources` - The resource requests and limits for the HedgeDoc container.

#### Example Deployment

You can find example deployments in the [`examples`](./examples) directory.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| ernail | <nagel.eric.95@googlemail.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | The affinity for the pod(s).  Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| apiVersions | object | `{"configMap":"v1","deployment":"apps/v1","horizontalPodAutoscaler":"autoscaling/v2","ingress":"networking.k8s.io/v1","networkPolicy":"networking.k8s.io/v1","persistentVolumeClaim":"v1","podDisruptionBudget":"policy/v1","service":"v1","serviceAccount":"v1","serviceMonitor":"monitoring.coreos.com/v1","statefulSet":"apps/v1"}` | The api versions of the resources created by this chart.  Ref: https://kubernetes.io/docs/reference/using-api/deprecation-guide/ |
| app | object | `{"env":[{"name":"CMD_DB_USERNAME","valueFrom":{"secretKeyRef":{"key":"username","name":"hedgedoc-db-credentials"}}},{"name":"CMD_DB_PASSWORD","valueFrom":{"secretKeyRef":{"key":"password","name":"hedgedoc-db-credentials"}}},{"name":"CMD_DB_DATABASE","value":"hedgedoc"},{"name":"CMD_DB_HOST","value":"postgresql-hedgedoc-rw"},{"name":"CMD_DB_PORT","value":"5432"},{"name":"CMD_DB_DIALECT","value":"postgres"},{"name":"CMD_LOG_LEVEL","value":"info"},{"name":"CMD_IMAGE_UPLOAD_TYPE","value":"filesystem"},{"name":"CMD_DOMAIN","value":"hedgedoc.example.com"}]}` | App configuration. |
| app.env | list | `[{"name":"CMD_DB_USERNAME","valueFrom":{"secretKeyRef":{"key":"username","name":"hedgedoc-db-credentials"}}},{"name":"CMD_DB_PASSWORD","valueFrom":{"secretKeyRef":{"key":"password","name":"hedgedoc-db-credentials"}}},{"name":"CMD_DB_DATABASE","value":"hedgedoc"},{"name":"CMD_DB_HOST","value":"postgresql-hedgedoc-rw"},{"name":"CMD_DB_PORT","value":"5432"},{"name":"CMD_DB_DIALECT","value":"postgres"},{"name":"CMD_LOG_LEVEL","value":"info"},{"name":"CMD_IMAGE_UPLOAD_TYPE","value":"filesystem"},{"name":"CMD_DOMAIN","value":"hedgedoc.example.com"}]` | Environment variables to pass to the container.  Ref: https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/ |
| app.env[0] | object | `{"name":"CMD_DB_USERNAME","valueFrom":{"secretKeyRef":{"key":"username","name":"hedgedoc-db-credentials"}}}` | The database username. |
| app.env[1] | object | `{"name":"CMD_DB_PASSWORD","valueFrom":{"secretKeyRef":{"key":"password","name":"hedgedoc-db-credentials"}}}` | The database password. |
| app.env[2] | object | `{"name":"CMD_DB_DATABASE","value":"hedgedoc"}` | The database name. |
| app.env[3] | object | `{"name":"CMD_DB_HOST","value":"postgresql-hedgedoc-rw"}` | The database URL without protocol and port. |
| app.env[4] | object | `{"name":"CMD_DB_PORT","value":"5432"}` | The database port. |
| app.env[5] | object | `{"name":"CMD_DB_DIALECT","value":"postgres"}` | The database dialect. |
| app.env[6] | object | `{"name":"CMD_LOG_LEVEL","value":"info"}` | The log level for the application. |
| app.env[7] | object | `{"name":"CMD_IMAGE_UPLOAD_TYPE","value":"filesystem"}` | The image upload type. |
| app.env[8] | object | `{"name":"CMD_DOMAIN","value":"hedgedoc.example.com"}` | The domain of the application. |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":2,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":80}` | Autoscaling configuration. Be aware that HedgeDoc does not support running multiple instances on the same database.  Ref: https://kubernetes.io/docs/concepts/workloads/autoscaling/ |
| configMap | object | `{"annotations":{},"data":{},"enabled":false,"name":"config"}` | ConfigMap configuration.  Ref: https://kubernetes.io/docs/concepts/configuration/configmap/ |
| configMap.annotations | object | `{}` | Annotations to add to the ConfigMap. |
| configMap.data | object | `{}` | The data to add to the ConfigMap. |
| configMap.enabled | bool | `false` | Whether to create a ConfigMap resource. |
| configMap.name | string | `"config"` | The name of the ConfigMap. The name should reference the ConfigMap name at `.Values.volumes`. |
| containerPorts | list | `[{"name":"http","port":3000,"protocol":"TCP"},{"name":"metrics","port":3000,"protocol":"TCP"}]` | The ports of the container. To use these ports in the service(s), you need to add them to `.Values.service.ports` or `.Values.metrics.service.ports`.  If `.Values.networkPolicy.enabled` is true and `.Values.ingress.enabled` is true, you need to add them to `.Values.networkPolicy.ingressController.containerPorts`.  If `.Values.livenessProbe.enabled` is true, you need to add them to `.Values.livenessProbe`.  If `.Values.readinessProbe.enabled` is true, you need to add them to `.Values.readinessProbe`.  Ref: https://kubernetes.io/docs/concepts/services-networking/service/  Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/ |
| containerSecurityContext | object | `{"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsUser":10001}` | The security context for the container.  Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| extraPodLabels | object | `{}` | Extra labels to add to the pod(s).  Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| fullnameOverride | string | `""` | Use this to override the fullname of the chart. |
| hostPodAntiAffinity | object | `{"enabled":false,"weight":50}` | A host podAntiAffinity, that stops multiple pods from from being scheduled on the same node.  Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| hostPodAntiAffinity.enabled | bool | `false` | Whether to enable the host podAntiAffinity. |
| hostPodAntiAffinity.weight | int | `50` | The weight of the host podAntiAffinity. |
| image | object | `{"pullPolicy":"Always","repository":"quay.io/hedgedoc/hedgedoc","tag":""}` | The image of the container.  Ref: https://kubernetes.io/docs/concepts/containers/images/ |
| image.pullPolicy | string | `"Always"` | The pull policy for the image. |
| image.repository | string | `"quay.io/hedgedoc/hedgedoc"` | The repository/name/url of the image. |
| image.tag | string | `""` | The tag of the image. If not set, the chart's `appVersion` is used. |
| imagePullSecrets | list | `[]` | Secrets for pulling an image from a private repository.  Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ |
| ingress | object | `{"annotations":{},"className":"nginx","enabled":false,"hosts":[{"host":"hedgedoc.example.com","paths":[{"path":"/","pathType":"Prefix","servicePortName":"http"}]}],"tls":[{"hosts":["hedgedoc.example.com"],"secretName":"hedgedoc-tls"}]}` | Ingress configuration.  Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/ |
| ingress.annotations | object | `{}` | Annotations to add to the Ingress. |
| ingress.className | string | `"nginx"` | The class of the Ingress controller. |
| ingress.enabled | bool | `false` | Whether to create an Ingress resource. |
| ingress.hosts | list | `[{"host":"hedgedoc.example.com","paths":[{"path":"/","pathType":"Prefix","servicePortName":"http"}]}]` | The hosts of the Ingress. |
| ingress.hosts[0].paths[0].servicePortName | string | `"http"` | The service port name to use for the Ingress. This should reference the service ports defined at `.Values.service.ports`. |
| ingress.tls | list | `[{"hosts":["hedgedoc.example.com"],"secretName":"hedgedoc-tls"}]` | The TLS configuration for the Ingress. |
| livenessProbe | object | `{}` | Liveness Probe configuration. Liveness probes can be dangerous. Only use them if you really need one. See https://srcco.de/posts/kubernetes-liveness-probes-are-dangerous.html for more information.  Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| metrics | object | `{"enabled":false,"service":{"ports":[{"name":"metrics","port":3000,"protocol":"TCP","targetPort":"metrics"}],"type":"ClusterIP"},"serviceMonitor":{"enabled":false,"endpoints":[{"interval":"30s","metricRelabelings":[],"path":"/metrics","port":"metrics","relabelings":[]}]}}` | Configuration options regarding metrics resources (ServiceMonitor, Service, etc.).  Ref: https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#customresourcedefinitions |
| metrics.enabled | bool | `false` | Whether to create a service for metrics. |
| metrics.service | object | `{"ports":[{"name":"metrics","port":3000,"protocol":"TCP","targetPort":"metrics"}],"type":"ClusterIP"}` | Metrics service configuration. |
| metrics.service.ports | list | `[{"name":"metrics","port":3000,"protocol":"TCP","targetPort":"metrics"}]` | The ports of the metrics service. These should reference the container ports defined at `.Values.containerPorts`.  Ref: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports |
| metrics.service.type | string | `"ClusterIP"` | The type of service to create.  Ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |
| metrics.serviceMonitor | object | `{"enabled":false,"endpoints":[{"interval":"30s","metricRelabelings":[],"path":"/metrics","port":"metrics","relabelings":[]}]}` | ServiceMonitor configuration.  Ref: https://github.com/prometheus-operator/prometheus-operator?tab=readme-ov-file#customresourcedefinitions |
| metrics.serviceMonitor.enabled | bool | `false` | Whether to create a ServiceMonitor resource. |
| metrics.serviceMonitor.endpoints | list | `[{"interval":"30s","metricRelabelings":[],"path":"/metrics","port":"metrics","relabelings":[]}]` | Configuration of the endpoints to scrape. |
| metrics.serviceMonitor.endpoints[0] | object | `{"interval":"30s","metricRelabelings":[],"path":"/metrics","port":"metrics","relabelings":[]}` | The service port to scrape. This should reference the service ports defined at `.Values.metrics.service.ports`. |
| metrics.serviceMonitor.endpoints[0].interval | string | `"30s"` | The interval at which metrics should be scraped. |
| metrics.serviceMonitor.endpoints[0].metricRelabelings | list | `[]` | The metric relabelings to apply. |
| metrics.serviceMonitor.endpoints[0].path | string | `"/metrics"` | The path to scrape metrics from. |
| metrics.serviceMonitor.endpoints[0].relabelings | list | `[]` | The relabelings to apply. |
| nameOverride | string | `""` | Use this to override the name of the chart. |
| namespaceOverride | string | `""` | Use this to override the namespace of the chart. By default, `.Release.Namespace` is used. |
| networkPolicy | object | `{"annotations":{},"egress":{"allowAll":false,"extraRules":[]},"enabled":false,"extraIngess":[],"ingress":{"allowAll":false,"extraRules":[],"ingressController":{"containerPorts":["http"],"from":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"ingress"}},"podSelector":{"matchLabels":{"app.kubernetes.io/name":"ingress-nginx"}}}]},"metricsScraper":{"from":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"kube-prometheus-stack"}},"podSelector":{"matchLabels":{"app.kubernetes.io/name":"kube-prometheus-stack-prometheus-operator"}}}]}}}` | Network Policy configuration.  Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/ |
| networkPolicy.annotations | object | `{}` | Annotations to add to the NetworkPolicy. |
| networkPolicy.egress | object | `{"allowAll":false,"extraRules":[]}` | Egress configuration. |
| networkPolicy.egress.allowAll | bool | `false` | Whether to allow all egress traffic. If true, all other egress rules will be ignored. |
| networkPolicy.egress.extraRules | list | `[]` | Extra egress rules. |
| networkPolicy.enabled | bool | `false` | Whether to create a NetworkPolicy resource. |
| networkPolicy.extraIngess | list | `[]` | Extra ingress rules. |
| networkPolicy.ingress.allowAll | bool | `false` | Whether to allow all ingress traffic. If true, all other ingress rules will be ignored. |
| networkPolicy.ingress.extraRules | list | `[]` | Extra ingress rules. |
| networkPolicy.ingress.ingressController | object | `{"containerPorts":["http"],"from":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"ingress"}},"podSelector":{"matchLabels":{"app.kubernetes.io/name":"ingress-nginx"}}}]}` | Configuration for allowing ingress traffic from the ingress controller. Only used if `ingress.enabled` is true. |
| networkPolicy.ingress.ingressController.containerPorts | list | `["http"]` | The container ports to allow the ingress controller to access. These should reference the container ports defined at `.Values.containerPorts`. |
| networkPolicy.ingress.ingressController.from | list | `[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"ingress"}},"podSelector":{"matchLabels":{"app.kubernetes.io/name":"ingress-nginx"}}}]` | The `from` rules to allow ingress traffic from the ingress controller. |
| networkPolicy.ingress.metricsScraper | object | `{"from":[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"kube-prometheus-stack"}},"podSelector":{"matchLabels":{"app.kubernetes.io/name":"kube-prometheus-stack-prometheus-operator"}}}]}` | Configuration for allowing ingress traffic from the metrics scraper. |
| networkPolicy.ingress.metricsScraper.from | list | `[{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"kube-prometheus-stack"}},"podSelector":{"matchLabels":{"app.kubernetes.io/name":"kube-prometheus-stack-prometheus-operator"}}}]` | The `from` rules to allow ingress traffic from the metrics scraper(s). |
| nodeSelector | object | `{}` | The node selector for the pod(s).  Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"pvcName":"hedgedoc-image-uploads","size":"8Gi","storageClass":""}` | Persistent Volume Claim configuration.  Ref: https://kubernetes.io/docs/concepts/storage/persistent-volumes/ |
| persistence.accessModes | list | `["ReadWriteOnce"]` | The access modes of the persistent volume claim. |
| persistence.annotations | object | `{}` | Annotations to add to the persistent volume claim. |
| persistence.enabled | bool | `false` | Whether to enable persistence. |
| persistence.pvcName | string | `"hedgedoc-image-uploads"` | The name of the persistent volume claim. The name should reference the PersistentVolumeClaim defined at `.Values.volumes`. |
| persistence.size | string | `"8Gi"` | The size of the persistent volume claim. |
| persistence.storageClass | string | `""` | The storage class of the persistent volume claim. |
| podAnnotations | object | `{}` | Annotations to add to the pod(s).  Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podDisruptionBudget | object | `{"annotations":{},"enabled":false,"maxUnavailable":1,"minAvailable":1,"unhealthyPodEvictionPolicy":"AlwaysAllow"}` | Pod Disruption Budget configuration.  Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/ |
| podDisruptionBudget.annotations | object | `{}` | Annotations to add to the PodDisruptionBudget. |
| podDisruptionBudget.enabled | bool | `false` | Whether to create a PodDisruptionBudget resource. |
| podDisruptionBudget.maxUnavailable | int | `1` | The maximum number of pods that can be unavailable. Ignored if `minAvailable` is set. |
| podDisruptionBudget.minAvailable | int | `1` | The minimum number of pods that must be available. If set, maxUnavailable won't be used. |
| podDisruptionBudget.unhealthyPodEvictionPolicy | string | `"AlwaysAllow"` | The Unhealthy Pod Eviction Policy. |
| podSecurityContext | object | `{}` | The security context for the pod.  Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| readinessProbe | object | `{"httpGet":{"path":"/status","port":"http"}}` | Readiness Probe configuration.  Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| readinessProbe.httpGet.path | string | `"/status"` | The path to use for the readiness probe. |
| readinessProbe.httpGet.port | string | `"http"` | The port to use for the readiness probe. This should reference the container ports defined at `.Values.containerPorts`. |
| replicaCount | int | `1` | The number of replicas of the pod. Will not be used if `.Values.autoscaling.enabled` is `true`. Be aware that HedgeDoc does not support running multiple instances on the same database.  Ref: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/ |
| resources | object | `{"limits":{"cpu":"100m","ephemeral-storage":"128Mi","memory":"128Mi"},"requests":{"cpu":"100m","ephemeral-storage":"128Mi","memory":"128Mi"}}` | Resource limits and requests.  Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| service | object | `{"enableAdditionalHeadlessService":false,"ports":[{"name":"http","port":3000,"protocol":"TCP","targetPort":"http"}],"type":"ClusterIP"}` | Service configuration. A service for metrics is created separately. Check `.Values.metrics` for more information.  Ref: https://kubernetes.io/docs/concepts/services-networking/service/ |
| service.enableAdditionalHeadlessService | bool | `false` | Wether to create an additional headless service. This should be enabled when using StatefulSets.  Ref: https://kubernetes.io/docs/concepts/services-networking/service/#headless-services |
| service.ports | list | `[{"name":"http","port":3000,"protocol":"TCP","targetPort":"http"}]` | The ports of the service. These should reference the container ports defined at `.Values.containerPorts`. When `.Values.ingress.enabled` is `true`, they should reference `.Values.ingress.hosts`.  Ref: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports |
| service.type | string | `"ClusterIP"` | The type of service to create.  Ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |
| serviceAccount | object | `{"annotations":{},"automount":true,"enabled":true,"name":""}` | Configuration for service accounts.  Ref: https://kubernetes.io/docs/concepts/security/service-accounts/ |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.automount | bool | `true` | Whether to mount a ServiceAccount's API credentials. |
| serviceAccount.enabled | bool | `true` | Whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set, a name is generated based on the chart name. |
| strategy | object | `{"type":"RollingUpdate"}` | Deployment strategy configuration.  Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| tolerations | object | `{}` | The tolerations for the pod(s).  Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| volumeMounts | list | `[{"mountPath":"/tmp","name":"tmp"},{"mountPath":"/hedgedoc/public/uploads","name":"hedgedoc-image-uploads"}]` | Volume Mounts configuration.  Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| volumeMounts[0] | object | `{"mountPath":"/tmp","name":"tmp"}` | Needed for the user to be able to upload images The name should reference the volume defined at `.Values.volumes`. |
| volumeMounts[1] | object | `{"mountPath":"/hedgedoc/public/uploads","name":"hedgedoc-image-uploads"}` | Only relevant if app.env[].CMD_IMAGE_UPLOAD_TYPE is set to "filesystem" The name should reference the volume defined at `.Values.volumes`. |
| volumes | list | `[{"emptyDir":{},"name":"tmp"},{"name":"hedgedoc-image-uploads","persistentVolumeClaim":{"claimName":"hedgedoc-image-uploads"}}]` | Volumes configuration.  Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| volumes[0] | object | `{"emptyDir":{},"name":"tmp"}` | Needed for the user to be able to upload images The volume name should reference the volumeMounts defined at `.Values.volumeMounts`. |
