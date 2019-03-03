## etcd-sts-operator

This project stems from [etcd-ansible-operator](https://github.com/water-hole/etcd-ansible-operator). It is an effort to implement a POC operator for using `stateful sets` to deploy etcd, with a wider objective of using it in the original [etcd-operator](https://github.com/coreos/etcd-operator).

### Pre-requisites for trying it out:

A kubernetes cluster deployed with `kubectl` correctly configured. [Minikube](https://github.com/kubernetes/minikube/) is the easiest way to get started.

The stateful sets use persistent volumes, the cluster needs to be configured with a dynamic persistent volume provisioner. In case of minikube, the guidelines can be found [here](https://github.com/kubernetes/minikube/blob/master/docs/persistent_volumes.md)

### Steps to bring an etcd cluster up

To follow this guide, make sure you are in the `default` namespace.

1. Create RBAC `kubectl create -f https://raw.githubusercontent.com/alaypatel07/etcd-sts-operator/master/deploy/rbac.yaml`
2. Create CRD `kubectl create -f https://raw.githubusercontent.com/alaypatel07/etcd-sts-operator/master/deploy/crd.yaml`
3. Deploy the operator `https://raw.githubusercontent.com/alaypatel07/etcd-sts-operator/cfa861a9c2e408ab90d578606e2b9a1e32e48b78/deploy/operator.yaml`
4. Create an etcd cluster `kubectl create -f https://raw.githubusercontent.com/alaypatel07/etcd-sts-operator/master/deploy/cr.yaml`
5. Verify that cluster is up by `kubectl get pods -l app=etcd`. You should see something like this
    ```
    $ kubectl get pods -l app=etcd
    NAME                     READY   STATUS    RESTARTS   AGE
    example-etcd-cluster-0   1/1     Running   0          27s
    example-etcd-cluster-1   1/1     Running   0          21s
    example-etcd-cluster-2   1/1     Running   0          18s
    ```

### Accessing the etcd cluster

If you are using minikube:

1. Create a service to access etcd cluster from outside the cluster by `kubectl create -f https://raw.githubusercontent.com/coreos/etcd-operator/master/example/example-etcd-cluster-nodeport-service.json`
2. Install [etcdctl](https://coreos.com/etcd/docs/latest/getting-started-with-etcd.html)
3. Set etcd version `export ETCDCTL_API=3`
4. Set etcd endpoint `export ETCDCTL_ENDPOINTS=$(minikube service example-etcd-cluster-client-service --url)`
5. Set a key in etcd `etcdctl put hello world`

If you are inside the cluster, set the etcd endpoint to: `http://<cluster-name>-client.<namespace>.svc:2379` and it should work. If you are using secure client, use `https` protocol for the endpoint.

### Check failure recovery

Recovering from loss of all the pods is the key purpose behind the idea of using stateful set to deploy etcd. Here are the steps to check it out:


1. Bring an etcd cluster up.
2. Insert some data into the etcd cluster `$etcdctl put hello world`
3. Watch members of etcd cluster by running `watch etcdctl member list` in a separate terminal. You need to export environment variables(ETCDCTL_ENDPOINTS)
4. Delete all the pods to simulate failure recovery `$kubectl delete pod -l app=etcd `
5. Within sometime, you should see all the pods going away and being replaced by a new pods, something like this.
6. After sometime, the cluster will be available again. 
7. Check if the data exists:
```
$ etcdctl get hello
hello
world
```

### Delete a cluster
1. Bring a cluster up.
2. Delete the cluster by `kubectl delete etcdcluster example-etcd-cluster`. This should delete all the pods and services created because of this cluster       