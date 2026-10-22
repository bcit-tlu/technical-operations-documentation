# Managing clusters

There are several Kubernetes dashboards available ([k8s-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/), [k9s](https://k9scli.io/), [headlamp](https://headlamp.dev/), [skooner](https://skooner.io/)), but we have found that [Rancher Manager](https://ranchermanager.docs.rancher.com/) continues to be one of the best; it is free, efficient, performant, and receives regular updates from a reputable organization ([SUSE](https://www.rancher.com/products/rancher-platform)).

## Headlamp on the Talos clusters

Headlamp authenticates to a cluster with a service-account bearer token pasted into the UI. This works identically on Talos clusters — there is nothing Talos-specific about it — but token auth requires an existing admin kubeconfig context (e.g. `admin@tlu-c01`, created by `talosctl kubeconfig`).

### One-time setup per cluster

```bash
kubectl --context admin@tlu-c01 -n kube-system create serviceaccount headlamp-admin
kubectl --context admin@tlu-c01 create clusterrolebinding headlamp-admin \
  --clusterrole=cluster-admin --serviceaccount=kube-system:headlamp-admin
```

!!! warning "Namespace must match"

    The `--serviceaccount=<namespace>:<name>` subject in the binding must match the namespace where the service account actually lives. A binding pointing at `headlamp:headlamp-admin` silently grants nothing to a `kube-system:headlamp-admin` token — the symptom is a successful login with zero permissions in the UI.

### Per-login token

```bash
kubectl --context admin@tlu-c01 -n kube-system create token headlamp-admin --duration=1h
```

Paste the printed token into Headlamp with `tlu-c01` selected. Mint a fresh token each login — keep the TTL short.

### Verify before pasting

```bash
kubectl --context admin@tlu-c01 auth can-i get pods \
  --as=system:serviceaccount:kube-system:headlamp-admin   # expect: yes
```

To test a token exactly as Headlamp uses it — as a Bearer token against the API, with no client cert:

```bash
TOKEN=$(kubectl --context admin@tlu-c01 -n kube-system create token headlamp-admin --duration=1h)
kubectl config view --raw \
  -o jsonpath='{.clusters[?(@.name=="tlu-c01")].cluster.certificate-authority-data}' \
  | base64 -d > /tmp/tlu-c01-ca.crt
kubectl --server=https://k8s-api.tlu-c01.tlu.bcit.ca:6443 \
  --certificate-authority=/tmp/tlu-c01-ca.crt --token="$TOKEN" auth whoami
# expect Username: system:serviceaccount:kube-system:headlamp-admin
```

!!! warning "Don't test tokens via `--context`"

    `kubectl --context admin@tlu-c01 --token="$TOKEN" ...` still sends the context's embedded client certificate, which wins over `--token` — `auth whoami` reports `admin`, not the service account. Use `--server`/`--certificate-authority`/`--token` without a context, as above.

!!! info "Cluster-admin scope"

    `cluster-admin` is convenient for nonprod (`latest`). For `stable` clusters, prefer a read-only `ClusterRole` (e.g. bound to `view`) over cluster-admin tokens.

## Empty CPU/Memory columns in Headlamp

Headlamp's CPU/Memory columns — and `kubectl top` — read from the `metrics.k8s.io` API, which is served by [metrics-server](https://github.com/kubernetes-sigs/metrics-server). Neither Kubernetes nor Talos ships metrics-server by default; if the columns are blank and `kubectl top nodes` reports "Metrics API not available", it isn't installed yet.

Talos-specific caveat: kubelet serving certificates are signed by a **per-node Talos CA**, not the Kubernetes cluster CA, so metrics-server cannot verify them with the standard CA bundle. Deploy it with `--kubelet-insecure-tls` (per SideroLabs guidance). Node metrics should be delivered through `flux-fleet-v2`'s observability tier rather than installed by hand.
