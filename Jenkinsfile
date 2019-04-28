#!groovy
import com.bit13.jenkins.*

properties ([
	buildDiscarder(logRotator(numToKeepStr: '25', artifactNumToKeepStr: '25')),
	disableConcurrentBuilds(),
	pipelineTriggers([
		pollSCM('H/30 * * * *')
	]),
])


node ("node") {
	def ProjectName = "voice-create-bot-docker"
	def slack_notify_channel = null

	def MAJOR_VERSION = 1
	def MINOR_VERSION = 0

	env.PROJECT_MAJOR_VERSION = MAJOR_VERSION
	env.PROJECT_MINOR_VERSION = MINOR_VERSION

	env.CI_BUILD_VERSION = Branch.getSemanticVersion(this)
	env.CI_DOCKER_ORGANIZATION = Accounts.GIT_ORGANIZATION
	env.CI_PROJECT_NAME = ProjectName
	currentBuild.result = "SUCCESS"
	def errorMessage = null

	if(env.BRANCH_NAME ==~ /master$/) {
			return
	}

	wrap([$class: 'TimestamperBuildWrapper']) {
		wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
			Notify.slack(this, "STARTED", null, slack_notify_channel)
			try {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.CI_ARTIFACTORY_CREDENTIAL_ID,
									usernameVariable: 'ARTIFACTORY_USERNAME', passwordVariable: 'ARTIFACTORY_PASSWORD']]) {
					stage ("install" ) {

						env.DISCORD_BOT_TOKEN = SecretsVault.get(this, "secret/${env.CI_PROJECT_NAME}", "DISCORD_BOT_TOKEN")
						env.VCB_DB_PATH = SecretsVault.get(this, "secret/${env.CI_PROJECT_NAME}", "VCB_DB_PATH")

						deleteDir()
						Branch.checkout(this, env.CI_PROJECT_NAME)
						Pipeline.install(this)
					}
					stage ("lint") {
						sh script: "${WORKSPACE}/.deploy/lint.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
					}
					stage ("build") {
						sh script: "${WORKSPACE}/.deploy/build.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
					}
					stage ("test") {
						sh script: "${WORKSPACE}/.deploy/test.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
					}
					stage ("deploy") {
						sh script: "${WORKSPACE}/.deploy/deploy.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
					}
					stage ('publish') {
						sh script:  "${WORKSPACE}/.deploy/validate.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"

						Branch.publish_to_master(this)
						Pipeline.publish_buildInfo(this)
					}
				}
			} catch(err) {
				currentBuild.result = "FAILURE"
				errorMessage = err.message
				throw err
			}
			finally {
				Pipeline.finish(this, currentBuild.result, errorMessage)
			}
		}
	}
}
