node('master') { // need a few lines of scripted pipeline before the declarative pipeline...
    stage('Prepare') {
        gretlJobRepoUrl = env.GRETL_JOB_REPO_URL_OEREB
    }
}

pipeline {
    agent none
    parameters {
        // TODO: Funktioniert nicht bei der allerersten Ausführung, deshalb durch den gretl-job-generator setzen lassen
        string(name: 'buildDescription', description: 'Bitte geben Sie den Grund für die Publikation der Daten ein')
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '25'))
        disableConcurrentBuilds()
        timeout(time: 7, unit: 'DAYS')
    }
    stages {
        stage('Import into staging schema') {
            agent { label 'gretl-ili2pg4' }
            steps {
                script { currentBuild.description = "${params.buildDescription}" }
                git url: "${gretlJobRepoUrl}", branch: "${params.BRANCH ?: 'master'}", changelog: false
                dir(env.JOB_BASE_NAME) {
                    sh "gradle --init-script /home/gradle/init.gradle importDataToStage"
                }
                archiveArtifacts artifacts: '*.xtf'
                emailext (
                    to: '${DEFAULT_RECIPIENTS}',
                    recipientProviders: [requestor()],
                    subject: "ÖREB-Daten zum Review bereit (GRETL-Job ${JOB_NAME} ${BUILD_DISPLAY_NAME})",
                    body: "Mit dem GRETL-Job ${JOB_NAME} (${BUILD_DISPLAY_NAME}) wurden ÖREB-Daten bereitgestellt, die ein Review erfordern. Nach dem Review können Sie unter folgendem Link die Publikation der Daten veranlassen oder abbrechen: ${RUN_DISPLAY_URL}."
                )
            }
        }
        stage('Validation') {
            agent { label 'master' }
            steps {
                input message: "Fortfahren und die Daten publizieren?", ok: "OK"
            }
        }
        stage('Import into live schema') {
            agent { label 'gretl-ili2pg4' }
            steps {
                git url: "${gretlJobRepoUrl}", branch: "${params.BRANCH ?: 'master'}", changelog: false
                // Following command needs authentication, so use rather Copy Artifact plugin
                //sh 'curl --insecure -L -O ${BUILD_URL}artifact/*zip*/archive.zip'
                sh 'pwd && ls -la'
                echo 'Executing gradle importLive (import data, uploda data)'
            }
        }
       
    }
    post {
        always {
            echo 'deleteDir()'
        }
        unsuccessful {
            emailext (
                to: '${DEFAULT_RECIPIENTS}',
                recipientProviders: [requestor()],
                subject: "GRETL-Job ${JOB_NAME} (${BUILD_DISPLAY_NAME}) ist fehlgeschlagen",
                body: "Die Ausführung des GRETL-Jobs ${JOB_NAME} (${BUILD_DISPLAY_NAME}) war nicht erfolgreich. Details dazu finden Sie in den Log-Meldungen unter ${RUN_DISPLAY_URL}."
            )
        }
    }
}
