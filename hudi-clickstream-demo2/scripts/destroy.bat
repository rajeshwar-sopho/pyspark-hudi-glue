cd ..\iaac\services\aws_resources
terraform destroy -var-file=..\..\env\dev\aws_resources.tfvars -auto-approve
cd ..\..\..\scripts
