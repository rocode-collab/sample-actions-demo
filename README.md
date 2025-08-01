# Sample Java Application

A deployable Spring Boot Java application with REST endpoints, health checks, and containerization support.

## Features

- **Spring Boot 3.2.0** with Java 17
- **REST API** with multiple endpoints
- **Health checks** and monitoring
- **Docker** containerization
- **GitHub Actions** CI/CD pipeline
- **Maven** build system

## API Endpoints

| Endpoint | Description | Method |
|----------|-------------|--------|
| `/` | Welcome message | GET |
| `/hello` | Personalized greeting | GET |
| `/health` | Health check | GET |
| `/info` | Application info | GET |
| `/actuator/health` | Spring Boot health | GET |
| `/actuator/info` | Spring Boot info | GET |

## Quick Start

### Prerequisites

- Java 17 or higher
- Maven 3.6+ (or use Maven wrapper)
- Docker (optional, for containerized deployment)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sample-actions-demo
   ```

2. **Build the application**
   ```bash
   ./mvnw clean package
   ```

3. **Run the application**
   ```bash
   java -jar target/sample-app-1.0.0.jar
   ```

4. **Test the application**
   ```bash
   curl http://localhost:8080/
   curl http://localhost:8080/hello?name=YourName
   curl http://localhost:8080/health
   ```

### Docker Deployment

1. **Build the Docker image**
   ```bash
   docker build -t sample-java-app .
   ```

2. **Run the container**
   ```bash
   docker run -p 8080:8080 sample-java-app
   ```

3. **Using Docker Compose**
   ```bash
   docker-compose up -d
   ```

## Deployment Options

### 1. Traditional Deployment

Build the JAR file and deploy to any Java application server:

```bash
./mvnw clean package
java -jar target/sample-app-1.0.0.jar
```

### 2. Docker Deployment

Deploy as a containerized application:

```bash
docker build -t sample-java-app .
docker run -d -p 8080:8080 --name java-app sample-java-app
```

### 3. Cloud Deployment

#### Azure App Service
```bash
# Build the application
./mvnw clean package

# Deploy to Azure App Service
az webapp deploy --resource-group <resource-group> --name <app-name> --src-path target/sample-app-1.0.0.jar
```

#### AWS Elastic Beanstalk
```bash
# Create deployment package
./mvnw clean package
# Upload the JAR file to AWS Elastic Beanstalk
```

#### Google Cloud Run
```bash
# Build and deploy to Cloud Run
gcloud run deploy sample-java-app --source .
```

### 4. Kubernetes Deployment

Create a Kubernetes deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-java-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-java-app
  template:
    metadata:
      labels:
        app: sample-java-app
    spec:
      containers:
      - name: sample-java-app
        image: sample-java-app:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_PORT` | 8080 | Application port |
| `SPRING_PROFILES_ACTIVE` | dev | Active Spring profile |
| `JAVA_OPTS` | -Xmx512m -Xms256m | JVM options |

### Application Properties

The application uses `application.yml` for configuration. Key settings:

- **Server port**: 8080
- **Health endpoints**: Enabled
- **Logging**: Configured for console output
- **Actuator**: Health, info, and metrics endpoints exposed

## Monitoring and Health Checks

The application includes built-in monitoring:

- **Health endpoint**: `GET /health`
- **Spring Boot Actuator**: `GET /actuator/health`
- **Application info**: `GET /info`
- **Metrics**: `GET /actuator/metrics`

## CI/CD Pipeline

The GitHub Actions workflow uses a single reusable workflow that handles both building and deploying:

1. **Build and Deploy Job**: Uses reusable java-reusable.yml workflow
   - Sets up Java 17
   - Runs security checks using Azure authentication
   - Builds the application using Maven
   - Runs unit tests
   - Uploads build artifacts
   - Deploys to Azure App Service

Triggered on:
- Push to main/master branch
- Pull requests (build only, no deployment)

## Development

### Project Structure

```
├── src/
│   ├── main/
│   │   ├── java/com/example/
│   │   │   ├── SampleApplication.java
│   │   │   └── controller/
│   │   │       └── HelloController.java
│   │   └── resources/
│   │       └── application.yml
│   └── test/
│       └── java/com/example/
│           └── SampleApplicationTests.java
├── .github/workflows/
│   └── build-and-deploy.yml
├── Dockerfile
├── docker-compose.yml
├── pom.xml
└── README.md
```

### Adding New Endpoints

1. Create a new controller class in `src/main/java/com/example/controller/`
2. Add `@RestController` annotation
3. Define endpoints with `@GetMapping`, `@PostMapping`, etc.
4. Test locally and deploy

### Testing

```bash
# Run all tests
./mvnw test

# Run specific test
./mvnw test -Dtest=SampleApplicationTests

# Run with coverage
./mvnw jacoco:report
```

## Azure App Service Deployment

This application is configured to deploy to Azure App Service using free Azure plans (F1 tier).

### Required Setup

1. **Configure GitHub Secrets**: See `AZURE_SETUP.md` for detailed instructions
2. **Create Azure App Service**: Follow the setup guide for creating the App Service
3. **Set up Azure Authentication**: Configure the required Azure AD app registration

### Required Secrets

- `AZURE_CREDENTIALS`: Azure service principal credentials (JSON)
- `AZURE_WEBAPP_NAME`: Azure App Service name
- `AZURE_WEBAPP_PUBLISH_PROFILE`: Azure App Service publish profile

### Deployment Process

The workflow uses a single reusable workflow that handles:

1. **Build and Deploy Phase**: Uses reusable java-reusable.yml workflow
   - Java 17 setup
   - Maven build and test
   - Azure security checks
   - Artifact upload
   - Azure App Service deployment
   - Health checks

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Change port in application.yml or use environment variable
   SERVER_PORT=8081 java -jar target/sample-app-1.0.0.jar
   ```

2. **Memory issues**
   ```bash
   # Increase heap size
   java -Xmx1g -jar target/sample-app-1.0.0.jar
   ```

3. **Docker build fails**
   ```bash
   # Clean and rebuild
   docker system prune -a
   docker build --no-cache -t sample-java-app .
   ```

4. **Azure deployment fails**
   - Check all required secrets are configured
   - Verify Azure App Service exists and is running
   - Ensure Azure authentication is properly set up
   - Review the `AZURE_SETUP.md` guide

## License

This project is licensed under the MIT License. 