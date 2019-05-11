#!/bin/bash
# Copyright (C) 2019, case
# All rights reserved.
# Version    : 1.0
# Date       : 2019-04-20
# Last Update: 2019-04-20
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cat > redis-master-controller.yaml <<EOF
apiVersion: v1
kind: ReplicationController
metadata:
  name: redis-master
spec:
  replicas: 1
  selector:
    name: redis-master
  template:
    metadata:
      name: redis-master
      labels:
        name: redis-master
    spec:
      containers:
      - name: redis-master
        image: kubeguide/redis-master
        ports:
        - containerPort: 6379
EOF

kubectl create -f redis-master-controller.yaml
kubectl get rc
kubectl get pods

cat > redis-master-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: redis-master
  labels:
    name: redis-master
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    name: redis-master
EOF

kubectl create -f redis-master-service.yaml
kubectl get services

cat > redis-slave-controller.yaml <<EOF
apiVersion: v1
kind: ReplicationController
metadata:
  name: redis-slave
spec:
  replicas: 2
  selector:
    name: redis-slave
  template:
    metadata:
      name: redis-slave
      labels:
        name: redis-slave
    spec:
      containers:
      - name: redis-slave
        image: kubeguide/guestbook-redis-slave
        env:
        - name: GET_HOSTS_FROM
          value: env
        ports:
        - containerPort: 6379
EOF

kubectl create -f redis-slave-controller.yaml
kubectl get rc
kubectl get pods

cat > redis-slave-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: redis-slave
  labels:
    name: redis-slave
spec:
  ports:
  - port: 6379
  selector:
    name: redis-slave
EOF

kubectl create -f redis-slave-service.yaml
kubectl get services

cat > frontend-controller.yaml <<EOF
apiVersion: v1
kind: ReplicationController
metadata:
  name: frontend
  labels:
    name: frontend
spec:
  replicas: 3
  selector:
    name: frontend
  template:
    metadata:
      labels:
        name: frontend
    spec:
      containers:
      - name: frontend
        image: kubeguide/guestbook-php-frontend
        env:
        - name: GET_HOSTS_FROM
          value: env
        ports:
        - containerPort: 80
EOF

kubectl create -f frontend-controller.yaml
kubectl get rc
kubectl get pods

cat > frontend-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    name: frontend
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30001
  selector:
    name: frontend
EOF

kubectl create -f frontend-service.yaml
kubectl get services
cat > cluster-admin.yaml <<EOF
# ------------------- Dashboard Service Account ------------------- #

apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system

---
# ------------------- Dashboard ClusterRoleBinding ------------------- #

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system

EOF

kubectl apply -f cluster-admin.yaml
kubectl get svc -n kube-system
#kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')


#kubectl delete -f frontend-controller.yaml
#kubectl delete -f redis-master-controller.yaml
#kubectl delete -f redis-slave-controller.yaml
#kubectl delete -f redis-slave-service.yaml
#kubectl delete -f redis-master-service.yaml
#kubectl delete -f frontend-service.yaml
