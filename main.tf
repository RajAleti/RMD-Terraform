data "azurerm_key_vault" "fisher" {
  name                = var.key_vault_name
  resource_group_name = var.keyvault_rg
}

data "azurerm_key_vault_secret" "sp_id" {
  name         = "spid"
  key_vault_id = data.azurerm_key_vault.fisher.id
}

data "azurerm_key_vault_secret" "fisher_secret" {
  name         = "appsecret"
  key_vault_id = data.azurerm_key_vault.fisher.id
}

resource "azurerm_app_service_plan" "example" {
  name                = "${var.solution}-${var.environment}-appserviceplan"
  location            = var.location
  resource_group_name = var.rg_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example-dev" {
  name                = "${var.solution}-${var.environment}-app-service"
  location            = var.location
  resource_group_name = var.rg_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
    always_on                = "false"
    java_version             = "11"
    php_version              = "7.4"
    python_version           = "3.4"
    
  }

  app_settings = {
    "environment-solution" = "${var.environment}-${var.solution}"
  }

  storage_account {
    name = var.storage_account_id
    type = AzureBlob
    account_name = var.storage_account_name
    share_name = var.container_name
    access_key = var.storage_account_access_key
  
  } 
  active_directory {
    client_id = data.azurerm_key_vault_secret.sp_id.value
    client_secret = data.azurerm_key_vault_secret.fisher_secret.value
  }  

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "${var.db_fqdn}"
  }

  tags = {
    environment = "${var.environment}" 
    solution = "${var.solution}"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_app_service.publix-dev.id
  subnet_id      = "${var.app_service_subnet_id}"
}

resource "azurerm_function_app" "example" {
  name                       = "${var.solution}-${var.environment}-functions"
  location                   = var.location
  resource_group_name        = var.rg_name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  app_settings {
    FUNCTIONS_WORKER_RUNTIME = "python"
  }

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
    always_on                = "false"
    java_version             = "11"
    php_version              = "7.4"
    python_version           = "3.4"
  }

   active_directory {
    client_id = data.azurerm_key_vault_secret.sp_id.value
    client_secret = data.azurerm_key_vault_secret.fisher_secret.value
  }
}
