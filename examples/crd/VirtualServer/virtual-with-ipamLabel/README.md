# Virtual Server with IPAM Label

This section demonstrates the option to configure virtual server using IPAM label to manage the virtual server address. 
In order for the `ipamLabel` to provide an IP address, you need to have a F5 IPAM controller running and with the defined Labels/IP-ranges.

First lets verify that the IPAM is running.

```
kubectl get po -n kube-system | grep f5ipam

**************** Expected Result ****************
NAME                                      READY   STATUS    RESTARTS       AGE
f5ipam-5bf9fbdb5-dzqwd                    1/1     Running   12 (39h ago)   18d
```

Review the IPAM IP ranges.

```
kubectl -n kube-system describe deployment f5ipam

**************** Expected Result ****************
...
...
    Command:
      /app/bin/f5-ipam-controller
    Args:
      --orchestration=kubernetes
      --ip-range='{"Dev":"10.1.10.181-10.1.10.190","Prod":"10.1.10.191-10.1.10.200"}'
      --log-level=DEBUG
...
...
```


Create the VS CRD resources. 
```
kubectl apply -f virtual-with-ipamLabel.yml
```

Confirm that the VS CRDs is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```
Save the IP adresses that was assigned by the IPAM for this VirtualServer

Try accessing the service as per the example below. 
```
curl http://ipam.f5demo.local/ --resolve ipam.f5demo.local:80:<IP Address assigned by IPAM>
```

