# ami-jenkins

This repo creates custom AMI to host Jenkins using Packer

Features:

1. Use Ubuntu 24.04 LTS as source image

## Packer instruction

(in local test, in `packer` folder, run `export AWS_PROFILE=ghactions` before initiation)(no space around '='!!)
1. `packer fmt -var-file=jenkins-ami.pkrvars.hcl jenkins-ami.pkr.hcl`
2. `packer init -var-file=jenkins-ami.pkrvars.hcl jenkins-ami.pkr.hcl`
3. `packer validate -var-file=jenkins-ami.pkrvars.hcl jenkins-ami.pkr.hcl`                                                            
4. `packer build -var-file=jenkins-ami.pkrvars.hcl jenkins-ami.pkr.hcl`  