# Health Monitor

This section demonstrates the option to configure health monitor for pools in virtual server.
Heath monitor is supported for each pool members. 


Create the CRD resource.
```
kubectl apply -f health-monitor.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

On the BIGIP UI, you should see the application pool marked as green and a custom monitor assigned to the pool

| BIGIP Pool             |  Pool Details |
:-------------------------:|:-------------------------:
![health-monitor-bigip-1](images/health-monitor-bigip-1.png)  |  ![health-monitor-bigip-2](images/health-monitor-bigip-2.png)


