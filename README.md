Primeros pasos con Jenkins
===========================

Quick start install Jenkins
==============================
1. install docker
2. install docker-compose
3. pull image jenkins/jenkins de hub.docker.com
4. create file docker-compose.yml con el siguiente contenido
```docker
version: '3'
services:
  jenkins:
    container_name: jenkins
    image: jenkins/jenkins
    ports:
      - "8080:8080"
    volumes:
      - $PWD/jenkins_home:/var/jenkins_home
    networks:
      - net
networks:
  net:
```
4.1. crear la siguiente ruta ./jenkins_home
5. acceder al siguiente enlace http://localhost:8080
6. se solicitara un hash o contraseña obtnerlo de la siguiente ruta. Con el siguiente comado se obtendra la contraseña.
```bash
cat jenkins_home/secrets/initialAdminPassword
```
copiar el hash arrojado por el comando anterior y pegar en la pagina de inicio http://localhost:8080
7. Se mostrará dos opciones para instalar los plugins que utilizará jenkins, por ser la primera vez seleccionar la primera opción que es la instalación de los plugins sugeridos por Jenkins. Esperar a que finalicé la instalación de los plugin y mostrará un ventana par crear la primera cuenta.
8. en la vista "Create First Admin User", ingresar los siguientes datos.
  - username: admin
  - password: ******
  - Full name: admin
  - E-mail address: admin@admin.com
y presionar el botón "Save and Continue"
9. mostrará un modal con la url con la se prodrá acceder a Jenkins, esta variable se puede modificar más adelante sin problemas. "Continuar"
10. Se muestra un mensaje de que Jenkins está listo para iniciar presionar botón "Start using Jenkins". esá acción nos llevara a la pagina de inicio de Jenkins.

Docker compose
=============================
docker-compose up -d -> para crear y/o lenvatar el servicio
docker-compose start -> solo para servicio que ya existan previamente
docker-compose stop -> para parar el servicio que este corriendo
docker compose down -> para eliminar los componentes que haya creado docker componse

Jenkins UI
==============================
Manage Jenkins: parte de cofiguración del sistema
- autenticación
- credenciales
- install plugins

First Job
=======================
1. Seleccionar "New Item"
2. Selecionar nuevo proyecto de estilolibre
3. en la sección "Build", seleccionar la opción "Execute Shell" y agregar el siguiente comando.
```bash
echo "hello world"
```
presionar en el botón "Save"
4. hacer click en el "Build Now"

#### Pasar Variables en Shell

Se puede realizar de multiples formas una de ellas se detalla acontinuación:

Se debe de relizar las siguientes pasos:

- Crear un script bash con el siguiente contenido.
```bash
#!/bin/bash

NAME=$1
LASTNAME=$2
echo hola, $NAME $LASTNAME
```

> - dónde #!/bin/bash,  permite determinar qué intérprete se encargará de ejecutar el resto del script.
> - dónde NAME=$1 y LASTNAME=$2 son variables locales que reciben asignaciones de argumentos que seran introducidas desde el entorno de ejecución.
> - finalmente echo hola, $NAME $LASTNAME, es el command line que jenkins estará ejecutando.
