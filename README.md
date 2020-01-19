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

- copiar el script en la siguiente ruta del servidor jenkins /opt/script.sh
- ahora en el jenkins en el proyecto creado anteriormente hay que edidar la sección **"Build"**
    ```bash
    NAME=Chris
    LASTNAME=Valdez

    /opt/script.sh $NAME $LASTNAME
    ```

#### Agregar parametros al Job

1. Ingresar al Job que se esta trabajando, y acceder a las opciones de configuración.
2. buscar la opción *"Esta ejecución debe parametrizarse"* habilitar esta opción y se nos mostrará un menú desplegable.
3. Del menú seleccionar *"Parametro de Canade"* asignar los siguiente valores.
    - Nombre del Parametro: NAME
    - Valor por default: Tom
4. en la sección *"build"* ingresar el siguiente script bash.
    ```bash
    echo "Hola, $NAME"
    ```
5. guardar, y ahora la opción para ejecutar el job a cambiado a "Ejecutar con parametros"
    Al ejecutar, ahora se nos muestra un formulario con la definición de los parametros configurado en el job.<br>
    Por default toma el valor que se le asignado cuando se definio el parametro o se puede reemplazar por una cadena que desemos pasar.

##### Tipo de Paramtros
1. Crear un nuevo proyeto en jenkins. (Tipo de proyecto "Estilo Libre")
2. Hacer click en el job en la opción *Configuración*.
3. Buscar la opción "This project is parameterized". Agregar los siguientes parametros.
    - NAME, tipo de parametro String
    - LASTNAME, tipo de parametro String
    - MOSTRAR, tipo de parametro Boolean

4. Crear el siguiente script bash, con el nombre "script_with_parameters.sh"
    ```bash
    #!/bin/bash

    NAME=$1
    LASTNAME=$2
    MOSTRAR=$3

    if [ "$MOSTRAR" = "true" ]; then
      echo "Hola, $NAME $LASTNAME"
    else
      echo "Para mostrar el nombre completo, debe seleccionar la variable MOSTRAR"
    fi
    ```
5. Copiar el script en la siguiente ruta del contenedor del servidor Jenkins. "/opt/script_with_parameters.sh", copiar con el siguiente comando. *"docker cp ./script_with_paramters.sh <NOMRE_CONTENEDOR>:/opt/"* INTRO
6. En las configuraciones del job de jenkins, en la pestaña *"Build"*, realizar la ejecución del script con el siguiente command Line.
    ```bash
    /opt/script_with_parameters.sh $NAME $LASTNAME $MOSTRAR
    ```
----------------------------------
# Crear Servidor SSH

<p>
En esta sección crearemos un servidor ssh para interactuar desde jenkins, añadirenos un conatiner con centos7 y le instalaremos el servio ssh. También modificaremos nuestro archivo docker-compose para levante los contenedores de jenkins con el ssh y pueden descubrirse entre si.

En esta parte, estará partida en dos secciones la primera parte construiremos una imagen donde disponibilisaremos  el server ssh, en la segunda parse la acoplaremos al ecosistema de jenkins mediente el docker compose.
</p>

### Build Image server SSH

Primero en nuestro workspace createmos una carpeta *centos7*.
```bash
mkdir centos7
```
Ingresamos a la carpeta *centos7*, ahora ejecutamos el  comando **ssh-keygen** para generar crear unas keys para usar con *ssh*
```bash
ssh-keygen -f remote-key
```
Con el comando anterior hemos generado un par de archivos que son las keys que usaremos para autenticarnos en el servidor ssh. la opcion f es para crear la key en formato file el argumento *remote-key* es el nombre del keys que se generaran.

Ahora  creamos un file con el nombre **Dockerfile**, ahora la abrimos para poder editar el contenid, agregar el siguiente contendo.
```dockerfile
FROM centos:7

ENV container docker

RUN yum install server-ssh -y

RUN adduser remote_user && \
    echo "1234" | passwd remote_user --stdin && \
    mkdir /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh

COPY remote-key.pub /home/remote_user/.ssh/authorized_keys

RUN chown remote_user:remote_user -R /home/remote_user && \
    chmod 600 /home/remote_user/.ssh/authorized_heys

RUN /usr/sbin/sshd-keygen -A > /dev/null 2>&1

CMD /usr/sbin/sshd -D
```

### Ajusttar Docker-Compose para el Server SSH

En nuestro workspace, acceder al archivo docker-compose.yml y realizar la siguiente modificación:

```dockerfile
  remote_host:
    container_name: remote-host
    image: remote-host
    build:
      context: centos7
    networks:
      - net
```
Quedando el archivo del siguiente modo:
```dockerfile
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
  remote_host:
    container_name: remote-host
    image: remote-host
    build:
      context: centos7
    networks:
      - net
networks:
  net:
```

Con la   definición del archivo docker-compose.yml estamos listo para poder construir la imagen del contexto centos7. Para realizar debemos correr el siguient comando:
```bash
docker-compose build
```

Una vez que tengamos la nueva imagen, estamos listos para poder levantar las instanciar del nuevo servidor ssh. para eso ejecutamos el siguiente comando *docker-compose up -d*, en la consola de salida veremos como se crea el nuevo contaier.

Ahora para para probar la conexión y la autenticación vamos copiar el key privado en el servidor jenkins para poder conectanos mediandte ssh al container server-ssh.
```bash
docker cp centos7/remote-key jenkins:/tmp
```
Con la key privada copiada dentro del server jenkins a la ruta temporal accedemos al conteneder de servidor de jenkins y haremos la conexión ssh.
```bash
docker exec -it jenkins bash
```
Ahora que estamos dentro del server jenkins, gracias al comando anterior, ejecutamos el comando ssh.
```bash
ssh -i /tmp/remote-key remote_user@remote-host
```
Una vez ejecutado eso nos abrira una conexión hacia el servidor ssh y nos estaremos autenticando mediante el key file generado en los pasos anteriores, (validar que se haya copiado correctamente el key file en la ruta temporal).