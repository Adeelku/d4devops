variable "location" {
  description = "Azure Region"
  type        = string
}

variable "tags" {
  type = map(string)
  default = {
    Billing-Code   = "!!Not Defined!!"
    Business-Unit  = "!!Not Defined!!"
    Environment    = "!!Not Defined!!"
    Solution-Group = "!!Not Defined!!"
    Solution-ID    = "!!Not Defined!!"
    Solution-Name  = "!!Not Defined!!"
    Expiry-Date    = "!!Not Defined!!"

  }
}

variable "unique_name" {
  description = "Freeform input to append to resource group name. Set to 'true', to append 5 random integers"
  type        = string
  default     = null
}

variable "business_unit" {
  description = "Business Unit or Department e.g. Cloud Eng."
  type        = string
}

variable "environment_type" {
  description = "Environmnet type e.g. DEV, QA, PROD"
  type        = string
}
