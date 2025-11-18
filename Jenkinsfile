pipeline {
    agent any

    environment {
        SUBSCRIPTION_ID = credentials('azure-subscription-id')
        TENANT_ID       = credentials('azure-tenant-id')
        LOCATION        = 'East US'
        RESOURCE_GROUP  = 'my-rg'
        CLIENT_ID       = credentials('azure-client-id')       // SP App ID
        CLIENT_SECRET   = credentials('azure-client-secret')   // SP Password
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
                    sh '''
                    terraform plan -out=tfplan -input=false \
                        -var "subscription_id=$SUBSCRIPTION_ID" \
                        -var "tenant_id=$TENANT_ID" \
                        -var "location=$LOCATION" \
                        -var "resource_group_name=$RESOURCE_GROUP"
                    '''
                }
            }
        }

         stage('Terraform Apply/Destroy') {
            steps {
                dir('terraform') {
                    script {
                        if (params.DESTROY) {
                            echo "Destroying infrastructure..."
                            sh 'terraform destroy -auto-approve \
                                -var "subscription_id=$SUBSCRIPTION_ID" \
                                -var "tenant_id=$TENANT_ID" \
                                -var "client_id=$CLIENT_ID" \
                                -var "client_secret=$CLIENT_SECRET" \
                                -var "location=$LOCATION" \
                                -var "resource_group_name=$RESOURCE_GROUP"'
                        } else {
                            echo "Applying infrastructure..."
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }
    }
}

