resource "azuread_application" "aks_server_app" {
  
  # https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration-cli#create-azure-ad-server-component

  name                       = "${local.aks_server_app_name}"
  homepage                   = "https://${local.aks_server_app_name}"
  identifier_uris            = ["https://${local.aks_server_app_name}"]
  type                       = "webapp/api"
  group_membership_claims    = "All"

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read - Sign in and read user profile - Allows users to sign-in to the app, and allows the app to read the profile of signed-in users. It also allows the app to read basic company information of signed-in users.
      type = "Scope"
    }

    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a" # Directory.Read.All - Read directory data - Allows the app to read data in your organization's directory, such as users, groups and apps.
      type = "Scope"
    }

    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61" # Directory.Read.All (Application) - Read directory data - Allows the app to read data in your organization's directory, such as users, groups and apps, without a signed-in user.
      type = "Role"
    }
  }

  provisioner "local-exec" {
      command = <<EOF
        az ad app permission grant --id ${azuread_application.aks_server_app.application_id} --api 00000003-0000-0000-c000-000000000000 && 
        az ad app permission admin-consent --id ${azuread_application.aks_server_app.application_id}
      EOF
  }
}

resource "azuread_service_principal" "aks_server_app" {
  application_id = "${azuread_application.aks_server_app.application_id}"
}

resource "ramdom_password" "aks_server_app" {
    length = 32
}

resource "azuread_service_principal_password" "aks_server_app" {
  service_principal_id = "${azuread_service_principal.aks_server_app.id}"
  value                = "${random_password.aks_server_app.result}"
  end_date             = "2099-01-01T01:02:03Z"
}

 resource "azuread_application" "aks_client_app" {
  
  # https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration-cli#create-azure-ad-client-component

  name                       = "${local.aks_client_app_name}"
  homepage                   = "https://${local.aks_client_app_name}"
  reply_urls                 = ["https://${local.aks_client_app_name}"]
  type                       = "native"

    required_resource_access {
        resource_app_id = "${azuread_application.aks_server_app.id}" # Our own Server App (See above)

        resource_access {
            id   = "${azuread_application.aks_server_app.oauth2_permissions.0.id}" # First OAuth2 permission of our server app.
            type = "Scope"
        }
    }

  provisioner "local-exec" {
      command = <<EOF
        az ad app permission grant --id ${azuread_application.aks_client_app.application_id} --api ${azuread_application.aks_server_app.id} 
      EOF
  }
}

resource "azuread_service_principal" "aks_client_app" {
  application_id = "${azuread_application.aks_client_app.application_id}"
}

resource "azuread_application" "aks_sp" {
  
  # The usual SP that AKS needs to provision its own resources

  name                       = "${local.aks_sp_name}"
  homepage                   = "https://${local.aks_sp_name}"
  identifier_uris            = ["https://${local.aks_sp_name}"]
  type                       = "webapp/api"
}

resource "azuread_service_principal" "aks_sp" {
  application_id = "${azuread_application.aks_sp.application_id}"
}

resource "ramdom_password" "aks_sp" {
    length = 32
}

resource "azuread_service_principal_password" "aks_sp" {
  service_principal_id = "${azuread_service_principal.aks_sp.id}"
  value                = "${random_password.aks_sp.result}"
  end_date             = "2099-01-01T01:02:03Z"
}