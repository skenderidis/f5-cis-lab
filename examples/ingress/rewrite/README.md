# Ingress Examples

In this section we provide examples for the most common use-cases of Ingress Resources with F5 CIS

- [Basic-Ingress](#Basic-Ingress)
- [FQDN-Based-Routing](#FQDN-Based-Routing)
- [FanOut/Path-Based-Routing](#FanOut/Path-Based-Routing)
- [Use-cases](#use-cases)
- [Variables](#variables)

## AppRoot Rewrite
The following example deploys an Ingress resource with rewrite-app-root annotation that will redirect any traffic for the root path `/` to `/approot1`

__http://rewrite1.f5demo.local/ => http://rewrite1.f5demo.local/approot1__

Create the Ingress resource
```
kubectl apply -f rewrite-app-root.yml
```

Try accessing the service with the use of curl as per the examples below

```
curl -v http://rewrite1.f5demo.local/ --resolve rewrite1.f5demo.local:80:10.1.10.50
curl -v http://rewrite2.f5demo.local/ --resolve rewrite2.f5demo.local:80:10.1.10.50
```

You should see that the path that was send on the backend application has been changed from `/` to `/approot1`.
Similarly if accessing the service `rewrite2.f5demo.local` the path will change to `approot2`

![approot-rewrite-output](images/approot-rewrite-output.png)


## URL Rewrite
The following example deploys an Ingress resource that rewrites the URL from `lab.f5demo.local/mylab` to `laboratory.f5demo.local/mylaboratory`

Create the Ingress resource
```
kubectl apply -f url-rewrite-ingress.yml
```

Try accessing the service with the use of curl as the example below

```
curl http://lab.f5demo.local/mylab --resolve lab.f5demo.local:80:10.1.10.50
```

You should see that the Hostname and Path that was send on the backend application has been changed as per the Ingress resource configuration.

![url-rewrite-output](images/url-rewrite-output.png)

