## etcd-ansible-operator

This operator implements the [etcd-operator](https://github.com/coreos/etcd-operator/) using ansible and is run using [ansible-operator](https://github.com/water-hole/ansible-operator)

#### Steps to bring an etcd cluster up

1. Create rbac `kubectl create -f deploy/rbac.yaml`
2. Create crds `kubectl create -f deploy/crd/yaml`
3. Deploy the operator `kubectl create -f deploy/operator.yaml`
4. Create a cluster `kubectl create -f deploy/cr.yaml`
5. Verify that cluster is up by `kubectl get pods -l app=etcd`. You should see something like this
    ```
    $ kubectl get pods -l app=etcd
    NAME                              READY     STATUS    RESTARTS   AGE
    example-etcd-cluster-1a7d2c2f8b   1/1       Running   0          14m
    example-etcd-cluster-5afd8f00ce   1/1       Running   0          14m
    example-etcd-cluster-e43636bc7c   1/1       Running   0          14m
    ```

#### Scale cluster up

1. Bring a cluster up as discussed above
2. Edit the `deploy/cr.yaml` file as follows:

    ```
    apiVersion: "etcd.database.coreos.com/v1beta2"
    kind: "EtcdCluster"
    metadata:
      name: "example-etcd-cluster"
      ## Adding this annotation make this cluster managed by clusterwide operators
      ## namespaced operators ignore it
      # annotations:
      #   etcd.database.coreos.com/scope: clusterwide
    spec:
      size: 5
    #  TLS:
    #    static:
    #      member:
    #        peerSecret: etcd-peer-tls
    #        serverSecret: etcd-server-tls
    #      operatorSecret: etcd-client-tls
      version: "3.2.13"
    ```
   This shoudl scale up the cluster by 2 pods.

3. Apply the changes `kubectl apply -f deploy/cr.yaml`
4. Verify that the cluster has scaled up by `kubectl get pods -l app=etcd`. You should see something like this:
    ```
    $ kubectl get pods -l app=etcd
    NAME                              READY     STATUS    RESTARTS   AGE
    example-etcd-cluster-1a7d2c2f8b   1/1       Running   0          18m
    example-etcd-cluster-1c497c44c5   1/1       Running   0          29s
    example-etcd-cluster-5afd8f00ce   1/1       Running   0          18m
    example-etcd-cluster-a3f3b02a1b   1/1       Running   0          18s
    example-etcd-cluster-e43636bc7c   1/1       Running   0          18m
    ```
#### Accessing the etcd cluster

If you are using minikube:

1. Create a service to access etcd cluster from outside the cluster by `kubectl create -f https://raw.githubusercontent.com/coreos/etcd-operator/master/example/example-etcd-cluster-nodeport-service.json`
2. Install [etcdctl](https://coreos.com/etcd/docs/latest/getting-started-with-etcd.html)
3. Set etcd version `export ETCDCTL_API=3`
4. Set etcd endpoint `export ETCDCTL_ENDPOINTS=$(minikube service example-etcd-cluster-client-service --url)`
5. Set a key in etcd `etcdctl put hello world`

If you are inside the cluster, set the etcd endpoint to: `http://<cluster-name>-client.<namespace>.svc:2379` and it should work. If you are using secure client, use `https` protocol for the endpoint.


#### Check failure recovery
1. Bring a cluster up.
2. Delete a pod to simulate a failure `kubectl delete pod example-etcd-cluster-1a7d2c2f8b`
3. Within sometime, you should see the deleted pod going away and being replaced by a new pod, something like this:
    
    ```$ kubectl get pods -l app=etcd
       NAME                              READY     STATUS    RESTARTS   AGE
       example-etcd-cluster-1c497c44c5   1/1       Running   0          3m
       example-etcd-cluster-25f6bd225a   1/1       Running   0          8s
       example-etcd-cluster-5afd8f00ce   1/1       Running   0          21m
       example-etcd-cluster-a3f3b02a1b   1/1       Running   0          3m
       example-etcd-cluster-e43636bc7c   1/1       Running   0          21m   
   ```
       
#### Delete a cluster
1. Bring a cluster up.
2. Delete the cluster by `kubectl delete etcdcluster example-etcd-cluster`. This should delete all the pods and services created because of this cluster


#### TLS

To create certificates, do the following:
1. Bring [minikube](https://github.com/kubernetes/minikube/) up in your host.
2. Install [ansible] (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#running-from-source). Note the ansible version should be greater than 2.6
3. Run `tls_playbook.yaml` as follows:

    ```
        ansible-playbook ansible/tls_playbook.yaml
    ```
   This should create certs in `/tmp/etcd/etcdtls/example-etcd-cluster/` directory. This should also create 3 kubernetes secrets
4. Verify by running:
    ```
    $ kubectl get secrets
    NAME                  TYPE                                  DATA      AGE
    default-token-zhqgh   kubernetes.io/service-account-token   3         1d
    etcd-client-tls       Opaque                                3         3h
    etcd-peer-tls         Opaque                                3         3h
    etcd-server-tls       Opaque                                3         3h
    ```
5. Create rbac if not already created `kubectl create -f deploy/rbac.yaml`
6. Create crd if not already created `kubectl create -f deploy/crd.yaml`
7. Deploy operator if nor already deployed `kubectl create -f deploy/operator.yaml`
8. Create etcd cluster with tls using:
    ```
    kubectl create -f deploy/cr_tls.yaml
    ```


#### Upgrades

Work in progress