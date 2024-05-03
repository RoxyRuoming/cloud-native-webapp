// service account and role binding
// for cicd pipeline
# resource "google_project_iam_binding" "network_admin" {
#   project = var.project_id
#   role    = "roles/compute.networkAdmin" // var.network_admin_role
  
#   members = [
#     "serviceAccount:packer@csye6225-dev-a04.iam.gserviceaccount.com"
#   ]
# }

# resource "google_project_iam_binding" "load_balancer_admin" {
#   project = var.project_id
#   role    = "roles/compute.loadBalancerAdmin" // var.load_balancer_admin_role
  
#   members = [
#     "serviceAccount:packer@csye6225-dev-a04.iam.gserviceaccount.com"
#   ]
# }

resource "google_project_iam_binding" "packer_iam" {
  for_each = toset(var.packer_roles)
  project = var.project_id
  role    = each.value

  members = [
    var.packer_service_account
  ]
}


// create a service account for vm
resource "google_service_account" "vm_service_account" {
  account_id   = var.vm_service_account_account_id
  display_name = var.vm_service_account_display_name
}

// Bind IAM Role - Logging Admin to the Service Account
resource "google_project_iam_binding" "logging_admin" {
  project = var.project_id
  role    = var.logging_admin_role

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

// Bind IAM Role - Monitoring Metric Writer to the Service Account
resource "google_project_iam_binding" "monitoring_metric_writer" {
  project = var.project_id
  role    = var.monitoring_metric_writer_role

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

// bind "roles/pubsub.publisher" to vm service account
resource "google_project_iam_binding" "vm_pubsub_publisher" {
  project = var.project_id
  role    = var.vm_pubsub_publisher_role

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(var.vm_roles) 
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

data "google_project" "gcp_project" {
  project_id = var.project_id
}


resource "google_kms_crypto_key_iam_binding" "vm_crypto_key" {
  crypto_key_id = google_kms_crypto_key.vm_crypto_key.id
  role          = var.role_encrypter_decrypter
  members       = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
    "serviceAccount:service-${data.google_project.gcp_project.number}@compute-system.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "default"{
  project = var.project_id
  role          = var.role_encrypter_decrypter
  members = [
    "serviceAccount:service-${data.google_project.gcp_project.number}@compute-system.iam.gserviceaccount.com"
  ]
}
// allow google cloud storage service account to access cloud kms
data "google_storage_project_service_account" "gcs_account" {
}

resource "google_kms_crypto_key_iam_binding" "cloud_storage__crypto_key_binding" {
  crypto_key_id = google_kms_crypto_key.bucket_crypto_key.id
  role          = var.role_encrypter_decrypter

  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  # "serviceAccount:${google_service_account.cloud_function_sa.email}"]
  ]
}

resource "google_kms_crypto_key_iam_member" "crypto_key_iam_member" {
  crypto_key_id = google_kms_crypto_key.bucket_crypto_key.id
  role          = var.role_encrypter_decrypter
  member = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

// bind roles to cloud function service account
resource "google_project_iam_binding" "cloud_function_iam" {
  for_each = toset(var.cloud_function_roles)

  project = var.project_id
  role    = each.value

  members = [
    "serviceAccount:${google_service_account.cloud_function_sa.email}",
  ]
}

// allow cloudsql to access cloud kms
resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  project = var.project_id
  service = var.gcp_sa_cloud_sql_service
}

resource "google_kms_crypto_key_iam_binding" "cloudsql_instance_crypto_key_binding" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.db_crypto_key.id
  role          = var.role_encrypter_decrypter

  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
}
////////////////////////////////////////////////////
resource "google_compute_network" "vpc_network" {
  name                            = var.vpc_name
  project                         = var.project_id
  routing_mode                    = var.vpc_routing_mode
  auto_create_subnetworks         = var.auto_create_subnetworks
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "webapp" {
  name          = var.subnet_name_webapp
  ip_cidr_range = var.subnet_ip_webapp
  region        = var.region
  network       = google_compute_network.vpc_network.name
  project       = var.project_id
}

resource "google_compute_subnetwork" "db" {
  name          = var.subnet_name_db
  ip_cidr_range = var.subnet_ip_db
  region        = var.region
  network       = google_compute_network.vpc_network.name
  project       = var.project_id
}

//internet gateway route for vpc
resource "google_compute_route" "internet_gateway" {
  name             = var.internet_gateway_name
  network          = google_compute_network.vpc_network.name
  dest_range       = var.dest_range
  next_hop_gateway = var.next_hop_gateway
}

// configuring VPC peering connection
resource "google_compute_global_address" "private_ip_address" {
  name          = var.private_ip_address_name
  purpose       = var.private_ip_address_purpose
  address_type  = var.private_ip_address_address_type
  prefix_length = var.private_ip_address_prefix_length
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_sql_connection" {
  network                 = google_compute_network.vpc_network.name
  service                 = var.private_sql_connection_service
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}


// cloud sql
// set up cloudsql instance
resource "google_sql_database_instance" "cloudsql_instance" {
  depends_on       = [google_service_networking_connection.private_sql_connection]
  name             = var.cloudsql_instance_name
  database_version = var.cloudsql_instance_database_version
  region           = var.cloudsql_instance_region
  encryption_key_name = google_kms_crypto_key.db_crypto_key.id // 这里是官方写法，应该是对的

  settings {
    tier              = var.cloudsql_instance_tier
    disk_autoresize   = var.cloudsql_instance_disk_autoresize
    disk_size         = var.cloudsql_instance_disk_size
    disk_type         = var.cloudsql_instance_disk_type
    availability_type = var.cloudsql_instance_availability_type

    ip_configuration {
      ipv4_enabled                                  = var.cloudsql_instance_ipv4_enabled
      enable_private_path_for_google_cloud_services = var.cloudsql_instance_private_path_for_google_cloud_services
      private_network                               = google_compute_network.vpc_network.self_link
    }
    backup_configuration {
      enabled            = var.cloudsql_instance_backup_enabled
      binary_log_enabled = var.cloudsql_instance_binary_log_enabled
    }
  }
  deletion_protection = var.deletion_protection
  # depends_on = [google_service_networking_connection.private_sql_connection]
}

// set up cloudsqlc database
resource "google_sql_database" "cloudsql_database" {
  name     = var.cloudsql_database_name
  instance = google_sql_database_instance.cloudsql_instance.name
}

// set up datebase user and password
resource "random_password" "password" {
  length  = var.password_length
  special = var.password_special
}

resource "google_sql_user" "webapp_user" {
  name       = var.webapp_user_name
  instance   = google_sql_database_instance.cloudsql_instance.name
  password   = random_password.password.result
  depends_on = [google_sql_database_instance.cloudsql_instance]

}

// cloud function
// add vpc connector (for cloud function to access cloudsql)
resource "google_vpc_access_connector" "vpc_connector" {
  name          = var.vpc_connector_name
  region        = var.vpc_connector_region
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = var.vpc_connector_ip_cidr_range
}

// create service account for cloud function
resource "google_service_account" "cloud_function_sa" {
  project      = var.project_id
  account_id   = var.cloud_function_sa_account_id
  display_name = var.cloud_function_sa_display_name
}

// create cloud storage bucket for cloud function
resource "google_storage_bucket" "cloud_functions_bucket" {
  name          = var.cloud_functions_bucket_name
  location      = var.cloud_functions_bucket_location
  force_destroy = var.cloud_functions_bucket_force_destroy

  encryption {
    default_kms_key_name = google_kms_crypto_key.bucket_crypto_key.id 
    // 官方写法 https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#nested_encryption
  }

  depends_on = [google_kms_crypto_key_iam_binding.cloud_storage__crypto_key_binding]
}

// upload cloud function to bucket
resource "google_storage_bucket_object" "function_source" {
  name   = var.function_source_name
  bucket = google_storage_bucket.cloud_functions_bucket.name
  source = var.function_source  
}

// create pubsub topic - "verify-email" 
resource "google_pubsub_topic" "verify_email_topic" {
  name                       = var.verify_email_topic_name
  message_retention_duration = var.verify_email_topic_duration
}



// use 2nd function
resource "google_cloudfunctions2_function" "cloud_function" {
  name        = var.cloud_function_name
  location    = var.cloud_function_location

  build_config {
    runtime     = var.cloud_function_runtime
    entry_point = var.cloud_function_entry_point
    environment_variables = {} 
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_functions_bucket.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    max_instance_count = var.cloud_function_max_instance_count
    min_instance_count = var.cloud_function_min_instance_count
    available_memory   = var.cloud_function_available_memory
    timeout_seconds    = var.cloud_function_timeout_seconds
    environment_variables = {
      DB_HOST = google_sql_database_instance.cloudsql_instance.private_ip_address
      DB_USER = google_sql_user.webapp_user.name
      DB_PASS = random_password.password.result
      DB_NAME = google_sql_database.cloudsql_database.name
    }
    ingress_settings               = var.cloud_function_ingress_settings
    all_traffic_on_latest_revision = var.cloud_function_all_traffic_on_latest_revision
    service_account_email          = google_service_account.cloud_function_sa.email
    vpc_connector = google_vpc_access_connector.vpc_connector.name 
  }
  event_trigger {
    trigger_region = var.cloud_function_trigger_region
    event_type     = var.cloud_function_event_type
    pubsub_topic   = google_pubsub_topic.verify_email_topic.id
    retry_policy   = var.cloud_function_retry_policy
  }

  depends_on = [
    google_sql_database_instance.cloudsql_instance,
    google_vpc_access_connector.vpc_connector
  ]
}

// Create a global compute instance template 
resource "google_compute_instance_template" "webapp_template" {
  project = var.project_id
  name    = var.webapp_template_name
  machine_type = var.vm_machine_type
  can_ip_forward = var.can_ip_forward_enable
  tags =  var.template_target_tags
  disk {
    source_image = var.image
    auto_delete       = var.auto_delete_enable
    boot              = var.boot_enable
    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.vm_crypto_key.id
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.webapp.self_link
    access_config {
    }
  }

  service_account {
    email = google_service_account.vm_service_account.email 
    scopes = var.vm_scopes
  }

  metadata = {
    startup-script = <<-EOT
    #!/bin/bash
    set -e

    # create application.properties 
    sudo echo "spring.datasource.url=jdbc:mysql://${google_sql_database_instance.cloudsql_instance.private_ip_address}:3306/${google_sql_database.cloudsql_database.name}?useSSL=false" > /opt/myapp/application.properties
    sudo echo "spring.datasource.username=${google_sql_user.webapp_user.name}" >> /opt/myapp/application.properties
    sudo echo "spring.datasource.password=${random_password.password.result}" >> /opt/myapp/application.properties
    sudo echo "spring.sql.init.mode=always" >> /opt/myapp/application.properties

    sudo echo "spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver" >> /opt/myapp/application.properties
    sudo echo "spring.jpa.properties.hibernate.dialect = org.hibernate.dialect.MySQL8Dialect" >> /opt/myapp/application.properties
    sudo echo "spring.jpa.hibernate.ddl-auto=create" >> /opt/myapp/application.properties
    sudo echo "spring.jpa.show-sql=true" >> /opt/myapp/application.properties

    # Override Hikari configuration
    sudo echo "spring.datasource.hikari.connection-timeout=2000" >> /opt/myapp/application.properties
    sudo echo "spring.datasource.hikari.maximum-pool-size=30" >> /opt/myapp/application.properties

    sudo systemctl restart webapp
    EOT
  }
}

// Create a compute health check. This health check should use the /healthz endpoint in the web application.
resource "google_compute_health_check" "health_check" {
  project = var.project_id
  name    = var.health_check_name

  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.timeout_sec 
  healthy_threshold   = var.health_threshold 
  unhealthy_threshold = var.unhealth_threshold 

  http_health_check {
    port = var.health_check_port 
    request_path = var.health_check_path
  }
}

// Create a compute autoscaler resource that will scale up when CPU usage exceeds 5% CPU.
resource "google_compute_autoscaler" "autoscaler" {
  project = var.project_id
  name    = var.autoscaler_name
  zone = var.vm_zone

  target = google_compute_instance_group_manager.group_manager.id

  autoscaling_policy {
    min_replicas = 1 
    max_replicas = 5 
    cooldown_period = 300 

    cpu_utilization {
      target = 0.05 // var.cpu_utilization
    }

    scale_in_control {
      max_scaled_in_replicas {
        percent = 5
      }
      time_window_sec = 150
    
    }
  }
}

// Create a regional compute instance group manager with the above resources.
resource "google_compute_instance_group_manager" "group_manager" {
  project = var.project_id
  name    = var.group_manager_name

  base_instance_name = var.base_instance_name

  zone               = var.vm_zone 
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.webapp_template.id
  }

  named_port {
    name = var.manager_named_port_name
    port = var.manager_named_port_port
  }


  auto_healing_policies {
    health_check      = google_compute_health_check.health_check.id
    initial_delay_sec = var.initial_delay_sec
  }
}

// Create a firewall rule that allows traffic from the load balancer to the VM instances
resource "google_compute_firewall" "allow_lb_traffic" {
  project = var.project_id
  name    = var.allow_lb_traffic_name
  network = google_compute_network.vpc_network.name
  direction     = var.direction

  allow {
    protocol = var.allow_lb_traffic_protocol
    ports    = var.allow_lb_traffic_ports
  }
 
  source_ranges = var.allow_lb_traffic_source_ranges 
  target_tags = var.allow_lb_traffic_target_tags
}

// Set up SSL certificates Use Google-managed SSL certificates.
resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  project       = var.project_id
  name          = var.ssl_certificate_name
  managed {
    domains = var.ssl_certificate_domains 
  } 
}

