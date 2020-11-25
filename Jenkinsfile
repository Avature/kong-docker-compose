pipeline {
  agent any
  stages {
      stage('Plugins Testing') {
        // agent {
        //   docker {
        //     image 'imega/busted'
        //     args '-v $WORKSPACE:/data -e HOME=$WORKSPACE'
        //   }
        // }
        steps {
          sh(script: 'cd ./plugins/mtls_certs_manager && ./run_tests_with_docker.sh')
          sh(script: 'cd ./plugins/client_consumer_validator && ./run_tests_with_docker.sh')
        }
      }
  }
}
