# nginx-load-balancer 🚀

Pequeña demostración sobre la implementación de un **Load Balancer** con **Nginx**. 
Este ejemplo cuenta con dos servicios: uno en **Go** y otro en **Node.js**. Ambos se exponen mediante **Nginx**, el cual implementa el método **Round-Robin** para balancear la carga de las solicitudes entre diferentes servidores.

📌 Para más información, consulta la documentación oficial de [Load Balancing en Nginx](http://nginx.org/en/docs/http/load_balancing.html).

---

## 🛠 Requisitos

Antes de comenzar, asegúrate de tener instaladas las siguientes herramientas:

- ✅ [Docker](https://docs.docker.com/toolbox/toolbox_install_windows/) - Plataforma de contenedores
- ✅ [GNUWin](https://stackoverflow.com/a/46842187/8513536) - Herramientas GNU para Windows *(opcional)*

---

## 🚀 Ejecución del Proyecto

Para ejecutar el proyecto, dirígete a la carpeta de descarga y ejecuta el archivo **Makefile**:

```sh
$ cd <[proyect_path]>
$ make build
```

> ⚠️ Si prefieres no instalar **GNUWin**, puedes copiar los comandos manualmente desde la sección *#node servers* en el archivo [Makefile](https://github.com/theboshy/nginx-load-balancer/blob/master/Makefile).

Una vez finalizada la instalación, accede al servidor **Nginx** dentro de Docker en el puerto `8080` (`xxx.xxx.xxx.xxx:8080`). Luego, prueba las rutas `/go` y `/node`. Si actualizas varias veces, notarás que el mensaje mostrado cambia en cada petición, lo que indica que la carga se está distribuyendo correctamente.

Para conocer la **IP** del entorno Docker, ejecuta:

```sh
$ docker-machine ip <MACHINE_NAME>
```

Si usaste la configuración predeterminada de Docker, puedes verificar la IP con:

```sh
$ docker-machine ip default
```

Para listar todas las máquinas virtuales en ejecución, usa:

```sh
$ docker-machine ls
```

---

## 📂 Estructura del Proyecto

### 📌 `./dirapp`
Contiene los servicios y archivos Docker necesarios para el enrutamiento con **Nginx**.

#### 🌐 `goserv` - Servicio en Go
Este servicio utiliza **[Gin Gonic](https://github.com/gin-gonic/gin)** para exponer un servidor REST simple.

📄 [main.go](https://github.com/theboshy/nginx-load-balancer/blob/master/dirapp/goserv/main.go)

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

Prueba el servidor localmente con:
```sh
$ go run ./main.go
```
Luego, accede a `http://localhost:8080/go`.

#### 🌐 `nodeserv` - Servicio en Node.js

📄 [index.js](https://github.com/theboshy/nginx-load-balancer/blob/master/dirapp/nodeserv/index.js)

```javascript
const http = require('http');

http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end(`<h1>${process.env.MESSAGE}</h1>`);
}).listen(8080);
```

Prueba el servidor con:
```sh
$ node index.js
```

---

## 🖥 Configuración de Nginx

### 📌 `./nginx`
Esta carpeta almacena la configuración de **Nginx** como balanceador de carga.

📄 [Dockerfile](https://github.com/theboshy/nginx-load-balancer/blob/master/nginx/Dockerfile)

```dockerfile
FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
```

📄 [nginx.conf](https://github.com/theboshy/nginx-load-balancer/blob/master/nginx/nginx.conf)

```nginx
upstream app-node {
    server 172.17.0.1:8081 weight=1;
    server 172.17.0.1:8082 weight=1;
}

upstream app-go {
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

El parámetro **weight** define la cantidad de sesiones asignadas a cada servidor. Ejemplo:

```nginx
upstream app-node {
     server 172.17.0.1:8081 weight=100;
     server 172.17.0.1:8082 weight=10;
 }
```

En este caso, cuando el servidor `172.17.0.1:8081` alcance 100 sesiones, las siguientes solicitudes se dirigirán a `172.17.0.1:8082`.

---

## 📌 Actualización 6/6/18 🚀

✅ **TODO**: Añadir configuración de balanceadores de carga dinámicos usando `docker-gen`.

---
