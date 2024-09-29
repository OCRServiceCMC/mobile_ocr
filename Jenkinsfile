pipeline {
    agent any

    environment {
        ANDROID_HOME = 'C:\Users\yunom\AppData\Local\Android\Sdk
        PATH = "${ANDROID_HOME}\\tools;${ANDROID_HOME}\\platform-tools;${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/OCRServiceCMC/mobile_ocr'
            }
        }
        stage('Install Flutter') {
            steps {
                bat '''
                choco install flutter --ignorechecksums -y
                refreshenv
                '''
            }
        }
        stage('Install Dependencies') {
            steps {
                bat 'C:\\tools\\flutter\\bin\\flutter pub get'
            }
        }
        stage('Build APK') {
            steps {
                bat 'C:\\tools\\flutter\\bin\\flutter build apk --release'
            }
        }
        stage('Dockerize') {
            steps {
                bat '''
                REM Kiểm tra và xóa container có cùng tên nếu tồn tại
                for /f "tokens=*" %%i in ('docker ps -aq -f "name=mobile_ocr_pipeline_container"') do (
                    docker rm -f %%i
                )

                REM Kiểm tra và xóa container sử dụng cùng cổng nếu tồn tại
                for /f "tokens=*" %%i in ('docker ps -q -f "publish=8081"') do (
                    docker rm -f %%i
                )

                REM Xây dựng Docker image và chạy container
                docker build -t mobile_ocr_pipeline .
                docker run -d -p 8081:8081 --name mobile_ocr_pipeline_container mobile_ocr_pipeline
                '''
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk', allowEmptyArchive: false
            }
        }
    }
    post {
        always {
            echo 'Cleaning up workspace...'
            deleteDir()
        }
    }
}
