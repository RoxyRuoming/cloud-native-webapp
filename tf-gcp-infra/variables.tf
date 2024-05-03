
variable "project_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet_name_webapp" {
  type = string
}

variable "subnet_name_db" {
  type = string
}

variable "subnet_ip_webapp" {
  type = string
}

variable "subnet_ip_db" {
  type = string
}

variable "region" {
  type = string
}

variable "internet_gateway_name" {
  type = string
}

variable "vpc_routing_mode" {
  type = string
}

variable "dest_range" {
  type = string
}

variable "next_hop_gateway" {
  type = string
}

#  for a04
variable "allow_app_traffic_name" {
  type = string
}
variable "allow_app_traffic_protocol" {
  type = string
}

variable "allow_app_traffic_ports" {
  type = list(string)
}
variable "allow_source_ranges" {
  type = list(string)
}
variable "vm_target_tags" {
  type = list(string)
}

variable "template_tags" {
  type = list(string)
}

variable "deny_traffic_name" {
  type = string
}

variable "deny_app_traffic_protocol" {
  type = string
}
variable "deny_app_traffic_ports" {
  type = list(string)
}
variable "deny_source_ranges" {
  type = list(string)
}

variable "allow_me_tarffic_name" {
  type = string
}

variable "vm_instance_name" {
  type = string
}
variable "vm_machine_type" {
  type = string
}
variable "vm_zone" {
  type = string
}
variable "boot_disk_type" {
  type = string
}
variable "boot_disk_size" {
  type = number
}

variable "image" {
  type = string
}

variable "my_ip" {
  type = list(string)
}

// a05
variable "private_ip_address_name" {
  type = string
}
variable "private_ip_address_purpose" {
  type = string
}
variable "private_ip_address_address_type" {
  type = string
}
variable "private_ip_address_prefix_length" {
  type = number
}
variable "private_sql_connection_service" {
  type = string
}
variable "cloudsql_instance_name" {
  type = string
}

variable "cloudsql_instance_database_version" {
  type = string
}

variable "cloudsql_instance_region" {
  type = string
}

variable "cloudsql_instance_tier" {
  type = string
}

variable "cloudsql_instance_disk_autoresize" {
  type = bool
}

variable "cloudsql_instance_disk_size" {
  type = number
}

variable "cloudsql_instance_disk_type" {
  type = string
}

variable "cloudsql_instance_availability_type" {
  type = string
}

variable "cloudsql_instance_ipv4_enabled" {
  type = bool
}

variable "cloudsql_instance_private_path_for_google_cloud_services" {
  type = bool
}

variable "cloudsql_instance_backup_enabled" {
  type = bool
}

variable "cloudsql_instance_binary_log_enabled" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "cloudsql_database_name" {
  type = string
}

variable "webapp_user_name" {
  type = string
}

variable "password_length" {
  type = number
}

variable "password_special" {
  type = bool
}
variable "auto_create_subnetworks" {
  type = bool

}
variable "delete_default_routes_on_create" {
  type = bool
}
variable "vm_service_account_account_id" {
  type = string
}

variable "vm_service_account_display_name" {
  type = string
}

variable "service_account_scopes" {
  type = list(string)
}

variable "dns_zone_name" {
  type = string
}

variable "dns_record_type" {
  type = string
}

variable "dns_record_ttl" {
  type = number
}

variable "logging_admin_role" {
  type = string
}

variable "monitoring_metric_writer_role" {
  type = string
}
variable "vpc_connector_name" {
  type = string
}

variable "vpc_connector_region" {
  type = string
}

variable "vpc_connector_ip_cidr_range" {
  type = string
}

variable "cloud_function_sa_account_id" {
  type = string
}

variable "cloud_function_sa_display_name" {
  type = string
}

variable "cloud_functions_bucket_name" {
  type = string
}

variable "cloud_functions_bucket_location" {
  type = string
}

variable "cloud_functions_bucket_force_destroy" {
  type = bool
}

variable "function_source_name" {
  type = string
}

variable "function_source" {
  type = string
}

variable "verify_email_topic_name" {
  type = string
}

variable "verify_email_topic_duration" {
  type = string
}

variable "cloud_function_roles" {
  type = list(string)
}
variable "vm_pubsub_publisher_role" {
  type = string
}

