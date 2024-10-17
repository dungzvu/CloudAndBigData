# CloudAndBigData

Good day!

**Part 1: [Cloud](https://github.com/teabetab/CoursCloudN7)**

**Part 2: [Big Data](https://sd-160040.dedibox.fr/hagimont)**

Group members:
  - Pham Gia Phuc
  - Vu Trung Dung
  - Nguyen Tu Tung


### Quick guide
```shell
# install
bash scripts/install.sh

# spin up instances
cd terraform/
terraform init
terraform plan
terraform apply -auto-approve

# Get instance ips
terraform output -json ips
```