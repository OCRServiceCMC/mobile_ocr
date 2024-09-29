pipeline {
    agent any

    tools {
        flutter 'Flutter'  // Đảm bảo rằng 'Flutter' đã được cấu hình trong Jenkins Tools Configuration
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/OCRServiceCMC/mobile_ocr'
            }
        }
        stage('Install Dependencies') {
            steps {
                bat 'flutter pub get'
            }
        }
        stage('Build APK') {
            steps {
                bat 'flutter build apk --release'
            }
        }
        stage('Dockerize') {
            steps {
                bat '''
                REM Kiểm tra và xóa container có cùng tên nếu tồn tại
                for /f "tokens=*" %%i in ('docker ps -aq -f "name=mobile-ocr-container"') do (
                    docker rm -f %%i
                )

                REM Kiểm tra và xóa container sử dụng cùng cổng nếu tồn tại
                for /f "tokens=*" %%i in ('docker ps -q -f "publish=8081"') do (
                    docker rm -f %%i
                )

                REM Xây dựng Docker image và chạy container
                docker build -t mobile-ocr .
                docker run -d -p 8081:8081 --name mobile-ocr-container mobile-ocr
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
