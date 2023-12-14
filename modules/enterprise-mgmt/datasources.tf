locals {

  enterprise_mgmt_data = distinct(flatten([

    for project_name, enterprise_mgmt in var.enterprise_mgmt : {

      name                    = project_name
      description             = enterprise_mgmt.description
      type                    = enterprise_mgmt.type
      enable                  = enterprise_mgmt.enable
      skip_disable_on_destroy = enterprise_mgmt.skip_disable_on_destroy
    }
  ]))
}
