
#-------------------------------
# Local Declarations
#-------------------------------
locals {
  resource_group_name = "${var.name}"
  unique_name = var.unique_name == "true" ? random_integer.suffix[0].result : (var.unique_name == "false" ? null : var.unique_name)
  company_code             = "CL"  
}
