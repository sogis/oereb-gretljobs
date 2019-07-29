pipeline {
    agent none
    parameters {
        string(name: 'buildDescription', description: 'Bitte geben Sie den Grund für die Publikation der Daten ein')
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '25'))
        disableConcurrentBuilds()
        timeout(time: 3, unit: 'MINUTES')
    }
    stages {
        stage('Import into staging schema') {
            agent { label 'gretl' }
            steps {
                script { currentBuild.description = "${params.buildDescription}" }
                git url: 'https://github.com/schmandr/oereb-gretljobs.git'
                sh 'pwd && ls -la'
                echo 'Executing gradle importStaging (transform data, export data, import data)'
                sh 'touch a.xtf && touch b.xtf'
                archiveArtifacts artifacts: '*.xtf'
                echo "Send E-Mails (containing link to ${BUILD_URL}input/)"
            }
        }
        stage('Validation') {
            agent { label 'master' }
            steps {
                input message: 'Sollen die Daten publiziert werden?'
            }
        }
        stage('Import into live schema') {
            agent { label 'gretl' }
            steps {
                git url: 'https://github.com/schmandr/oereb-gretljobs.git'
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
        failure {
            echo 'Send E-Mail'
        }
    }
}