# dns - updated
data "google_dns_managed_zone" "env_dns_zone" {
  name = var.dns_zone_name
}

resource "google_dns_record_set" "dns" {
  name = data.google_dns_managed_zone.env_dns_zone.dns_name
  type = var.dns_record_type
  ttl  = var.dns_record_ttl

  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  # rrdatas      = [google_compute_global_address.private_ip_address.address]
  rrdatas      = [module.gce-lb-http.external_ip]
}

// 改用module的模式写
module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 9.0"
  name    = var.gce_lb_http_name
  project = var.project_id
  target_tags = var.gc_lb_http_target_tags

  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.id]  // import ssl certificate  这里不确定要不要
  ssl = true
  managed_ssl_certificate_domains = var.managed_ssl_certificate_domains
  # https_redirect = true

  backends = {
    default = {

      protocol    = var.backend_protocol
      port        = var.backend_port
      port_name   = var.backend_port_name
      timeout_sec = var.backend_timeout_sec
      enable_cdn  = var.backend_enable_cdn

      health_check = {
        request_path = var.health_check_path
        port         = var.health_check_port
      }

      log_config = {
        enable      = var.log_config_enable 
        sample_rate = var.log_config_sample_rate
      }

      groups = [
        {
          group = google_compute_instance_group_manager.group_manager.instance_group
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
}

resource "google_compute_firewall" "allow_https" {
  name          = var.allow_https_name // "allow-https"
  direction     = var.allow_https_direction // "INGRESS"
  network       = google_compute_network.vpc_network.name
  priority      = var.allow_https_priority // 1000
  source_ranges = var.allow_https_source_ranges // ["0.0.0.0/0"]
  target_tags   = var.allow_https_target_tags // "allow-https"

  allow {
    ports    = var.allow_https_ports // ["443"]
    protocol = var.allow_https_protocol // "tcp"
  }
}

// a09
// use a key ring in the same region as the resources
# data "google_kms_key_ring" "key_ring" {
#   project = var.project_id
#   location = var.region
#   name = var.kms_key_ring_name
# }

// create a key ring
resource "google_kms_key_ring" "key_ring" {
  project = var.project_id
  location = var.region
  name = var.kms_key_ring_name
}

// create 3 separate crypto keys for 3 different purposes - each update will generate a new key
resource "random_id" "random_crypto_key_id" {
  byte_length = var.random_crypto_key_id_byte_length
}

resource "google_kms_crypto_key" "db_crypto_key" {
  // create a random name using random provider
  name  = "csye6225-a09-db-${random_id.random_crypto_key_id.hex}" 
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.key_rotation_period
}
resource "google_kms_crypto_key" "vm_crypto_key" {
  // create a random name using random provider
  name  = "csye6225-a09-vm-${random_id.random_crypto_key_id.hex}" 
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.key_rotation_period
}

resource "google_kms_crypto_key" "bucket_crypto_key" {
  // create a random name using random provider
  name  = "csye6225-a09-bucket-${random_id.random_crypto_key_id.hex}" 
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.key_rotation_period
}







