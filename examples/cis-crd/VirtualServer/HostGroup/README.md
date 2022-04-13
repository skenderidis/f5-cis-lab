# Virtual Server with Host Group


The Multi-host feature allows CIS to support a single HTTP VirtualServer on BIG-IP for different hostnames. This is similar to how OpenShift routes work today. The benefit of using the multi-host feature is the ability to reuse the same IP Address on BIG-IP.
You can configure VirtualServer CRD using the hostGroup parameter to club virtual servers with different hostnames into one in BIG-IP.

## virtual-with-hostGroup.yaml

This section demonstrates the option to configure virtual server using Host Group to club virtual servers with different host names into one in VIP. 

Eg: virtual-with-hostGroup.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: app2-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: app1.f5demo.local
  virtualServerAddress: "10.1.10.100"
  virtualServerName: "hostgroup-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app1-svc
      servicePort: 8080
---
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: app2-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: app2.f5demo.local
  virtualServerAddress: "10.1.10.100"
  virtualServerName: "hostgroup-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app2-svc
      servicePort: 8080

```
By deploying the above 2 VirtualServer CRDs in your cluster, CIS will create a single HTTP Virtual Server (with VIP `10.1.10.100`) on the BIG-IP system with different hostnames (in this example, `app1.f5demo.local` and `app2.f5demo.local`) since both VS CRDs share the same hostGroup property.

Create the VS CRD resources. 
```
kubectl apply -f virtual-with-hostGroup.yml
```

Confirm that both VS CRDs is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Try accessing the service as per the example below. 
```
curl http://test.f5demo.local/ --resolve test.f5demo.local:80:10.1.10.100

```
In the above example you should see a reset connection as it didnt match the configured Host parameter.
`curl: (56) Recv failure: Connection reset by peer`


Try again with the examples below
```
curl http://app1.f5demo.local/ --resolve app1.f5demo.local:80:10.1.10.100
curl http://app2.f5demo.local/ --resolve app2.f5demo.local:80:10.1.10.100

```

Verify that the traffic was forwarded to the `app1-svc` and `app2-svc` services as per the Hostname.


## virtual-with-hostGroup-ipam.yaml

In this example we are using again hostGroup to club Virtual Servers together but we are using `ipamLabel` insted of `virtualServerAddress` in order to create a VirtualServer IP.

Eg: virtual-with-hostGroup-ipam.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: ipam1-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: ipam1.f5demo.local
  ipamLabel: "Dev"
  virtualServerName: "hostgroup-ipam-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app1-svc
      servicePort: 8080
---
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: ipam2-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: ipam2.f5demo.local
  ipamLabel: "Dev"
  virtualServerName: "hostgroup-ipam-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app2-svc
      servicePort: 8080
```


Create the VS CRD resources. 
```
kubectl apply -f virtual-with-hostGroup-ipam.yml
```

Confirm that both VS CRDs is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Save the IP adresses that was assigned by the IPAM for this VirtualServer

Try accessing the serviceas per the examples below. 
```
curl http://ipam1.f5demo.local/ --resolve ipam1.f5demo.local:80:<IP Address assigned by IPAM>
curl http://ipam2.f5demo.local/ --resolve ipam2.f5demo.local:80:<IP Address assigned by IPAM>

```

Verify that the traffic was forwarded to the `app1-svc` and `app2-svc` services as per the Hostname.

