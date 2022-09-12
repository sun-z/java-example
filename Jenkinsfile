def registry = "harbor.sun.com"
// 项目
def project = "ukubernetes"
def app_name = "java-example"
def project_version = "1.0"
// def tag = v0.${BUILD_NUMBER}
def image_name = "${registry}/${project}/${app_name}-${project_version}:v0.${BUILD_NUMBER}"
def host_name = "example.sun.com"

// 认证
def secret_name = "harbor-registry"


node('sun-jnlp') {
	 // 拉取代码
	stage('Clone:拉取代码') {
        	echo "1.Clone Stage"
		checkout scm
    	}
	
    	stage('Test:测试') {
		echo "2.Test Stage"
    	}
	// 代码编译及打包成镜像
    	stage('Build:代码编译及构建镜像') {
		echo "3.Build Docker Image Stage"
// 		sh "docker build -t ${image_name} ."
		sh """
		    ls
		    mvn clean package -Dmaven.test.skip=true dockerfile:build -Ddockerfile.tag=v0.${BUILD_NUMBER}
		    ls target
	    	"""
    	}
	// 项目镜像推送到仓库
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
	// 部署到K8S主机
    	stage('Deploy:部署') {
// 		when { environment name: 'action', value: 'release' }
		echo "6. Deploy Stage"
		sh """
			kubectl -n ${Namespace} apply -f deploy.yaml  --record=true
			sleep 10
			kubectl -n ${Namespace} get pod
		"""
    	}
	// K8S紧急时回滚
    	stage('Rollback to k8s') {
// 		when { environment name: 'action', value: 'rollback' }
		echo "k8s images is rolled back! " 
		sh """
             		kubectl describe deployment ${app_name} -n ${Namespace} |grep -w 'Image:'
//                     	kubectl rollout undo deployment ${app_name} -n ${Namespace}
//                     	kubectl describe deployment ${app_name} -n ${Namespace} |grep -w 'Image:'
            	"""
       }  
}
