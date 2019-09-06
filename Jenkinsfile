node('master') { // need a few lines of scripted pipeline before the declarative pipeline...
    stage('Prepare') {
        gretlJobsRepoUrl = env.GRETL_JOB_REPO_URL
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
        timeout(time: 3, unit: 'MINUTES')
    }
    stages {
        stage('Import into staging schema') {
            agent { label 'gretl-ili2pg4' }
            steps {
                script { currentBuild.description = "${params.buildDescription}" }
                git url: "${gretlJobsRepoUrl}", branch: "${params.BRANCH ?: 'master'}", changelog: false
                sh 'pwd && ls -la'
                echo 'Executing gradle importStaging (transform data, export data, import data)'
                sh 'touch a.xtf && touch b.xtf'
                archiveArtifacts artifacts: '*.xtf'
                echo "Send E-Mails (containing link to ${BUILD_URL}input/)"
            }
        }
        stage('Import into live schema') {
            agent { label 'gretl-ili2pg4' }
            steps {
                input message: 'Möchten Sie die Daten publizieren?'
                git url: "${gretlJobsRepoUrl}", branch: "${params.BRANCH ?: 'master'}", changelog: false
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
                subject: "GRETL-Job ${env.JOB_NAME} (${env.BUILD_DISPLAY_NAME}) ist fehlgeschlagen",
                body: "Die Ausführung des GRETL-Jobs ${env.JOB_NAME} (${env.BUILD_DISPLAY_NAME}) war nicht erfolgreich. Details dazu finden Sie in den Log-Meldungen unter ${env.BUILD_URL}."
            )
        }
    }
}
