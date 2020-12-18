# Instructions
- Set up backend for terraform states
  ```zsh
  cd backend
  terraform init
  terraform plan
  terraform apply
  ```

- Set up volume for persistent EBS
  ```zsh
  cd volume
  terragrunt init
  terragrunt apply
  ```
  Read main/scripts/startup.sh for more details.

- Set up main for the actual server
  ```zsh
  cd main
  terragrunt init
  terragrunt apply
  ```

## TODO:
- [x] Set up EC2 instance + Cloudflare DNS + EBS Volumes
- [x] Set up discord hooks for server status
- [x] Configure firewall
- [ ] Configure multiple IAM users to plan / destroy
- [ ] Configure Vault

<!-- - [ ] Spawn server on DO on apply --> 
<!-- - [ ] Backup server on destroy to S3 -->
