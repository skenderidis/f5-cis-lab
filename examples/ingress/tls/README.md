# Ingress Examples

In this section we provide 3 examples for the most common use-cases of TLS Ingress resources

- [Basic-Ingress](#Basic-Ingress)
- [FQDN-Based-Routing](#FQDN-Based-Routing)
- [FanOut/Path-Based-Routing](#FanOut/Path-Based-Routing)
- [Use-cases](#use-cases)
- [Variables](#variables)


## TLS Ingress (certificate on BIGIP)
The following example deploys a TLS ingress resource that has the certificate stored on BIGIP as a SSL Client Profile.

Verify that the SSL Client Profile exists (see below)

![certificates-bigip](images/certificates-bigip.png)

Create the Ingress resource
```
kubectl apply -f tls-cert-bigip.yml
```

Try accessing the service with the use of curl as the example below

```
curl -vk https://tls1.f5demo.local --resolve tls1.f5demo.local:443:10.1.10.52
```

You should see the following output. Please notice the `CN` value configured on the certificate. We use curl's -k option to turn off certificate verification and the -v option to get the TLS certificate details

![tls-ingress-bigip](images/tls-ingress-bigip.png)


## TLS Ingress (certificate on BIGIP)
The following example deploys an ingress resource with 2 FQDNs that require different TLS certificates (stored on BIGIP).

Verify that both SSL Client Profile exists (see below). 
![certificates-bigip](images/certificates-bigip.png)

One of the certificates (in this case tls1) has to be the SNI default profile. Please select the tls1 profile and verify the configuration (marked in RED)


Create the ingress resource
```
kubectl apply -f multi-tls-cert-bigip.yml
```

Try accessing both services with the use of curl as per the examples below. We use curl's -k option to turn off certificate verification and the -v option to get the TLS certificate details

```
curl -vk https://tls1.f5demo.local --resolve tls1.f5demo.local:443:10.1.10.53
curl -vk https://tls2.f5demo.local --resolve tls2.f5demo.local:443:10.1.10.53
```

You should see the following output. Notice that the `CN` value change based on the FQDN as a different certificate gets presented to the client.

![multi-tls-ingress-bigip](images/multi-tls-ingress-bigip.png)