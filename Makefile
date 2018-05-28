build:
	#clean
	docker rmi -f node_serv
	docker rmi -f go_serv
	docker rmi -f load-balance-nginx
	#node_servers
	docker build -t node_serv ./dirapp/nodeserv
	docker run -e "MESSAGE=servidor 1" -p 8081:8080 -d node_serv
	docker run -e "MESSAGE=servidor 2" -p 8082:8080 -d node_serv
	#go_servers
	docker build -t go_serv ./dirapp/goserv
	docker run -e "MESSAGE=servidor 1" -p 8083:8080 -d go_serv
	docker run -e "MESSAGE=servidor 2" -p 8084:8080 -d go_serv
 	#nginx server/load-balancer
	docker build -t load-balance-nginx ./nginx/
	docker run -p 8080:80 -d load-balance-nginx

	#$(info [verifique la aplicacion en la docker machine por defecto  = $(shell docker-machine ip default)])
	#$(info verificar el host de los contenedores creados $docker-machine -ls )
	#$(info verificar la url de una docker machine $docker-machine ip <docker_machine_name> )
	#start http://$(shell docker-machine ip default):8080
	python -m webbrowser "http://$(shell docker-machine ip default):8080/go"
