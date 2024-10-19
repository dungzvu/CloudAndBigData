# CloudAndBigData

Good day!

**Part 1: [Cloud](https://github.com/teabetab/CoursCloudN7)**

**Part 2: [Big Data](https://sd-160040.dedibox.fr/hagimont)**

Group members:
  - Pham Gia Phuc
  - Vu Trung Dung
  - Nguyen Tu Tung


## Quick guide

### Install
```shell
bash scripts/install.sh
```

### Test terraform function
```shell
cd terraform/
terraform init
terraform plan
terraform apply -auto-approve

# Get instance ips
terraform output -json ips
```

### Run full
```shell
bash start.sh <n_slaves> <file_jar_path> <file_data_path> <job_class_name>

# examples
bash start.sh 2 ./examples/wc.jar ./examples/filesample.txt WordCount
```

