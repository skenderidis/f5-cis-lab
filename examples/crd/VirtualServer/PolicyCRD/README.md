# PolicyCRD Examples

This section demonstrates the deployment of a Virtual Server with custom TCP, HTTP and WAF Profiles with PolicyCRD.

- [TLS Ingress (certificate on K8s)](#tls-ingress-certificate-on-k8s)
- [TLS Ingress (certificate on BIGIP)](#tls-ingress-certificate-on-bigip)

## PolicyCRD XFF
This section demonstrates the deployment of a Virtual Server with a custom HTTP Profiles that add XFF header.

Eg: policy-vs /policy-crd 
```yml
apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: policy-xff
spec:
  profiles:
    http: /Common/http-xff
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: xff-policy-vs
spec:
  virtualServerAddress: 10.1.10.96
  host: policy.f5demo.local
  policyName: policy-xff
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Create the PolicyCRD and VirtualServerCRD resources.
```
kubectl apply -f xff-policy.yml
kubectl apply -f vs-with-policy-xff.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

On the BIGIP we created a profile called `http-xff` that adds the client IP as an HTTP header (x-forwarded-for) before forading the transaction to the backend.

Access the service using the following example. 
```
curl -v http://policy.f5demo.local/ --resolve policy.f5demo.local:80:10.1.10.96
```

Verify that the `x-forwarded-for` Header exists and contains the client's actual IP



## PolicyCRD WAF
This section demonstrates the deployment of a Virtual Server with a WAF policy to protect against Layer 7 threats.

Eg: VirtualServer / PolicyCRD 
```yml
apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: waf-policy
spec:
  l7Policies:
    waf: /Common/basic_waf_policy
  profiles:
    http: /Common/http-XFF
    logProfiles:
      - /Common/Log all requests
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: waf-policy-vs
spec:
  virtualServerAddress: 10.1.10.98
  host: policy.f5demo.local
  policyName: waf-policy
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Create the PolicyCRD and VirtualServerCRD resource.
```
kubectl apply -f waf-policy.yml
kubectl apply -f vs-with-policy-waf.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

On the BIGIP we created a WAF profile to block HTTP attacks, so we expect BIGIP to mitigate any L7 attack (according to the WAF policy) that is executed to the services running in K8S.

Access the service using the following example. 
```
curl -v "http://policy.f5demo.local/index.php?parameter=<script/>" --resolve policy.f5demo.local:80:10.1.10.98
```

Verify that the second transaction that contains the attacks gets blocked by BIGIP WAF.



