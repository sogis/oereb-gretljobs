pipeline {
    agent { label env.NODE_LABEL ?: 'gretl' }
    stages {
        stage('GRETL job') {
            options {
                retry(2)
            }
            steps {
                git url: "${env.GIT_REPO_URL}", branch: "${params.BRANCH ?: 'main'}", changelog: false
                container('gretl') {
                    dir(env.JOB_BASE_NAME) {
                        dir('upload') {
                            unstash name: 'uploadFile'
                        }
                        sh 'gretl'
                    }
                }
            }
        }
    }
    post {
        unsuccessful {
            emailext (
                to: '${DEFAULT_RECIPIENTS}',
                recipientProviders: [requestor()],
                subject: "GRETL-Job ${env.JOB_NAME} (${env.BUILD_DISPLAY_NAME}) ist fehlgeschlagen",
                body: "Die Ausführung des GRETL-Jobs ${env.JOB_NAME} (${env.BUILD_DISPLAY_NAME}) war nicht erfolgreich. Details dazu finden Sie in den Log-Meldungen unter ${env.RUN_DISPLAY_URL}."
            )
        }
    }
}
