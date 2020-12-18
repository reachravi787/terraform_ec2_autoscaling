node {
    stage ('remove files'){
        sh '''rm -rf terraform_ec2_autoscaling terraform_ec2_autoscaling.zip'''
    stage('git'){
        git branch: 'main', credentialsId: 'Github_s3', url: 'https://github.com/reachravi787/terraform_ec2_autoscaling.git'
    }
    stage ('git clone'){
       sh '''git clone https://github.com/reachravi787/terraform_ec2_autoscaling.git

zip -r terraform_ec2_autoscaling.zip terraform_ec2_autoscaling'''
    }
    stage ('upload'){
        dir('/var/lib/jenkins/workspace/Upload_to_S3'){
            pwd();
            withAWS(region:'us-east-1', credentials: 'AWS_ID'){
                def identity=awsIdentity();
                s3Upload(file:'terraform_ec2_autoscaling.zip' bucket:'ravi-backup-bucket', path:'/var/lib/jenkins/workspace/Upload_to_S3/terraform_ec2_autoscaling.zip');
            }
          }   
        }
}
}
