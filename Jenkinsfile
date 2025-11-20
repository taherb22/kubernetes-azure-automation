pipeline {
    agent any

    parameters {
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Destroy infrastructure instead of applying.')
    }

    environment {
        SUBSCRIPTION_ID = credentials('azure-subscription-id')
        TENANT_ID       = credentials('azure-tenant-id')
        CLIENT_ID       = credentials('azure-client-id')
        CLIENT_SECRET   = credentials('azure-client-secret')

        location            = "francecentral"
        resource_group_name = "k8s"

        vnet_name   = "k8s-vnet"
        subnet_name = "k8s-subnet"

        admin_username      = "azureuser"
        ssh_public_key_path = "/var/jenkins_home/.ssh/id_rsa.pub" // Jenkins SSH public key path (set as environment variable)

        vm_sizew = "Standard_B1ms"
        vm_sizem = "Standard_B2ms"

        ANSIBLE_HOST_KEY_CHECKING = 'False'  // Optional: Disable SSH key checking
    }

    stages {

        stage('Azure Login') {
            steps {
                sh '''
                az login --service-principal \
                    -u $CLIENT_ID \
                    -p $CLIENT_SECRET \
                    --tenant $TENANT_ID
                '''
            }
        }

        stage('Generate tfvars') {
            steps {
                dir('terraform') {
                    sh '''
cat > terraform.tfvars <<EOF
subscription_id       = "${SUBSCRIPTION_ID}"
tenant_id             = "${TENANT_ID}"
client_id             = "${CLIENT_ID}"
client_secret         = "${CLIENT_SECRET}"

location              = "${location}"
resource_group_name   = "${resource_group_name}"

vnet_name             = "${vnet_name}"
subnet_name           = "${subnet_name}"

admin_username        = "${admin_username}"
ssh_public_key_path   = "${ssh_public_key_path}"

vm_sizew              = "${vm_sizew}"
vm_sizem              = "${vm_sizem}"
EOF
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan -input=false'
                }
            }
        }

        stage('Apply or Destroy') {
            steps {
                dir('terraform') {
                    script {
                        if (params.DESTROY) {
                            echo "Destroying infrastructure..."
                            sh 'terraform destroy -auto-approve'
                        } else {
                            echo "Applying infrastructure..."
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }

 
    
    }
    post {
        always {
            dir('terraform') {
                sh 'rm -f terraform.tfvars'  // Clean up the terraform.tfvars file
            }
            echo "Workspace cleaned."
        }

        success {
            echo "Pipeline completed successfully."
        }

        failure {
            echo "Pipeline failed. Please check the logs."
        }
    }
}
