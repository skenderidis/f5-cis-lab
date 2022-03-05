#Ingress Examples

This example demonstrates how to achieve session affinity using cookies.


## Basic Ingress
The following example deploys a basic ingress resource for a single service.

```
kubectl apply -f basic-ingress.yml
```

You can confirm that the Ingress works:

```
kubectl describe ing basic-ingress
```

You should see that following output. Notice that the value for Host and Path (marked in red) is *. 

You can access the service with the use of curl on the IP address assigned for the ingress. 

```
curl http://10.1.10.40
curl http://10.1.10.40/test.php
```
In both cases you should see that following output:



## FQDN Based Routing
The following example deploys an ingress resource that routes based on FQDN:
fqdn1.f5demo.local => app1-svc
fqdn2.f5demo.local => app2-svc


```
kubectl apply -f fqdn-based-routing.yml
```

You can confirm that the Ingress works:

```
kubectl describe ing fqdn-based-routing
```

You should see that following output. Notice that the values (marked in red) for Host is now defined ("fqdn1.f5demo.local" / "fqdn2.f5demo.local").

Try accessing the service with the use of curl on the IP address assigned for the ingress. 

```
curl http://10.1.10.14
```
You should see a reset connection as it didnt match the configured Host Header.

Try again with either of the 2 following options

```
curl -H "Host: fqdn1.f5demo.local" http://10.1.10.50/
curl -H "Host: fqdn2.f5demo.local"  http://10.1.10.50/
```

In both cases you should see that similar output but from different backend pods (app1 and app2 pods):


Note: Since we didn't define Host value on the Ingress resource, we can access the service regardless the Host Header Value (even IP address)



## FanOut (Path based routing)
The following example deploys an ingress resource that routes based on the uri path:
fanout.f5demo.local/app1 => app1-svc
fanout.f5demo.local/app2 => app2-svc


```
kubectl apply -f fanout.yml
```

You can confirm that the Ingress works:

```
kubectl describe ing fanout
```

You should see that following output. Notice that the values (marked in red) for Host is now defined "fanout.f5demo.local" and on the Path there are 2 entries; "app1" that points to app1-svc and "/app2" that points to app2-svc.

Try accessing the service with the use of curl on a path that has not been defined on the Ingress spec.

```
curl -H "Host: fanout.f5demo.local"  http://10.1.10.50/test/index.php
```

You should see a reset connection as it didnt match the configured Path value.

Try again with either of the 2 following options

```
curl -H "Host: fanout.f5demo.local" http://10.1.10.50/app1/index.php
curl -H "Host: fanout.f5demo.local" http://10.1.10.50/app2/index.php
curl -H "Host: fanout.f5demo.local" http://10.1.10.50/app1
curl -H "Host: fanout.f5demo.local"  http://10.1.10.50/app2
```

In all cases you should see that similar output but from different backend pods (app1 and app2 pods) depending on the path:



## Health Monitors
The following example deploys 2 health monitors to verify that the backend services are working properly.

"HTTP GET /health/echo" => health-monitor-1
"HTTP GET /health/myapp" => health-monitor-2


```
kubectl apply -f health-monitor.yml
```

You can confirm that the Ingress works:

```
kubectl describe ing health-monitor
```

You should see that following output. Notice that on the annotation section the health monitors have been defined.


On the BIGIP UI, you should see the pools marked in green


## AppRoot Rewrite
The following example deploys an ingress resource with rewrite-app-root annotation that will redirect any traffic for root path "/" to path "/approot1"

http://rewrite1.f5demo.local/ => http://rewrite1.f5demo.local/approot1


```
kubectl apply -f rewrite-app-root.yml
```

Try accessing the service with the use of curl as the example below

```
curl -H "Host: rewrite1.f5demo.local" http://10.1.10.50/
```

You should see that the path that was send on the backend application has been changed from "/" to "/approot1" following output:
Similarly if accessing the service rewrite2.f5demo.local the path will change to "approot2"




## URL Rewrite
The following example rewrites the URL of a service from "lab.f5demo.local/mylab" to "laboratory.f5demo.local/mylaboratory"

```
kubectl apply -f url-rewrite-ingress.yml
```


Try accessing the service with the use of curl as the example below

```
curl -H "Host: lab.f5demo.local" http://10.1.10.50/mylab
```


You should see that the Hostname and Path that was send on the backend application has been changed as per the Ingress Annotation.




## TLS Ingress (certificate on K8s)
The following example deploys an basic TLS ingress resource that has the certificate stored on K8s.

First we deploy the secret that holds the certificate
```
kubectl apply -f apps-tls-secret.yml
```

Then create the ingress resource
```
kubectl apply -f tls-cert-k8s.yml
```

Try accessing the service with the use of curl as the example below

```
curl -vk https://tls-k8s.f5demo.local --resolve tls-k8s.f5demo.local:443:10.1.10.13
```

You should see that following output:


#We'll use curl's -k option to turn off certificate verification of our self-signed certificate and the -v option to get the TLS certificate details



## TLS Ingress (certificate on BIGIP)
The following example deploys an basic TLS ingress resource that has the certificate stored on BIGIP as a SSL Client Profile.

First please verify that the SSLclient Profile exists (see below)


Then create the ingress resource
```
kubectl apply -f tls-cert-bigip.yml
```

Try accessing the service with the use of curl as the example below

```
curl -vk https://tls1.f5demo.local --resolve tls1.f5demo.local:443:10.1.10.13
```

You should see that following output:


#We'll use curl's -k option to turn off certificate verification of our self-signed certificate and the -v option to get the TLS certificate details




## TLS Ingress (certificate on BIGIP)
The following example deploys an ingress resource with 2 FQDNs that require different TLS certificates (stored on BIGIP).

First please verify that both SSLclient Profile exists (see below). 

One of the certificates (in this case tls1) has to be the SNI default profile. Please select the tls1 profile and verify the configuration (marked in RED)


Create the ingress resource
```
kubectl apply -f multi-tls-cert-bigip.yml
```

Try accessing both services with the use of curl examples below

```
curl -vk https://tls1.f5demo.local --resolve tls1.f5demo.local:443:10.1.10.13
curl -vk https://tls2.f5demo.local --resolve tls2.f5demo.local:443:10.1.10.13
```

You should see that following output. Notice on tls2.f5demo.local the certificate is the tls2. You can see it from the CN values.


#We'll use curl's -k option to turn off certificate verification of our self-signed certificate and the -v option to get the TLS certificate details








curl -vk https://tls1.f5demo.local --resolve tls1.f5demo.local:443:10.1.10.13

