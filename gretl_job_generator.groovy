// set default values
def gretlJobFilePath = '*'
def gretlJobFileName = 'build.gradle'
def jenkinsfileName = 'Jenkinsfile'
def jobPropertiesFileName = 'job.properties'

def jobNamePrefix = ''


// search for files (gretlJobFileName) that are causing the creation of a GRETL-Job
def jobFilePattern = "${gretlJobFilePath}/${gretlJobFileName}"
println 'job file pattern: ' + jobFilePattern
def jobFiles = new FileNameFinder().getFileNames(WORKSPACE, jobFilePattern)


// generate the jobs
println 'generating the jobs...'
for (jobFile in jobFiles) {
  // get the folder name (is at position 2 from the end of the jobFile path)
  def folderName = jobFile.split('/').getAt(-2)

  // define the job name
  def jobName = "${jobNamePrefix}${folderName}"
  println 'Job ' + jobName

  // set the path to the default Jenkinsfile
  def pipelineFilePath = "${WORKSPACE}/${jenkinsfileName}"
  // check if job provides its own Jenkinsfile
  def customPipelineFilePath = "${folderName}/${jenkinsfileName}"
  if (new File(WORKSPACE, customPipelineFilePath).exists()) {
    pipelineFilePath = customPipelineFilePath
    println '    custom pipeline file found: ' + customPipelineFilePath
  }
  // read Jenkinsfile content
  def pipelineScript = readFileFromWorkspace(pipelineFilePath)


  // set defaults for job properties
  def properties = new Properties([
    'authorization.permissions':'nobody',
    'logRotator.numToKeep':'unlimited',
    'parameters.fileParam':'none',
    'parameters.stringParam':'buildDescription;Keine Beschreibung angegeben;Beschreibung/Grund für die Publikation der Daten',
    'triggers.upstream':'none',
    'triggers.cron':''
  ])
  def propertiesFilePath = "${folderName}/${jobPropertiesFileName}"
  def propertiesFile = new File(WORKSPACE, propertiesFilePath)
  if (propertiesFile.exists()) {
    println '    properties file found: ' + propertiesFilePath
    properties.load(new FileReader(propertiesFile))
  }

  def productionEnv = ("${PROJECT_NAME}" == 'agi-gretl-production')

  pipelineJob(jobName) {
    if (!productionEnv) { // we don't want the BRANCH parameter in production environment
      parameters {
        stringParam('BRANCH', 'main', 'Name of branch to check out')
      }
    }
    if (properties.getProperty('parameters.fileParam') != 'none') {
      parameters {
        fileParam(properties.getProperty('parameters.fileParam'), 'Select file to upload')
      }
    }
    if (properties.getProperty('parameters.stringParam') != 'none') {
      def propertyValues = properties.getProperty('parameters.stringParam').split(';')
      if (propertyValues.length == 3) {
        parameters {
          stringParam(propertyValues[0], propertyValues[1], propertyValues[2])
        }
      }
    }
    if (properties.getProperty('authorization.permissions') != 'nobody') {
      authorization {
        permissions(properties.getProperty('authorization.permissions'), ['hudson.model.Item.Build', 'hudson.model.Item.Read'])
      }
    }
    if (properties.getProperty('logRotator.numToKeep') != 'unlimited') {
      logRotator {
        numToKeep(properties.getProperty('logRotator.numToKeep') as Integer)
      }
    }
    if (properties.getProperty('triggers.upstream') != 'none') {
      triggers {
        upstream(properties.getProperty('triggers.upstream'), 'SUCCESS')
      }
    }
    if (properties.getProperty('triggers.cron') != '' && productionEnv) { // we want triggers only in production environment
      triggers {
        cron(properties.getProperty('triggers.cron'))
      }
    }

    environmentVariables {
      // make the Git repository URL available on the Jenkins agent
      env('GIT_REPO_URL', GRETL_JOB_REPO_URL_OEREB_V2)
    }

    definition {
      cps {
        script(pipelineScript)
        sandbox()
      }
    }
  }
}

// add a view (tab) for these jobs
listView('ÖREB-v2-GRETL-Jobs') {
  jobs {
    regex(/^(oerebv2_.*|gretl-job-generator-oerebv2)/)
  }
  columns {
    status()
    weather()
    name()
    lastSuccess()
    lastFailure()
    lastDuration()
    buildButton()
    favoriteColumn()
  }
}
