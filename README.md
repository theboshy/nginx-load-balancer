# nginx-load-balancer
Demostracion pequeña sobre la implementacion de un **load balancer** con **nginx**, este ejemplo cuenta con 2 servicios uno echo en **go**, y otro en **nodejs** ambos se exponen mediante el servidor nginx para implementar el **metodo round-robin** para balancear las cargas(peticiones) a diferentes servers.

 >Este es un ejemplo minimo, para mas informacion [load_balancer](http://nginx.org/en/docs/http/load_balancing.html)

 ## Probar
 
 ### Requerimientos
 - *[Docker ](https://docs.docker.com/toolbox/toolbox_install_windows/)
 - [gnuwin](https://stackoverflow.com/a/46842187/8513536)




 Para ejecutar el proyecto solo es necesario dirigirse a la carpeta de descarga y ejecutar el archivo **[Makefile](https://github.com/theboshy/nginx-load-balancer/blob/master/Makefile)**

 ```bash
 $ cd <[proyect_path]>
 make build
 ```


 > Si prefiere no descargar **gnuwin**, puede simplemente copiar los comandos desde
#node servers en adelante en el archivo **[Makefile](https://github.com/theboshy/nginx-load-balancer/blob/master/Makefile)**



Una vez terminado puede probar la instalacion dirigiendose a su servidor **nginx** dentro de docker en el puerto **:8080** **xxx.xxx.xxx.xxx:8080** y probando cualquiera de las 2 rutas **/go**, **/node** y actualizando varias veces se dara cuenta de que el mensaje que muestra cada pagina es diferente de acuerdo a lo establecido en el **Makefile** *docker run -e **"MESSAGE=servidor 1"** -p 8081:8080 -d node_serv*



Para conocer la **ip** del entorno docker puede ejecutar


 ```bash
 docker-machine ip <MACHINE_NAME>
 ```
 
 

 Por lo general al isntalar docker e inciarlo se crea una maquina virtual con el nombre default
 ```bash
 docker-machine ip default
 ```
 
 
 Para conocer el nombre de todas las maquinas virtuales funcioanando ejecute
 ```bash
 docker-machine ls
 ```





 ## Estructura del proyecto



 ### ./dirapp
 Contiene los servicios y archivos docker para en el enrutamiento con nginx
 * [goserv] - contenedor del servicio en **go**
   - para exponer un pequeño servidor en go se hace uso de las librerias de **[gin gonic](https://github.com/gin-gonic/gin)** y contiene un *handler* que retorna una respuesta formada pór una variable obtenida del *envirotment*.




*[main.go](https://github.com/theboshy/nginx-load-balancer/blob/master/dirapp/goserv/main.go)*

```go
import (
	"log"
	"os"
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/go", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": os.Getenv("MESSAGE"),
		})
	})

	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Failed to run server: %v", err)
	}
}
```

> Puede probarlo una vez instalado [go_lang](https://golang.org/), ejecutar ```go run ./main.go``` y abrir ```localhost:8080/go``` para probarlo

En este caso exponemos el servicio **go** en el puerto **:8080**, y respondera  a la ruta ```<[host]>/go```
> Al declarar el puerto de expocion en el servicio **go** no significa que se este *exponiendo* tambien en el entorno [docker](https://docs.docker.com/engine/reference/run/)




* [nodeserv] - contenedor del servicio en **nodejs**
  - Ahora para ejecutar un servidor pequeño en nodejs implementamos el siguiente codigo
 
 
*[index.js](https://github.com/theboshy/nginx-load-balancer/blob/master/dirapp/nodeserv/index.js)*

```javascript
var http = require('http');
var fs = require('fs');

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end(`<h1>${process.env.MESSAGE}</h1>`);
}).listen(8080);

```

En este caso sucede lo mismo estamos creando un servidor con **nodejs** el cual respondera en la ruta sobre  la raiz principal */* , tambien tomara una *variable de entorno **(MESSAGE)***, la cual le daremos uso mas adelante.

> Para probar el servidor una vez instalado **[nodejs](https://nodejs.org/es/)**, ejecutar ```node index.js```



### ./nginx

En esta carpeta se encuentra alamacenada la configuracion de nginx para hacerlo funcionar como balanceador de cargas.
El archivo **[Dockerfile](https://docs.docker.com/engine/reference/builder/)** se encargara de descargar **nginx** en la version que queramos pero una vez se descargue debemos indicarle a la imagen docker que utilize nuestra configuracion.

*[Dockerfile](https://github.com/theboshy/nginx-load-balancer/blob/master/nginx/Dockerfile)*

```docker
FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
```

 Al ejecutar el comando
 
  ```docker
  RUN rm /etc/nginx/conf.d/default.conf
  ```
  
 Eliminaremos la configuracion por defecto de nginx.

 Al ejecutar

 ```docker
 COPY nginx.conf /etc/nginx/conf.d/default.conf
 ```

 copiaremos nuestro archivo de configuracion **nginx.conf**.

 La configuracion del servidor **nginx** esta compuesta de la siguiente manera

 *[nginx.conf](https://github.com/theboshy/nginx-load-balancer/blob/master/nginx/nginx.conf)*
 
```nginx
upstream app-node {
    #metodo : round-robin
    server 172.17.0.1:8081 weight=1;
    server 172.17.0.1:8082 weight=1;
}

upstream app-go {
    #metodo : round-robin
    server 172.17.0.1:8083 weight=1;
    server 172.17.0.1:8084 weight=1;
}

server {

    listen 80;
    location /node {
        proxy_pass http://app-node;
    }

    location /go {
        proxy_pass http://app-go;
    }
}
```

De esta forma le indicamos a nginx que redireccione las peticiones de ```<host>/node``` a 2 posibles servidores que se encuentran referenciados en el **proxy_pass** del **lcoation/node**

```nginx
location /node {
      proxy_pass http://app-node;
  }
  #.....
  upstream app-node {
    #metodo : round-robin
    server 172.17.0.1:8081 weight=1;
    server 172.17.0.1:8082 weight=1;
}
```

El parametro **weight** indica la cantidad maxima de sesiones en el servidor

  Ejemplo.
  Si se establece
  
```nginx
upstream app-node {
     server 172.17.0.1:8081 weight=100;
     server 172.17.0.1:8082 weight=10;
 }
```

Una vez alcanzada 100 sesiones en el servidor **172.17.0.1:8081**, las sigueintes se enrrutaran al siguiente en la lista **172.17.0.1:8082** el cual solo tiene un maximo de *10*.

De esta forma usando el metodo **round-robin** distrubuimos la carga del servidor a diferentes servidores y evitamos asi congestion o lentitud entre las peticiones con ayuda de **nginx**.

  > lo mismo para la configuracion de **location/go**

  De esta forma las peticiones echas al servidor nginx para la ruta **/node**, de acuerdo al metodo **round-robin** se dirigiran a **172.17.0.1:8081** o **172.17.0.1:8081**
  
  
  # UPDATE 6/6/18  📌 :shipit: 
  
  TODO : anadir configuracion de load balancer dinamicos usando traspilacion de codigo tipado (docker-gen)
