output "app_service_plan_id" {
    value = azurerm_app_service_plan.example.id
}

output "app_service_id" {
    value = azurerm_app_service.example-dev.id
}

output "app_service_hostname" {
    value = azurerm_app_service.example-dev.default_site_hostname
}


output "app_service_vnet_id" {
    value = azurerm_app_service_virtual_network_swift_connection.example.id
}

output "function_app_id" {
    value = azurerm_function_app.example.id
}

