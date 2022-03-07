# Ingress Examples

In this section we provide examples for the most common use-cases of Ingress Resources with F5 CIS

- [Basic-Ingress](#Basic-Ingress)
- [FQDN-Based-Routing](#FQDN-Based-Routing)
- [FanOut/Path-Based-Routing](#FanOut/Path-Based-Routing)
- [Use-cases](#use-cases)
- [Variables](#variables)

Before starting with the examples below, please make sure of the following:

-- Apps are running on the default namespace. --
```
kubectl apply -f basic-ingress.yml
```

-- CIS is running --
