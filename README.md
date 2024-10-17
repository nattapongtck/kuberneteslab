# kuberneteslab

ส่วนประกอบหลักๆ
1. API (UI, CLI)
2. Kubernetes Master (เหมือน Controller)
3. Node

Pod มีได้แค่ 1 IP เท่านั้น
1 Pod = 1 Container (80% ของโลก) แต่ 1 Pod มีได้หลาย Containers

Pod ไม่สามารถอยู่ด้วยตัวเองได้
Deployment ดูแล Pod

Replicas = จำนวน Pod ที่ต้องการ
