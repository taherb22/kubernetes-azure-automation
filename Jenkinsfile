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
       // SSH KEY PATHS
        ssh_public_key_path  = "/var/jenkins_home/.ssh/id_rsa.pub"   // for Terraform
        ssh_private_key_path = "/var/jenkins_home/.ssh/id_rsa"       // for Ansible (IMPORTANT)

        
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
ssh_private_key_path  = "${ssh_private_key_path}"
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

        stage('Generate Dynamic Inventory') {
            when {
                expression { return !params.DESTROY }   // Skip if DESTROY = true
            }
            steps {
                script {
                    dir('terraform') {
                        def master_ip = sh(script: 'terraform output -raw master_public_ip', returnStdout: true).trim()
                        def worker_ips_raw = sh(script: 'terraform output -raw worker_public_ips', returnStdout: true).trim()

                        // IMPORTANT: Return values to parent script
                        env.MASTER_IP = master_ip
                        env.WORKER_IPS_RAW = worker_ips_raw
                    }

                    def master_ip       = env.MASTER_IP
                    def worker_ips_raw  = env.WORKER_IPS_RAW
                    def ssh_private_key_path = env.ssh_private_key_path


                    
                    // Generate the inventory file content with dynamic ssh key path
                    def inventoryContent = """[masters]
master ansible_host=${master_ip} ansible_user=azureuser ansible_ssh_private_key_file=${ssh_private_key_path}

[workers]
"""


                    
                    // Add worker nodes to the inventory with dynamic ssh key path
                    worker_ips.eachWithIndex { ip, index ->
                        inventoryContent += "worker${index + 1} ansible_host=${ip} ansible_user=azureuser ansible_ssh_private_key_file=${ssh_private_key_path}\n"
                    }

                    // Write the inventory content to a file
                    writeFile(file: 'inventory.ini', text: inventoryContent)
                    // Debug: print inventory content to Jenkins console
                    sh 'echo "===== GENERATED INVENTORY ====="'
                    sh 'cat inventory.ini'
                    sh 'echo "================================"'
                }
            }
        }

        stage('Ansible Playbook Configuration') {
            when {
                expression { return !params.DESTROY }   // Skip if DESTROY = true
            }
            steps {
                script {
                    // Run the Ansible Playbook
                    def playbookResult = sh(script: 'ansible-playbook -i inventory.ini ansible/playbook.yml --extra-vars "admin_username=${admin_username} ssh_key_path=${ssh_public_key_path}"', returnStatus: true)
                    
                    echo "Ansible exit code: ${playbookResult}"
                    // Check if Ansible Playbook run was successful
                    if (playbookResult != 0) {
                        dir('terraform') {
                            sh 'terraform destroy -auto-approve'
                        }
                        error "Ansible Playbook failed, triggering destroy..."
                    } else {
                        echo "Ansible playbook executed successfully."
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
            // Cleanup ansible inventory
            sh 'rm -f inventory.ini'
            sh 'rm -rf ansible/.ansible'
            sh 'rm -rf ~/.ansible'
            echo "Workspace cleaned."
        }

        success {
            echo "Pipeline completed successfully."
        }

        failure {
            echo "Pipeline failed."
        }
    }
}
