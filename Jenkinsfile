node {
    stage('git'){
        git credentialsId: 'Github_ID', url: ' https://github.com/reachravi55/maven_demo.git'
    }
        stage ('upload to s3'){
       sh '''git clone https://github.com/reachravi787/terraform_ec2_autoscaling.git

zip -r terraform_ec2_autoscaling.zip terraform_ec2_autoscaling

aws s3 cp "$PWD/terraform_ec2_autoscaling.zip" s3://ravi-backup-bucket/

rm -rf terraform_ec2_autoscaling terraform_ec2_autoscaling.zip'''
    }

}
