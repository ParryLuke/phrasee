# Terraform module for Phrasee

Setup:
1. AWS user for terraform has the following permissions:
  - EC2FullAccess
  - S3FullAccess
  - IAMFullAccess
  - CloudWatchLogsFullAccess
2. Download access key for user from 'IAM' > _User_> 'Security credentials' in console
3. Install AWS console and run 'aws configure'. Enter the security credentials.
4. Download this repository
5. Run 'terraform init' then 'terraform apply' from root directory of repo

Resources use the default vpc.