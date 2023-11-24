module "jenkins" {
  source            = "../modules/jenkins"
  helm_version      = "4.8.3"
  jenkins_namespace = "jenkins"
}