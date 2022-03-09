# Create a simple HTTP Virtual Server without Host parameter.

This section demonstrates the deployment of a Basic Virtual Server without Host Parameter.


By deploying this yaml file in your cluster,


# Basic-Ingress
In the following example we deploy a basic ingress resource for a single K8s service.

Create the Ingress resource. 
```
kubectl apply -f noHost.yml
```
CIS will create a Virtual Server on BIG-IP with VIP "10.1.10.90" and attaches a policy which forwards the traffic to pool echo-svc when the uri path segment is******  /.   


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

