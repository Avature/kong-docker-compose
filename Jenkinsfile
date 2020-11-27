pipeline {
    agent any
    stages {
        stage('Branch Naming') {
            when {
                not { expression { return env.BRANCH_NAME ==~ /^[a-zA-Z0-9_]+$/ } }
            }
            steps {
                error("Branch does not match Pattern[/[a-zA-Z0-9_]+/]")
            }
        }
        stage('Codestyle Check') {
            steps {
                sh 'docker run --rm --volume=$PWD:/check mstruebing/editorconfig-checker'
            }
        }
    }
    post {
        failure {
            emailext(
                subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
        fixed {
            emailext(
                subject: "RECOVERED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>RECOVERED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' was fixed !</p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
}
