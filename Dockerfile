# ETAPA 1: Construcción (Build Stage)
# Usamos Maven con Java 21 (basado en la versión de Java en su pom.xml)
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de configuración de Maven (pom.xml) para descargar dependencias primero
COPY pom.xml .

# Descarga las dependencias del proyecto. Si no hay cambios en el pom.xml,
# esta capa de caché no se invalida, acelerando futuras construcciones.
RUN mvn dependency:go-offline -B

# Copia todo el código fuente del proyecto
COPY src ./src

# Empaqueta la aplicación como un archivo JAR ejecutable, saltando las pruebas
RUN mvn package -DskipTests

# Nombre del archivo JAR final basado en el pom.xml (artifactId-version.jar)
ARG JAR_FILE=target/gatewey-0.0.1-SNAPSHOT.jar

# ----------------------------------------------------------------------------

# ETAPA 2: Ejecución (Runtime Stage)
# Usamos una imagen mínima con solo el JRE de Java 21 (más pequeño y seguro)
FROM eclipse-temurin:21-jre-alpine

# Expone el puerto que usa su aplicación (server.port=8080 en application.properties)
EXPOSE 8080

# Establece la variable de entorno para el archivo JAR
ARG JAR_FILE=/app/target/gatewey-0.0.1-SNAPSHOT.jar
# Copia el archivo JAR de la etapa de construcción a la etapa de ejecución
COPY --from=build ${JAR_FILE} app.jar

# Comando para ejecutar la aplicación
# Se recomienda configurar las opciones de JVM para producción, como el tamaño de heap.
ENTRYPOINT ["java", "-jar", "/app.jar"]
