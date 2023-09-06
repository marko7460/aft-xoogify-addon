resource "aws_servicecatalog_principal_portfolio_association" "example" {
  portfolio_id  = var.portfolio_id
  principal_arn = module.aft_iam_roles.ct_management_exec_role_arn
  principal_type = "IAM"
}