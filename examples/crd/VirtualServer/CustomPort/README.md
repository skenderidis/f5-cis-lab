# Secure Virtual Server with Re-encrypt Termination using BIG-IP Profiles

This section demonstrates the option to configure VirtualAddress with custom HTTP/HTTPS port numbers.  
For this example section CIS will create a Virtual Server on BIG-IP with custom port (8080). To achieve this we will add `virtualServerHTTPPort` parameter on the VirtualServer resource with the port that we want BIGIP VIP to listen to. 

Eg: reference-vs.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: custom-port-http-vs
  labels:
    f5cr: "true"
spec:
  host: custom.f5demo.local
  virtualServerAddress: "10.1.10.114"
  virtualServerName: "custom-port-http-vs"
  virtualServerHTTPPort: 8080
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```


* for HTTPS VirtualServer the parameter name is `virtualServerHTTPSPort` 


