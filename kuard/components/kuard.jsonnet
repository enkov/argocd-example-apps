local p = import '../params.libsonnet';
local params = p.kuard;

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'kuard-deployment',
      annotations: {
        'litmuschaos.io/chaos': 'true',
      },
      labels: {
        app: 'kuard',
      },
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          app: 'kuard',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'kuard',
          },
        },
        spec: {
          containers: [
            {
              image: 'gcr.io/kuar-demo/kuard-amd64:blue',
              name: 'kuard',
              ports: [
                {
                  containerPort: 8080,
                  name: 'http',
                },
              ],
              volumeMounts: [
                {
                  mountPath: '/srv/conf',
                  name: 'kuard-conf',
                  // readOnly: 'true',
                },
              ],
            },
          ],
          volumes: [
            {
              name: 'kuard-conf',
              configMap: {
                items: [
                  {
                    key: 'default.conf',
                    path: 'kuard.conf',
                  },
                  {
                    key: 'alert.conf',
                    path: 'ololo.conf',
                  },
                ],
                name: 'kuard-configmap',
              },
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'kuard-service',
    },
    spec: {
      selector: {
        app: 'kuard',
      },
      ports: [
        {
          port: 80,
          targetPort: 8080,
        },
      ],
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      labels: {
        app: 'kuard',
      },
      name: 'kuard-np',
    },
    spec: {
      ports: [
        {
          name: 'web',
          // nodePort: 30904,
          port: 8080,
          protocol: 'TCP',
          targetPort: 8080,
        },
      ],
      selector: {
        app: 'kuard',
      },
      type: 'NodePort',
    },
  },
  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      annotations: {
        'nginx.ingress.kubernetes.io/proxy-body-size': '512m',
        'nginx.ingress.kubernetes.io/proxy-connect-timeout': '300',
        'nginx.ingress.kubernetes.io/proxy-read-timeout': '300',
        'nginx.ingress.kubernetes.io/proxy-send-timeout': '300',
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
      },
      name: 'kuard',
    },
    spec: {
      tls: [
        {
          hosts: [
            params.ingressHostname,
          ],
          secretName: 'le-prod',
        },
      ],
      rules: [
        {
          host: params.ingressHostname,
          http: {
            paths: [
              {
                backend: {
                  service: {
                    name: 'kuard-service',
                    port: {
                      number: 80,
                    },
                  },
                },
                path: '/',
                pathType: 'Prefix',
              },
            ],
          },
        },
      ],
    },
  },
  {
    kind: 'ConfigMap',
    apiVersion: 'v1',
    metadata: {
      labels: {
        app: 'kuard',
      },
      name: 'kuard-configmap',
      // namespace: namespace,
    },
    data: params.confData,
  },
]