variable "cloud_function_name" {
  type = string
}

variable "cloud_function_location" {
  type = string
}

variable "cloud_function_runtime" {
  type = string
}

variable "cloud_function_entry_point" {
  type = string
}

variable "cloud_function_max_instance_count" {
  type = number
}

variable "cloud_function_min_instance_count" {
  type = number
}

variable "cloud_function_available_memory" {
  type = string
}

variable "cloud_function_timeout_seconds" {
  type = number
}

variable "cloud_function_ingress_settings" {
  type = string
}

variable "cloud_function_all_traffic_on_latest_revision" {
  type = bool
}

variable "cloud_function_trigger_region" {
  type = string
}

variable "cloud_function_event_type" {
  type = string
}

variable "cloud_function_retry_policy" {
  type = string
}


// a08
variable "webapp_template_name" {
  type = string
}

variable "can_ip_forward_enable" {
  type = bool
}

variable "template_target_tags" {
  type = list(string)
}

variable "auto_delete_enable" {
  type = bool
}

variable "create_before_destroy" {
  type = bool
}
variable "boot_enable" {
  type = bool
}

variable "vm_roles" {
  type = list(string)
}

variable "health_check_name" {
  type = string
}

variable "check_interval_sec" {
  type = number
}

variable "timeout_sec" {
  type = number
}

variable "health_threshold" {
  type = number
}

variable "unhealth_threshold" {
  type = number
}

variable "health_check_port" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "autoscaler_name" {
  type = string
}

variable "min_replicas" {
  type = number
}

variable "max_replicas" {
  type = number
}

variable "cooldown_period" {
  type = number
}

variable "cpu_utilization" {
  type = number
}

variable "group_manager_name" {
  type = string
}

variable "base_instance_name" {
  type = string
}

variable "target_size" {
  type = number
}

variable "manager_named_port_name" {
  type = string
}

variable "manager_named_port_port" {
  type = number
}

variable "initial_delay_sec" {
  type = number
}

variable "allow_lb_traffic_name" {
  type = string
}

variable "direction" {
  type = string
}

variable "allow_lb_traffic_protocol" {
  type = string
}

variable "allow_lb_traffic_ports" {
  type = list(string)
}

variable "allow_lb_traffic_source_ranges" {
  type = list(string)
}

variable "allow_lb_traffic_target_tags" {
  type = list(string)
}

variable "ssl_certificate_name" {
  type = string
}

variable "ssl_certificate_domains" {
  type = list(string)
}

variable "gce_lb_http_module_source" {
  type = string
}

variable "gce_lb_http_module_version" {
  type = string
}

variable "gc_lb_http_target_tags" {
  type = list(string)
}

variable "gce_lb_http_name" {
  type = string
}

variable "managed_ssl_certificate_domains" {
  type = list(string)
}

variable "backend_protocol" {
  type = string
}

variable "backend_port" {
  type = number
}

variable "backend_port_name" {
  type = string
}

variable "backend_timeout_sec" {
  type = number
}

variable "backend_enable_cdn" {
  type = bool
}

variable "log_config_enable" {
  type = bool
}

variable "log_config_sample_rate" {
  type = number
}

variable "allow_https_name" {
  type = string
}

variable "allow_https_direction" {
  type = string
}

variable "allow_https_priority" {
  type = number
}

variable "allow_https_source_ranges" {
  type = list(string)
}

variable "allow_https_target_tags" {
  type = list(string)
}

variable "allow_https_ports" {
  type = list(string)
}

variable "allow_https_protocol" {
  type = string
}

// a09

variable "key_rotation_period" {
  type = string
}

variable "random_crypto_key_id_byte_length" {
  type = number
}

variable "kms_key_ring_name" {
  type = string
}

variable "gcp_sa_cloud_sql_service" {
  type = string
}

variable "role_encrypter_decrypter" {
  type = string
}

variable "vm_scopes" {
  type = list(string)
}

variable "packer_service_account" {
  type = string
}

variable "packer_roles" {
  type = list(string)
}

# variable "db_crypto_key_name" {
#   type = string
# }

# variable "vm_crypto_key_name" {
#   type = string
# }

# variable "bucket_crypto_key_name" {
#   type = string
# }
