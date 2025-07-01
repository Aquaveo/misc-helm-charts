# GeoServer Official Helm Chart

This Helm chart deploys [GeoServer](https://geoserver.org/) using the official [OSGeo GeoServer Docker image](https://hub.docker.com/r/osgeo/geoserver).

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistent data storage)

## Installation

### Add the Helm Repository

```bash
helm repo add misc-helm-charts https://your-repo-url.com
helm repo update
```

### Install the Chart

```bash
# Basic installation
helm install my-geoserver misc-helm-charts/geoserver-official

# With custom values
helm install my-geoserver misc-helm-charts/geoserver-official -f my-values.yaml

# Install in a specific namespace
helm install my-geoserver misc-helm-charts/geoserver-official --namespace geoserver --create-namespace
```

## Uninstalling the Chart

```bash
helm delete my-geoserver
```

## Configuration

The following table lists the configurable parameters and their default values.

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of GeoServer replicas | `1` |
| `image.repository` | GeoServer image repository | `docker.osgeo.org/geoserver` |
| `image.tag` | GeoServer image tag | `""` (uses appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
## Configuration

The following table lists the configurable parameters of the GeoServer chart and their default values.

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of GeoServer replicas | `1` |
| `image.repository` | GeoServer image repository | `docker.osgeo.org/geoserver` |
| `image.tag` | GeoServer image tag | `""` (uses appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `nameOverride` | Override the name of the chart | `""` |
| `fullnameOverride` | Override the full name of the release | `""` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### GeoServer Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `admin.user` | GeoServer admin username | `admin` |
| `admin.password` | GeoServer admin password | `geoserver` |
| `webappContext` | Web application context path | `geoserver` |
| `rootWebappRedirect` | Enable redirect from root to /geoserver/web | `false` |
| `proxyBaseUrl` | Proxy base URL (if behind reverse proxy) | `""` |

### Data Directory Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `dataDirectory.persistence.enabled` | Enable persistent storage for data directory | `true` |
| `dataDirectory.persistence.size` | Size of persistent volume | `8Gi` |
| `dataDirectory.persistence.storageClass` | Storage class | `""` |
| `dataDirectory.persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `dataDirectory.skipDemoData` | Skip demo data installation | `false` |

### JVM Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `jvm.extraJavaOpts` | Additional JVM options | `"-Xms512m -Xmx2g"` |

### Extensions Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `extensions.install` | Enable automatic extension installation | `false` |
| `extensions.stable` | List of stable extensions to install | `[]` |
| `extensions.community` | List of community extensions to install | `[]` |

### Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `security.runUnprivileged` | Run as unprivileged user | `true` |
| `security.runWithUserUid` | User ID to run as | `999` |
| `security.runWithUserGid` | Group ID to run as | `999` |
| `podSecurityContext.fsGroup` | Pod security context fsGroup | `999` |
| `securityContext.runAsUser` | Container security context runAsUser | `999` |
| `securityContext.runAsGroup` | Container security context runAsGroup | `999` |
| `securityContext.runAsNonRoot` | Run as non-root user | `true` |

### PostgreSQL Integration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgres.jndi.enabled` | Enable PostgreSQL JNDI configuration | `false` |
| `postgres.jndi.host` | PostgreSQL host | `""` |
| `postgres.jndi.port` | PostgreSQL port | `5432` |
| `postgres.jndi.database` | PostgreSQL database name | `""` |
| `postgres.jndi.username` | PostgreSQL username | `""` |
| `postgres.jndi.password` | PostgreSQL password | `""` |
| `postgres.jndi.resourceName` | JNDI resource name | `jdbc/postgres` |

### CORS Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cors.enabled` | Enable CORS configuration | `false` |
| `cors.allowedOrigins` | Allowed origins | `"*"` |
| `cors.allowedMethods` | Allowed HTTP methods | `"GET,POST,PUT,DELETE,HEAD,OPTIONS"` |
| `cors.allowedHeaders` | Allowed headers | `"Origin,Accept,X-Requested-With,Content-Type,Access-Control-Request-Method,Access-Control-Request-Headers"` |
| `cors.allowCredentials` | Allow credentials | `false` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

### Autoscaling Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable horizontal pod autoscaling | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas | `1` |
| `autoscaling.maxReplicas` | Maximum number of replicas | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `80` |

## Example Configurations

### Development Environment

```yaml
# Development setup with demo data
replicaCount: 1

admin:
  user: admin
  password: geoserver

dataDirectory:
  persistence:
    enabled: true
    size: 5Gi
  skipDemoData: false

jvm:
  extraJavaOpts: "-Xms256m -Xmx1g"

ingress:
  enabled: true
  hosts:
  - host: geoserver-dev.local
    paths:
    - path: /
      pathType: Prefix
```

### Production Environment

```yaml
# Production setup with security hardening
replicaCount: 2

image:
  tag: "2.27.0"

admin:
  user: admin
  password: "change-this-secure-password"

dataDirectory:
  persistence:
    enabled: true
    size: 50Gi
    storageClass: "fast-ssd"
  skipDemoData: true

jvm:
  extraJavaOpts: "-Xms2g -Xmx6g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

extensions:
  install: true
  stable:
  - "control-flow"
  - "monitor"
  - "inspire"
  - "css"
  - "ysld"

cors:
  enabled: true
  allowedOrigins: "https://myapp.example.com"
  allowCredentials: true

resources:
  limits:
    cpu: 2000m
    memory: 8Gi
  requests:
    cpu: 1000m
    memory: 4Gi

ingress:
  enabled: true
  className: "nginx"
  annotations:
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  hosts:
  - host: geoserver.example.com
    paths:
    - path: /
      pathType: Prefix
  tls:
  - secretName: geoserver-tls
    hosts:
    - geoserver.example.com
```

### PostgreSQL Integration

```yaml
# GeoServer with PostgreSQL backend
postgres:
  jndi:
    enabled: true
    host: "postgres.database.svc.cluster.local"
    port: 5432
    database: "geoserver"
    username: "geoserver"
    password: "secure-password"

extensions:
  install: true
  stable:
  - "postgresql"

dataDirectory:
  persistence:
    enabled: true
    size: 20Gi
  skipDemoData: true
```

### Production with Control Flow Extension

```yaml
# Production environment with control-flow extension for rate limiting
replicaCount: 3

image:
  tag: "2.27.0"

admin:
  user: admin
  password: "change-this-secure-password"

dataDirectory:
  persistence:
    enabled: true
    size: 100Gi
    storageClass: "fast-ssd"
  skipDemoData: true

jvm:
  extraJavaOpts: "-Xms4g -Xmx8g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication"

# Install control-flow extension for rate limiting
extensions:
  install: true
  stable:
  - "control-flow"
  - "monitor"
  - "inspire"

# Configure control-flow rules via ConfigMap
configMap:
  files:
    controlflow.properties: |
      # Global request limits
      ows.global=100
      ows.wms.global=50
      ows.wfs.global=30
      ows.wcs.global=20
      
      # Per-user limits (authenticated users)
      user.admin=30
      user.default=10
      
      # Per-IP limits for anonymous users
      ip.default=5
      
      # Timeout for requests in queue (seconds)
      timeout=60
      
      # Priority rules (higher numbers = higher priority)
      priority.wfs=10
      priority.wms=5
      priority.wcs=3

cors:
  enabled: true
  allowedOrigins: "https://myapp.example.com,https://admin.example.com"
  allowCredentials: true

resources:
  limits:
    cpu: 4000m
    memory: 12Gi
  requests:
    cpu: 2000m
    memory: 8Gi

# Horizontal Pod Autoscaler
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

# Pod disruption budget for high availability
podDisruptionBudget:
  enabled: true
  minAvailable: 2

ingress:
  enabled: true
  className: "nginx"
  annotations:
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
  hosts:
  - host: geoserver.example.com
    paths:
    - path: /
      pathType: Prefix
  tls:
  - secretName: geoserver-tls
    hosts:
    - geoserver.example.com

# Node affinity for spreading pods across nodes
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: geoserver-official
        topologyKey: kubernetes.io/hostname
```

## Available Extensions

### Stable Extensions
- `control-flow` - Rate limiting and request flow control
- `monitor` - Performance monitoring
- `inspire` - INSPIRE compliance
- `css` - CSS styling for maps
- `ysld` - YAML styling for maps
- `printing` - Map printing functionality
- `postgresql` - PostgreSQL support
- `wps` - Web Processing Service
- `gwc` - GeoWebCache integration

### Community Extensions
- `ogcapi-features` - OGC API - Features
- `ogcapi-maps` - OGC API - Maps
- `ogcapi-tiles` - OGC API - Tiles
- `cog` - Cloud Optimized GeoTIFF support

## Extension Configuration

### Control Flow Extension

The control-flow extension provides rate limiting and request flow control capabilities. It's essential for production environments to prevent server overload and ensure fair resource usage.

#### Configuration Options

The control-flow extension is configured via a `controlflow.properties` file. Here are the key configuration parameters:

- **Global Limits**: Set maximum concurrent requests for all services
- **Service-Specific Limits**: Different limits for WMS, WFS, WCS services
- **User-Based Limits**: Per-user request limits for authenticated users
- **IP-Based Limits**: Per-IP limits for anonymous users
- **Request Priorities**: Prioritize certain types of requests
- **Timeouts**: Maximum time requests can wait in queue

#### Example Control Flow Configuration

```properties
# Global request limits
ows.global=100                    # Maximum 100 concurrent requests globally
ows.wms.global=50                # Maximum 50 concurrent WMS requests
ows.wfs.global=30                # Maximum 30 concurrent WFS requests
ows.wcs.global=20                # Maximum 20 concurrent WCS requests

# Per-user limits (for authenticated users)
user.admin=30                    # Admin user can have 30 concurrent requests
user.poweruser=20                # Power users get 20 concurrent requests
user.default=10                  # Default authenticated users get 10

# Per-IP limits (for anonymous users)
ip.default=5                     # Anonymous users limited to 5 requests per IP

# Request timeout (seconds)
timeout=60                       # Requests wait maximum 60 seconds in queue

# Priority settings (higher number = higher priority)
priority.wfs=10                  # WFS requests get highest priority
priority.wms=5                   # WMS requests get medium priority
priority.wcs=3                   # WCS requests get lower priority

# Advanced settings
queue.timeout=120                # Maximum queue wait time
delay.after.completion=1000      # Delay in ms after request completion
```

#### Monitoring Control Flow

When using the control-flow extension with the monitor extension, you can track:
- Request queue length
- Request processing times
- Rejected requests due to limits
- User/IP-based statistics

## Security Considerations

1. **Change Default Credentials**: Always change the default admin password in production
2. **Use Strong Passwords**: Use complex passwords for the admin account
3. **Enable HTTPS**: Configure TLS/SSL for production deployments
4. **Limit Access**: Use network policies and ingress rules to restrict access
5. **Regular Updates**: Keep GeoServer and the chart updated with security patches

## Persistence

The chart mounts a persistent volume at `/opt/geoserver_data` for the GeoServer data directory. This ensures that:
- Configuration settings persist across pod restarts
- Workspace configurations are retained
- Custom styles and data stores are preserved

## Monitoring and Health Checks

The chart includes:
- Kubernetes readiness and liveness probes
- Support for monitoring extensions
- Health check endpoints for external monitoring

## Migration from Previous Versions

If upgrading from a previous version of this chart that used the nested `geoserver` values structure, you'll need to flatten your values. See the `REFACTORING.md` file for detailed migration instructions.

## Troubleshooting

### Common Issues

1. **Pod fails to start**: Check resource limits and persistent volume claims
2. **Data not persisting**: Verify persistent volume configuration
3. **Extensions not loading**: Check extension names and ensure they're compatible with the GeoServer version
4. **Memory issues**: Adjust JVM heap settings in `jvm.extraJavaOpts`

### Useful Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=geoserver-official

# View logs
kubectl logs -l app.kubernetes.io/name=geoserver-official

# Execute shell in pod
kubectl exec -it <pod-name> -- /bin/bash

# Port forward for local access
kubectl port-forward service/my-geoserver 8080:8080
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the changes
5. Submit a pull request

## License

This chart is licensed under the Apache License 2.0. See the LICENSE file for details.

## Support

- [GeoServer Documentation](https://docs.geoserver.org/)
- [GeoServer Community](https://geoserver.org/comm/)
- [Docker Image Documentation](https://github.com/geoserver/docker)
