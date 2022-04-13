# Virtual Server Examples

In this section we provide 4 Virtual Server deployment examples

- [Create a simple HTTP Virtual Server without Host parameter](#create-a-simple-http-virtual-server-without-host-parameter)
- [Create a simple HTTP Virtual Server with Host parameter and a single pool](#create-a-simple-http-virtual-server-with-host-parameter-and-a-single-pool)
- [Create a simple HTTP Virtual Server with Host parameter and two pools](#create-a-simple-http-virtual-server-with-host-parameter-and-two-pools)



## Create a simple HTTP Virtual Server without Host parameter.

This section demonstrates the deployment of a Basic Virtual Server without Host Parameter.

Eg: noHost.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: noHost
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.90"
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```

Create the VS CRD resource. 
```
kubectl apply -f noHost.yml
```
CIS will create a Virtual Server on BIG-IP with VIP "10.1.10.90" and attaches a policy which forwards all traffic to service echo-svc.   


Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Access the service as per the examples below. 

```
curl http://10.1.10.90 
curl http://10.1.10.90/test.php
curl http://test.f5demo.local --resolve test.f5demo.local:80:10.1.10.90
```

In all cases you should be able to access the service running in K8s.




## Create a simple HTTP Virtual Server with Host parameter and a single pool.

This section demonstrates the deployment of a Virtual Server with a single service as the pool.
The virtual server should send traffic for all paths to the same pool.

Eg: virtual-single-pool.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: single-pool-vs
  labels:
    f5cr: "true"
spec:
  host: app1.f5demo.local
  virtualServerAddress: "10.1.10.91"
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```

Create the VS CRD resource. 
```
kubectl apply -f virtual-single-pool.yml
```
CIS will create a Virtual Server on BIG-IP with VIP `10.1.10.90` and attaches a policy which forwards all traffic to pool echo-svc when the Host Header is equal to `app1.f5demo.local`.   


Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Try accessing the service with curl as per the examples below. 
```
curl http://10.1.10.91
curl http://app5.f5demo.local --resolve app5.f5demo.local:80:10.1.10.91
```

In all the above examples you should see a reset connection as it didnt match the configured Host Header.
`curl: (56) Recv failure: Connection reset by peer`

Try again with the examples below
```
curl http://app1.f5demo.local --resolve app1.f5demo.local:80:10.1.10.90
curl http://app1.f5demo.local/test --resolve app1.f5demo.local:80:10.1.10.90
```

In both cases you should be able to access the service running in K8s.



## Create a simple HTTP Virtual Server with Host parameter and two pools.

This section demonstrates the deployment of a Virtual Server with 2 services as the pools.
The virtual server should send traffic to the corresponding K8s service, according to the URI Path. In the following example traffic with URI Path `/lib` will be forwarded to service `app1-svc` while traffic with URI Path `/portal` will be forwarded to `app2-svc`. Traffic on all other URI Paths will be dropped. 

Eg: virtual-two-pools.yml

```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: two-pools-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.92"
  host: pools.f5demo.local
  pools:
  - path: /svc1
    service: app1-svc
    servicePort: 8080
  - path: /svc2
    service: app2-svc
    servicePort: 8080    
```

Create the VS CRD resource. 
```
kubectl apply -f virtual-two-pools.yml
```
CIS will create a Virtual Server on BIG-IP with VIP `10.1.10.92` and attaches a policy which forwards traffic to service app1-svc or app2-svc depending on the URI path.   


Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Try accessing the service with curl as per the examples below. 
```
curl http://pools.f5demo.local/ --resolve pools.f5demo.local:80:10.1.10.92

```
In the above example you should see a reset connection as it didnt match the configured URI Path.
`curl: (56) Recv failure: Connection reset by peer`



Try again with the examples below
```
curl http://pools.f5demo.local/svc1 --resolve pools.f5demo.local:80:10.1.10.92
curl http://pools.f5demo.local/svc2 --resolve pools.f5demo.local:80:10.1.10.92
```

Verify that the traffic was forwarded to the right service depending on the path that was entered.


## Create a HTTP Virtual Server with wildcard Host parameter.

This section demonstrates the deployment of a Virtual Server with wildcard Host parameter.
The virtual server should send traffic to the backend service if the Host Header matches the wildcard value configured on the Host parameter.

Eg: virtual-wildcardhost.yml

```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: wildcard-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.93"
  host: "*.f5demo.local"
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```

Create the VS CRD resource. 
```
kubectl apply -f virtual-wildcardhost.yml
```
CIS will create a Virtual Server on BIG-IP with VIP `10.1.10.93` and attaches a policy which forwards traffic to service `echo-svc` if the Host Header matches `*.f5demo.local`.   


Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Try accessing the service with curl as per the examples below. 
```
curl http://test.example.local/ --resolve test.example.local:80:10.1.10.93

```
In the above example you should see a reset connection as it didnt match the configured Host parameter.
`curl: (56) Recv failure: Connection reset by peer`


Try again with the examples below
```
curl http://test1.f5demo.local/ --resolve test1.f5demo.local:80:10.1.10.93
curl http://test2.f5demo.local/ --resolve test2.f5demo.local:80:10.1.10.93
...
...
curl http://test10.f5demo.local/ --resolve test10.f5demo.local:80:10.1.10.93

```

Verify that you traffic was forwarded to the `echo-svc` service on both tests.

