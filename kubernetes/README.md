# Kubernetes Manifests

Secure manifests for deploying the Blogging App to EKS with hardened security configurations.

## Files

- `namespace.yaml` - Create `blogging-app` namespace
- `deployment.yaml` - 2-replica deployment with hardened security context, read-only filesystem, non-root user
- `service.yaml` - LoadBalancer service (port 80 → 8080)
- `serviceaccount.yaml` - Service account with minimal RBAC permissions (NEW - Security Hardening)
- `networkpolicy.yaml` - Network policies restricting pod-to-pod and ingress/egress traffic (NEW - Security Hardening)

## Deploy

```bash
# Apply all manifests
kubectl apply -f kubernetes/

# Verify
kubectl get pods -n blogging-app
kubectl get svc blogging-app-service -n blogging-app
```

## Update Image

```bash
kubectl set image deployment/blogging-app blogging-app=<ECR_URL>:<TAG> -n blogging-app
```

## Get LoadBalancer URL

```bash
kubectl get svc blogging-app-service -n blogging-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Rollback

```bash
kubectl rollout undo deployment/blogging-app -n blogging-app
```

## Cleanup

```bash
kubectl delete namespace blogging-app
```

## Configuration

- **Replicas**: 2
- **CPU Requests**: 250m (guaranteed)
- **CPU Limits**: 500m (maximum)

## 🔐 Security Hardening

### Service Account Token Protection

✅ `automountServiceAccountToken: false` - Service account tokens **NOT** automatically mounted
✅ Tokens only mounted if explicitly needed by application
✅ Prevents token exposure if pod is compromised

### Container Security Context

✅ `runAsNonRoot: true` - Container runs as UID 1000 (non-root user)
✅ `readOnlyRootFilesystem: true` - Root filesystem is read-only, prevents malware persistence
✅ `allowPrivilegeEscalation: false` - Prevents privilege escalation attacks
✅ `capabilities: drop: ALL` - Removes all Linux capabilities, only NET_BIND_SERVICE kept

### RBAC (Role-Based Access Control)

✅ Dedicated `blogging-app` service account with minimal permissions
✅ Role only permits: reading pod status, reading configmaps (if needed)
✅ **No permissions to**: create pods, modify resources, access secrets, or interact with other namespaces

### Network Policy

✅ Default-deny ingress and egress (only allow whitelisted traffic)
✅ Allows traffic only from LoadBalancer service and kube-system
✅ Allows egress only to: DNS (UDP 53), HTTPS external (TCP 443), pod-to-pod (TCP 8080)
✅ Prevents lateral movement if pod is compromised

### Mitigations Against SonarQube Report Risks

| Risk                     | Mitigation                                                                                 |
| ------------------------ | ------------------------------------------------------------------------------------------ |
| **Unauthorized Access**  | `automountServiceAccountToken: false` + RBAC role with minimal permissions                 |
| **Privilege Escalation** | `allowPrivilegeEscalation: false` + `runAsNonRoot: true` + capability dropping             |
| **Data Breach**          | Service account has no permissions to read secrets or configmaps containing sensitive data |
| **Denial of Service**    | Network policy + CPU/memory limits prevent resource exhaustion                             |

- **Memory Requests**: 512Mi (guaranteed)
- **Memory Limits**: 1Gi (maximum)
- **Liveness Probe**: HTTP GET / (30s delay, 10s interval)
- **Readiness Probe**: HTTP GET / (10s delay, 5s interval)
