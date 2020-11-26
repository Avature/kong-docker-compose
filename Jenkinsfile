pipeline {
  agent any
  stages {
      stage('Plugins Testing') {
        steps {
          sh(script: './test plugins mtls_certs_manager')
          sh(script: './test plugins client_consumer_validator')
        }
      }
  }
}
