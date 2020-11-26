pipeline {
  agent any
  stages {
      stage('Test Plugins') {
        steps {
          sh(script: './test_plugin mtls_certs_manager')
          sh(script: './test_plugin client_consumer_validator')
        }
      }
  }
}
