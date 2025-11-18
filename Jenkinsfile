pipeline {
    agent any

    environment {
        // Azure Service Principal credentials configured in Jenkins (type: Azure Service Principal)
        AZURE_CREDENTIALS = 'azure cred' // replace with your credential ID
        // Terraform working directory
        TERRAFORM_DIR = 'terraform' // replace with your Terraform code path
    }
    
   
    
    parameters {
        booleanParam(
            name: 'DESTROY',
            defaultValue: false,
            description: 'Set to true to run terraform destroy instead of apply'
        )
    }


    stages {
        stage('Checkout') {
            steps {
                echo "Checking out repository..."
                checkout scm
            }
        }

         stage('Azure Login') {
            steps {
                // Use the Azure Service Principal plugin properly
                azureServicePrincipal(
                    credentialsId: 'azure cred', // your Jenkins Azure SP credential ID
                    
                ) {
                    echo 'Logged in to Azure successfully'
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    echo "Initializing Terraform..."
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    echo "Running Terraform Plan..."
                    sh 'terraform plan -out=tfplan -input=false'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    input message: "Approve Terraform Apply?", ok: "Apply"
                    echo "Applying Terraform plan..."
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { return params.DESTROY }   // Only run when destroy=true
            }
            steps {
                dir(TERRAFORM_DIR) {
                    input message: "Confirm Terraform Destroy?", ok: "Destroy"
                    sh 'terraform destroy -auto-approve'
                }
            }
        }        

    }

    post {
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
        success {
            echo "Terraform provisioning completed successfully."
        }
        failure {
            echo "Terraform provisioning failed."
        }
    }
}
