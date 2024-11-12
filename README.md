# kuberneteslab

ส่วนประกอบหลักๆ
1. API (UI, CLI)
2. Kubernetes Master (เหมือน Controller คอยจัดการ Node)
3. Node

Pod มีได้แค่ 1 IP เท่านั้น
1 Pod = 1 Container (80% ของโลก) แต่ 1 Pod มีได้หลาย Containers

Pod ไม่สามารถอยู่ด้วยตัวเองได้
Deployment ดูแล Pod

Replicas = จำนวน Pod ที่ต้องการ
มี Healthcheck หาก Node เกิดตาย มันก็สามารถสร้าง Pod มาทดแทนได้ด้วย

*** หาก Node กลับมา Online -> Pod จะไม่โยกกลับที่ Node เดิม

Service
ไม่สามารถวิ่งหา IP Pod หากปราศจาก Service ต้องมี Service ขวางหน้า Pod เสมอ

Service Type: Node Port (เรียกผ่าน IP ของ Node)
ทั้ง Onprem/Oncloud มีพฤติกรรมไม่เหมือนกัน
มีการทำ Forward Port ไปที่ ทุก Server ต่างกับ Docker ที่ไปเครื่องเดียว
Service ใน Kubernetes คือ Logical Internal Loadbalancer (Round robin)
Port 30000++

Service Type: LoadBalancer 
ถูก Upgrade จาก NodePort
เรียกว่า External Loadbalancer
มี IP ของ Loadbalancer เกี่ยวข้องจะได้ไม่ต้องเรียก Node IP
สะดวกสบายมากขึ้นกว่าเดิม
ใช้ได้แค่บน Oncloud เท่านั้น
แต่ Onprem ก็ใช้ได้ แต่ยากหน่อย เช่น nginx commercial, f5, HA proxy (Manual สร้างต่างหาก)

Service Type: ClusterIP
ทั้ง Node Port และ LoadBalancer ต่างเป็นการ Expose ออกสู่ภายนอก
ถ้าเราอยากจะ Protect Resource ภายในเช่น DB
มีแค่ Logical Loadbalancer (Internal) ได้ IP มา
โดยให้ App เรียกผ่าน IP ที่ได้มานี้

===

Ingress เป็นอีกตัวที่มาช่วยแก้ปัญหา Service Type


===Install kubectl===
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

===Install helm===
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

===Install helm with binary===
wget https://get.helm.sh/helm-v3.16.2-linux-386.tar.gz
tar -xvzf helm-v3.16.2-linux-386.tar.gz
sudo mv linux-386/helm /usr/local/bin/helm

If you using a cloudshell on AWS
sudo mv linux-386/helm /home/cloudshell-user/.local/bin/helm

===Update EKS Config on local Terminal=== /root/.kube/config
aws eks update-kubeconfig --region us-east-1 --name Demo-Cluster-Skooldio

kubectl version
kubectl get pod --all-namepsaces
kubectl get namespace
kubectl get pod --namespace kube-system
kubectl config get-contexts

kubectl create namespace bookinfo-dev
***Change default namespace to bookinfo-dev namespace
kubectl config set-context $(kubectl config current-context) --namespace=bookinfo-dev

kubectl create deployment nginx --image=nginx:latest

kubectl describe deployment nginx
kubectl describe pod nginx

kubectl expose deployment nginx --type LoadBalancer --port 80
kubectl get pod,deployment,service

kubectl scale deployment nginx --replica=3


===Change image to apache=== 
first "nginx" = deployment name
second "nginx = pod name
--record = record event
kubectl set image deployment nginx nginx=httpd:2.4-alpine --record
kubectl set image deployment nginx nginx=httpd:2.4-alpine --record && watch -n1 kubectl get pod


===Role back===
Example we are going rollback to nginx
kubectl rollout history deployment nginx 

kubectl rollout undo deployment nginx

===label selector===
kubectl create deployment apache --image=httpd:2.4-alpine
kubectl scale deployment apache --replicas=3

set service to apache
kubectl set selector service nginx "app=apache"

