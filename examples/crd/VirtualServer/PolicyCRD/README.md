# Policy CRD
This section demonstrates the deployment of a Virtual Server with customer TCP, HTTP and WAF Profiles.

Eg: policy-vs /policy-crd 
```yml
apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: policy-crd
spec:
  l7Policies:
    waf: /Common/WAF_Policy
  profiles:
    tcp: /Common/f5-tcp-wan
    http: /Common/http
    logProfiles:
      - /Common/local-waf
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: policy-vs
spec:
  virtualServerAddress: 10.1.10.96
  host: policy.f5demo.local
  policyName: policy-crd
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80

```

Create the PolicyCRD and VirtualServerCRD resource.
```
kubectl apply -f policy.yml
kubectl apply -f vs-with-policy.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

On the BIGIP HTTP Profile that was assigned with the PolicyCRD we added a custom XFF header called (Client-IP). Therefore we would expect to see that header received by the backend service 

Access the service using curl. 
```
curl -v http://policy.f5demo.local/ --resolve policy.f5demo.local:80:10.1.10.96
```

Verify that the Cient-IP Header exists and contains the client's actual IP


Since a WAF profile is enabled through the PolicyCRD, lets send an attack (XSS) and see if it gets blocked 
```
curl -v "http://policy.f5demo.local/?parameter=<script/>" --resolve policy.f5demo.local:80:10.1.10.96
```

Verify that the transaction gets blocked. 


