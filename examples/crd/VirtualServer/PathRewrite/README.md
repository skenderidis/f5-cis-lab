# App Root Rewrite (rewriteAppRoot)
Redirecting the application to specific path when request made with root path "/".
The path changes, but the pool with path "/" gets served.

Eg: rewriteAppRoot
```
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: approot-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.91"
  rewriteAppRoot: /home
  host: approot.example.com
  pools:
    - path: /
      service: app1-svc
      servicePort: 80
    - path: /lib
      service: app2-svc
      servicePort: 80
      rewrite: /library
```

Create the CRD resource.
```
kubectl apply -f approot.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```


Access the service as per the examples below. 

```
curl http://test.f5demo.local --resolve test.f5demo.local:80:10.1.10.90
```

In all cases you should be able to access the service running in K8s.

# Path Rewrite (rewrite)
Rewriting the path in HTTP Header of a request before submitting to the pool

Eg: rewrite
```
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: college-virtual-server
  labels:
    f5cr: "true"
spec:
  # This is an insecure virtual, Please use TLSProfile to secure the virtual
  # check out tls examples to understand more.
  virtualServerAddress: "172.16.3.6"
  host: collage.example.com
  pools:
    - path: /lab
      service: svc-1
      servicePort: 80
      rewrite: /laboratory
    - path: /lib
      service: svc-2
      servicePort: 80
      rewrite: /library
```

Eg: Combination of both
```
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: college-virtual-server
  labels:
    f5cr: "true"
spec:
  # This is an insecure virtual, Please use TLSProfile to secure the virtual
  # check out tls examples to understand more.
  virtualServerAddress: "172.16.3.6"
  rewriteAppRoot: /home
  host: collage.example.com
  pools:
    - path: /
      service: svc-1
      servicePort: 80
      rewrite: /index
    - path: /lib
      service: svc-2
      servicePort: 80
      rewrite: /library

```
