pipeline {
    agent none
    triggers{
        upstream(upstreamProjects: 'UCSB-PSTAT GitHub/base-rstudio/main', threshold: hudson.model.Result.SUCCESS)
    }
    environment {
        IMAGE_NAME = 'envs193ds'
    }
    stages {
        stage('Build Test Deploy') {
            agent {
                kubernetes {
                    cloud 'rke-test'
                    inheritFrom 'podman'
                }
            }
            stages{
                stage('Build') {
                    steps {
                        script {
                            if (currentBuild.getBuildCauses('com.cloudbees.jenkins.GitHubPushCause').size() || currentBuild.getBuildCauses('jenkins.branch.BranchIndexingCause').size()) {
                               scmSkip(deleteBuild: true, skipPattern:'.*\\[ci skip\\].*')
                            }
                        }
                        container('podman') {
                            echo "NODE_NAME = ${env.NODE_NAME}"
                            sh 'podman build -t localhost/$IMAGE_NAME --pull --force-rm --no-cache .'
                        }
                    }
                    post {
                        unsuccessful {
                            container('podman') {sh 'podman rmi -i localhost/$IMAGE_NAME || true'}
                        }
                    }
                }
                stage('Test') {
                    steps {
                        container('podman') {
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME which rstudio'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -q -e "getRversion() >= \\"4.1.3\\"" | tee /dev/stderr | grep -q "TRUE"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"AICcmodavg\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"broom\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"car\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"corrplot\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"DHARMa\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"flextable\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"GGally\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"ggeffects\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"glmmTMB\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"Hmisc\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"janitor\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"lterdatasampler\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"magick\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"MuMIn\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"naniar\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"NatParksPalettes\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"palmerpenguins\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"patchwork\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"performance\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"plotly\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"skimr\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"tidyverse\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"wesanderson\")"'
                            sh 'podman run -d --name=$IMAGE_NAME --rm --pull=never -p 8888:8888 localhost/$IMAGE_NAME start-notebook.sh --NotebookApp.token="jenkinstest"'
                            sh 'sleep 10 && curl -v http://localhost:8888/rstudio?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s[1-3][0-9][0-9]\\s+[\\w\\s]+\\s*$"'
                            sh 'curl -v http://localhost:8888/lab?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                            sh 'curl -v http://localhost:8888/tree?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                        }
                    }
                    post {
                        always {
                            container('podman') {sh 'podman rm -ifv $IMAGE_NAME'}
                        }
                        unsuccessful {
                            container('podman') {sh 'podman rmi -i localhost/$IMAGE_NAME || true'}
                        }
                    }
                }
                stage('Deploy') {
                    when { branch 'main' }
                    environment {
                        DOCKER_HUB_CREDS = credentials('DockerHubToken')
                    }
                    steps {
                        container('podman') {
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:latest --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:v$(date "+%Y%m%d") --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                        }
                    }
                    post {
                        always {
                            container('podman') {sh 'podman rmi -i localhost/$IMAGE_NAME || true'}
                        }
                    }
                }                
            }
            post {
                always {
                    container('podman') {sh 'podman rmi -i localhost/$IMAGE_NAME || true'}
                }
            }
        }
    }
    post {
        success {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'good', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'danger', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
