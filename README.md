# Instructions
- Set up backend for terraform states
  ```zsh
  cd backend
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
