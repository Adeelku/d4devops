variable "storage_account_id" {
    description = "(Required) Specifies the id of the storage account to apply the management policy to"
    type = string
}

variable "rules" {
    description = "(Optional) A rule block as documented below. Supports the following parameters: name, enabled, filters, actions."
    default = null
}