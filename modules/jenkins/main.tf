resource "kubernetes_namespace" "jenkins" {

  metadata {
    name   = "jenkins"
    labels = {
      name        = "jenkins"
      description = "jenkins"
    }
  }
}

resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.jenkins_namespace
  }
}

resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
    name = "jenkins"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "update"]
  }

  rule {
    api_groups = ["*"]
    resources  = [
      "statefulsets",
      "services",
      "replicationcontrollers",
      "replicasets",
      "podtemplates",
      "podsecuritypolicies",
      "pods",
      "pods/log",
      "pods/exec",
      "podpreset",
      "poddisruptionbudget",
      "persistentvolumes",
      "persistentvolumeclaims",
      "jobs",
      "endpoints",
      "deployments",
      "deployments/scale",
      "daemonsets",
      "cronjobs",
      "configmaps",
      "namespaces",
      "events",
      "secrets",
    ]
    verbs = ["create", "get", "watch", "delete", "list", "patch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
    name = "jenkins"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "jenkins"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "system:serviceaccounts:jenkins"
  }
}

resource "kubernetes_storage_class" "jenkins_pv" {
  metadata {
    name = "jenkins-pv"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = false
}

resource "kubernetes_persistent_volume" "jenkins_pv" {
  metadata {
    name      = "jenkins-pv"
  }
  spec {
    capacity = {
      storage = "20Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "jenkins-pv"
    persistent_volume_source {
      host_path {
        path = "/data/jenkins-volume/"
      }
    }
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.helm_version
  namespace  = var.jenkins_namespace
  timeout    = 600
  values = [
    file("files/jenkins-values.yaml"),
  ]

  depends_on = [
    kubernetes_namespace.jenkins,
  ]
}