# Instructions
- Set up backend for terraform states
  ```zsh
  cd example
  terraform init
  terraform plan
  terraform apply
  ```

- Set up main for the actual server
  ```zsh
  cd main
  terragrunt init
  terragrunt apply
  ```

## TODO:
- [ ] Spawn server on DO on apply
- [ ] Backup server on destroy to S3
- [ ] Set up discord hooks for server status
- [ ] Configure firewall
- [ ] Configure multiple IAM users to plan / destroy
- [ ] Configure Vault