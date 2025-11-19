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
        ssh_public_key_path = "/var/jenkins_home/.ssh/id_rsa.pub"


    
        vm_sizew = "Standard_B1ms" 
        vm_sizem = "Standard_B2ms"  
    }

    stages {

        /* ===========================
           Azure Authentication
           =========================== */
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

        /* ===========================
           Create terraform.tfvars
           =========================== */
        stage('Generate tfvars') {
            steps {
                dir('terraform') {
                    sh '''
cat > terraform.tfvars <<EOF
subscription_id       = "${SUBSCRIPTION_ID}"
tenant_id             = "${TENANT_ID}"
client_id             = "${CLIENT_ID}"
client_secret         = "${CLIENT_SECRET}"

location              = "${LOCATION}"
resource_group_name   = "${RESOURCE_GROUP}"

vnet_name             = "${VNET_NAME}"
subnet_name           = "${SUBNET_NAME}"

admin_username        = "${ADMIN_USERNAME}"
ssh_public_key_path   = "${SSH_KEY_PATH}"

vm_sizew              = "${VM_SIZEW}"
vm_sizem              = "${VM_SIZEM}"
EOF
                    '''
                }
            }
        }

        /* ===========================
           Terraform Init
           =========================== */
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -input=false'
                }
            }
        }

        /* ===========================
           Terraform Plan
           =========================== */
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan -input=false'
                }
            }
        }

        /* ===========================
           Terraform Apply or Destroy
           =========================== */
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

    /* ===========================
       Cleanup (remove secrets)
       =========================== */
    post {
        always {
            dir('terraform') {
                sh 'rm -f terraform.tfvars'
            }
            echo "Workspace cleaned."
        }
    }
}
