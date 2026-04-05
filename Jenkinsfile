pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - sleep
    args:
    - "9999999"
    volumeMounts:
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  - name: git
    image: alpine/git:latest
    command:
    - sleep
    args:
    - "9999999"
  volumes:
  - name: kaniko-secret
    projected:
      sources: []
'''
        }
    }

    environment {
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_REGION     = 'eu-central-1'
        ECR_REPO       = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/django-app"
        IMAGE_TAG      = "${BUILD_NUMBER}"
        GIT_REPO       = 'https://github.com/Etyamor/terraform-lesson-4.git'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                container('kaniko') {
                    sh """
                        /kaniko/executor \
                            --context=dir://\${WORKSPACE}/django-app \
                            --dockerfile=\${WORKSPACE}/django-app/Dockerfile \
                            --destination=\${ECR_REPO}:\${IMAGE_TAG} \
                            --destination=\${ECR_REPO}:latest \
                            --cache=false
                    """
                }
            }
        }

        stage('Update Helm Chart') {
            steps {
                container('git') {
                    withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            git config --global user.email "jenkins@ci.local"
                            git config --global user.name "Jenkins CI"

                            git clone https://\${GIT_USER}:\${GIT_TOKEN}@github.com/Etyamor/terraform-lesson-4.git repo
                            cd repo

                            sed -i "s|tag:.*|tag: \\"${IMAGE_TAG}\\"|" charts/django-app/values.yaml
                            sed -i "s|repository:.*|repository: ${ECR_REPO}|" charts/django-app/values.yaml

                            git add charts/django-app/values.yaml
                            git commit -m "ci: update image tag to ${IMAGE_TAG}"
                            git push origin main
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed. ArgoCD will sync the new image tag: ${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
