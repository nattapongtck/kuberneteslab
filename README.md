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




