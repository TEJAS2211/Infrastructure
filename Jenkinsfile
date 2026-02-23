pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Select apply or destroy')
  }

  environment {
    AWS_REGION = 'us-east-1'
    TF_IN_AUTOMATION = 'true'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            terraform -version
            terraform -chdir=terraform/environments/prod init -upgrade
          '''
        }
      }
    }

    stage('Terraform Validate') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform -chdir=terraform/environments/prod validate'
        }
      }
    }

    stage('Checkov Scan (IaC Security)') {
      steps {
        sh '''
          if command -v checkov >/dev/null 2>&1; then
            checkov -d terraform/environments/prod --framework terraform --soft-fail
          else
            docker run --rm -v "$PWD:/tf" bridgecrew/checkov:latest \
              -d /tf/terraform/environments/prod --framework terraform --soft-fail
          fi
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform -chdir=terraform/environments/prod plan -out=tfplan'
        }
      }
    }

    stage('Terraform Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        input 'Approve production deployment?'
        script {
          env.TF_APPLY_RAN = 'true'
        }
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform -chdir=terraform/environments/prod apply -auto-approve tfplan'
        }
      }
    }

    stage('Force Destroy (Manual)') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        input 'Force destroy ALL infrastructure?'
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform -chdir=terraform/environments/prod destroy -auto-approve'
        }
      }
    }
  }

  post {
    failure {
      script {
        if (env.TF_APPLY_RAN == 'true') {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
            sh 'terraform -chdir=terraform/environments/prod destroy -auto-approve || true'
          }
        }
      }
      cleanWs()
    }
    success { cleanWs() }
    unstable { cleanWs() }
    aborted { cleanWs() }
  }
}
