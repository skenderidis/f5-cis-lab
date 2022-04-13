# Rewrite Examples

In this section we provide 4 Virtual Server deployment examples

- [TLS Ingress (certificate on K8s)](#tls-ingress-certificate-on-k8s)
- [TLS Ingress (certificate on BIGIP)](#tls-ingress-certificate-on-bigip)
- [Multi-TLS Ingress (certificate on BIGIP)](#multi-tls-ingress-certificate-on-bigip)



## App Root Rewrite (rewriteAppRoot)
Redirecting the application to specific path when request made with root path "/".
The path changes, but the pool with path "/" gets served.

Eg: approot.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: approot-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.95"
  rewriteAppRoot: /home
  host: approot.f5demo.local
  pools:
    - path: /
      service: app1-svc
      servicePort: 8080
```

Create the CRD resource.
```
kubectl apply -f approot.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Access the service using curl. 
```
curl -v http://approot.f5demo.local/ --resolve approot.f5demo.local:80:10.1.10.95
```

Note that on the first example we receive a 302 redirect from BIGIP to /home while on the second example the path is rewritten from `/lib` to `/library`



## Path Rewrite (rewrite)
Rewriting the path in HTTP Header of a request before submitting to the pool

Eg: rewrite.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: rewrite-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.96"
  host: rewrite.f5demo.local
  pools:
    - path: /lab
      service: svc-1
      servicePort: 8080
      rewrite: /laboratory
    - path: /lib
      service: svc-2
      servicePort: 8080
      rewrite: /library
```


Create the CRD resource.
```
kubectl apply -f rewrite.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Access the service using curl. 
```
curl http://rewrite.f5demo.local/lab --resolve rewrite.f5demo.local:80:10.1.10.96
curl http://rewrite.f5demo.local/lib --resolve rewrite.f5demo.local:80:10.1.10.96
```

Note that the paths are rewritten from `/lib` to `/library` and from `/lab` to `/laboratory`
