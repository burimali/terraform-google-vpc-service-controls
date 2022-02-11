#module "access_context_manager_policy" {
#  source      = "terraform-google-modules/vpc-service-controls/google//.."
#  parent_id   = var.parent_id
#  policy_name = var.policy_name
# }  
  
module "access_level_members" {
  source      = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  description = "Simple Example Access Level"
  policy = var.policy_id
  name = "testing"
#  policy      = module.access_context_manager_policy.policy_id
#  name        = var.access_level_name
#  name = "testing"
#  members     = var.members
  ip_subnetworks = ["8.8.8.8"]
#  regions     = var.regions
}

resource "null_resource" "wait_for_members" {
  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = [module.access_level_members]
}

module "regular_service_perimeter_1" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  #policy         = module.access_context_manager_policy.policy_id
  policy         = var.policy_id
  perimeter_name = var.perimeter_name

  description   = "Perimeter shielding bigquery project"
  resources     = [var.protected_project_ids["number"]]
  access_levels = [module.access_level_members.name]

  restricted_services = ["bigquery.googleapis.com", "storage.googleapis.com","compute.googleapis.com"]


  ingress_policies = [
            {
               from = {
                   identities    = []
                   identity_type = "ANY_IDENTITY"
                   sources = {
                      access_level = "*"
                    }
                }
               to = {
                   resources = ["*"]
                   operations = {
                   "*" = {
                   methods = []
                   }
              }
          }
       }
    ]
  egress_policies = [ 
      {
              from = {
                  identities    = []
                  identity_type = "ANY_IDENTITY"
                }
               to = {
                   resources = ["*"]
                   operations = {
                   "*" = {
                   methods = []
                   }
              }
           }
        },
       {
      "from" = {
        "sources" = {
          access_levels = ["*"] # Allow Access from everywhere
        },
        "identities" = []
      }
      "to" = {
        "resources" = [
          "*"
        ]
        "operations" = {
          "storage.googleapis.com" = {
            "methods" = [
              "google.storage.objects.get",
              "google.storage.objects.list"
            ]
          }
        }
      }
    }
        #  {
        #       "from" = {
        #           "identities"    = []
        #           "identity_type" = "ANY_IDENTITY"
        #         }
        #        "to" = {
        #            "resources" = [                      
        #                "*"
        #            ]
        #            "operations" = {
        #            "compute.googleapus.com" = {
        #            "methods" = [
        #                      "NetworkServices.list"
        #                      ]
        #                 }
        #            }
        #       }
        #   }
     ]
 }
#identity_type  = "ANY_IDENTITY"
#    identities     = null
#    sources        = [{
#      resource     = ["*"]
#      access level = null
#    }]
#    resource       = ["*"]
#    operations     = null
#},
#]

#    {
#      "from" = {
#        "sources" = {
#          access_levels = ["*"] # Allow Access from everywhere
#        },
#        "identities" = var.read_bucket_identities
#      }
#      "to" = {
#        "resources" = [ "*" ]
#        "operations" = {
#          "storage.googleapis.com" = {
#            "methods" = [
#              "google.storage.objects.get",
#              "google.storage.objects.list"
#            ]
#          }
#        }
#      }
#    },

#  {
#    "from" = {
#        "sources" = {
#          access_levels = ["*"] # Allow Access from everywhere
#        },
#        "identities" = null
#      }
#
#
  #    "to" = {
  #      "resources" = [ "*" ]
  #      "operations" = null
  #    }
  #  },  
  #]



#ingress_policies_02 = [
#    {
#      "from" = {
#        "sources" = {
#          access_levels = ["*"] # Allow Access from everywhere
#        },
#        "identities" = null
#      }
#      "to" = {
#        "resources" = [ "*" ]
#        "operations" = [ "*" ]
#      }
#    },
#  ]

    
#    ingress_policies_02 = [
#    {
#      "from" = {
#        "sources" = {
#          access_levels = ["*"] # Allow Access from everywhere
#        },
#        "identities" = var.read_bucket_identities
#      }
#      "to" = {
#        "resources" = [
#          "*"
#        ]
#        "operations" = {
#          "storage.googleapis.com" = {
#            "methods" = [
#              "google.storage.objects.get",
#              "google.storage.objects.list"
#            ]
#          }
#        }
#      }
#    },
#]
    
#    
#  shared_resources = {
#    all = [var.protected_project_ids["number"]]
#  }
#
#  depends_on = [
#    module.gcs_buckets
#  ]
#}


#module "gcs_buckets" {
#  source           = "terraform-google-modules/cloud-storage/google"
#  project_id       = var.protected_project_ids["id"]
#  names            = var.buckets_names
#  randomize_suffix = true
#  prefix           = var.buckets_prefix
#  set_admin_roles  = true
#  admins           = var.members
#}
  
