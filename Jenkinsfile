def registry = "harbor.sun.com"
// 项目
def project = "ukubernetes"
def app_name = "java-examples"
def project_version = "1.0"
// def tag = v0.${BUILD_NUMBER}
def image_name = "${registry}/${project}/${app_name}-${project_version}:v0.${BUILD_NUMBER}"
def host_name = "example.sun.com"

// 认证
def secret_name = "harbor-registry"


node('sun-jnlp') {
	stage('Clone:拉取代码') {
        echo "1.Clone Stage"
	checkout()
    }
    
    stage('Test:测试') {
		echo "2.Test Stage"
    }
    stage('Build:代码编译及构建镜像') {
		echo "3.Build Docker Image Stage"
// 		sh "docker build -t ${image_name} ."
		sh """
		    ls
		    mvn clean package -Dmaven.test.skip=true dockerfile:build -Ddockerfile.tag=v0.${BUILD_NUMBER}
		    ls target
	    """
    }
    stage('Push:镜像上传') {
		echo "4.Push Docker Image Stage"
		withCredentials([usernamePassword(credentialsId: 'HarBor', usernameVariable: 'HarBorUser', passwordVariable: 'HarBorPassword')]) {
            sh """
				docker login ${registry} -u ${HarBorUser} -p ${HarBorPassword}
				mvn dockerfile:push
			"""
        }
    }
    stage('YAML:修改YAML文件') {
		echo "5. Change YAML File Stage"
		sh """
			pwd
            ls
            sed -i 's#IMAGE_NAME#${image_name}#' deploy.yaml
            sed -i 's#SECRET_NAME#${secret_name}#' deploy.yaml
            sed -i 's#RSCOUNT#${ReplicaCount}#' deploy.yaml
            sed -i 's#NS#${Namespace}#' deploy.yaml	
            sed -i 's#HOSTNAME#${host_name}#' deploy.yaml
		"""
    }
    stage('Deploy:部署') {
		echo "6. Deploy Stage"
		sh """
			kubectl -n ${Namespace} apply -f deploy.yaml
			sleep 10
			kubectl -n ${Namespace} get pod
		"""
    }
}
