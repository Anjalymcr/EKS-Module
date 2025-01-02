resource "kubernetes_namespace" "wilt" {
  metadata {
    name = "wilt"
  }
  depends_on = [module.eks]
}

resource "kubernetes_secret" "wilt_secrets" {
  metadata {
    name = "wilt-secrets"
    namespace = "wilt"
  }

  data = {
    POSTGRES_DB = base64encode(var.POSTGRES_DB)
    POSTGRES_USER = base64encode(var.POSTGRES_USER)
    POSTGRES_PASSWORD = base64encode(var.POSTGRES_PASSWORD)
    POSTGRES_HOST = base64encode(aws_db_instance.wilt_db.endpoint)
    POSTGRES_PORT = "5432"
  }

  type = "Opaque"
}


## Create  Configmap

resource "kubernetes_config_map" "wilt_configmap" {
  metadata {
    name = "wilt-configmap"
    namespace = "wilt"
  }

  data = {
    AWS_ACCOUNT_ID = var.aws_account_id
    AWS_REGION = var.region
    FRONTEND_REPO = "wilt-frontend"
    BACKEND_REPO = "wilt-backend"
  }
}