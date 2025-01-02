pipelineJob('wilt-cd-pipeline') {
    description('This is the CD pipeline for the Wilt project')

    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/Anjalymcr/Wilt.git')
                        credentials('github-token')
                    }
                    branch('main')
                }
            }
            scriptPath('wilt/jenkins/jenkinsfile')
        }
    }
}