===Tshoot===
kubectl logs nginx-676b6c5bbc-c2tnw
kubectl logs nginx-676b6c5bbc-c2tnw -f

kubectl get service
kubectl exec -it nginx-676b6c5bbc-c2tnw -- sh

kubectl get nods
kubectl describe node ip-10-1-10-132.ec2.internal

kubectl delete deployment nginx apache
kubectl delete service nginx

===01-pod.yaml===
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: bookinfo-dev
spec:
  containers:
  - name: busybox
    image: busybox
    command:
    - sleep
    - "3600"

kubectl apply -f 01-pod.yaml

kubectl api-resources

kubectl explain pod
kubectl explain pod.spec
kubectl explain pod.spec.containers


kubectl create -f 02-apache-deployment.yaml -f 02-apache-service.yaml --record

===Difference between "kubectl create" and "kubectl apply"
kubectl create cannot change the existing resources, apply can do
These 2 commands seems same

kubectl delete deployment apache
kubectl delete pod busybox
kubectl delete service apache

cat ~/.docker/config.json
kubectl get secret
kubectl create secret generic registry-bookinfo --from-file=.dockerconfigjson=$HOME/.docker/config.json
kubectl get secret
kubectl describe secret registry-bookinfo

kubectl get secret registry-bookinfo -o yaml

===Helm===
Repo is template

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo list
helm repo update

when we add repo it just download not update to newest version
cat ~/.cache/helm/repository

Helm list show release that create from repo
helm list

helm install mongodb bitnami/mongodb

kubectl get secret (ดู password)
kubectl describe secret mongodb

export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace bookinfo-dev mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 -d)
or
kubectl get secret mongodb -o json


===Access to mongodb===
kubectl run mongodb-client-2 --rm --tty -i --restart='Never' --image bitnami/mongodb:4.4.4-debian-10-r27 \
  --command -- mongo admin --host mongodb --authenticationDatabase admin -u root -p $MONGODB_ROOT_PASSWORD

 172.20.217.176
mongo admin --host mongodb --authenticationDatabase admin -u root -p XwgXKQOQuI
 
kubectl run --namespace bookinfo-dev mongodb-client-3 --rm --tty -i --restart='Never' --env="MONGODB_ROOT_PASSWORD=$MONGODB_ROOT_PASSWORD" --image docker.io/bitnami/mongodb:8.0.3-debian-12-r0 --command -- bash

echo $MONGODB_ROOT_PASSWORD

สร้าง File values.yaml
# Authentication settings
auth:
  enabled: true
  rootPassword: changeme
  username: root
  password: changeme
  database: ryze

# Persistent storage settings
persistence:
  enabled: true
  size: 8Gi

# Disable replica set
replicaSet:
  enabled: false

helm install mongodb-f values.yaml bitnami/mongodb

kubectl run mongodb-client --rm --tty -i --restart='Never' --image=docker.io/bitnami/mongodb:8.0.3-debian-12-r0 \
--command -- mongosh admin --host mongodb --authenticationDatabase admin -u root -p changeme
===End access to mongodb===

mkdir ~/bookinfo-secret
touch ~/bookinfo-secret/bookinfo-dev-ratings-mongodb-secret.yaml

apiVersion: v1
kind: Secret
metadata:
  name: bookinfo-dev-ratings-mongodb-secret
  namespace: bookinfo-dev
type: Opaque
data:
  mongodb-root-password: "cmF0aW5ncy1kZXYtcm9vdA=="
  mongodb-password: "cmF0aW5ncy1kZXY="


kubectl apply -f ~/bookinfo-secret/bookinfo-dev-ratings-mongodb-secret.yaml

###Bonus section
echo -n "ratings-dev-root" | base64 <<< text in base64

cd ~/ratings
mkdir database/
touch database/ratings_data.json
touch database/script.sh


#ratings_data.json
{"rating": 5}
{"rating": 4}

#script.sh
#!/bin/sh

set -e
mongoimport --host localhost --username $MONGODB_USERNAME --password $MONGODB_PASSWORD \
  --db $MONGODB_DATABASE --collection ratings --drop --file /docker-entrypoint-initdb.d/ratings_data.json


