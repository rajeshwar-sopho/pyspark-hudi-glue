cd ..\iaac\services\aws_resources
terraform apply -var-file=..\..\env\dev\aws_resources.tfvars -auto-approve
cd ..\..\..\scripts
