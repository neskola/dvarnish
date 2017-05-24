Varnish with Docker poc
===========

### Varnish environment variables
Varnish will use the following environment variables. You can override them if you want

	VARNISH_PORT 8010

### Build the image
To build the image run:

	$ docker build -t varnish-veikkaus:1.0 ssh://git@frontv03t.tst.veikkaus.fi:7999/vkbe/docker-varnish-poc.git

### Start couple backend containers
First pull Cats & Dogs voting app image

	$ docker pull docker/example-voting-app-vote

Start couple of container's to run in background

	$ docker run -itd --name voting-app -p 8080:80 docker/example-voting-app-vote

	$ docker run -itd --name voting-app-2 -p 8090:80 docker/example-voting-app-vote

### Start the Varnish container
To run the container you need to link the containers you want to run behind the load balancer that Varnish will create.
Varnish will detect all the node containers you pass and add them to the load balancer, we do this with the "parse" file. The only requirement is that when you link your containers you use the name "nodeN". Example: --link container_name:node1 --link container_name2:node2. This command will also map the port 8010 inside the Varnish container to the port 8010 in your host so you can access the node application at http://localhost:8010

	$ docker run -itd -p 8010:8010 --link voting-app:node1 --link voting-app-2:node2 varnish-poc 

#### Bash into the container
If you want to bash into the container you can, just do: 

	$ docker run -itd -p 8010:8010 --link voting-app:node1 --link voting-app-2:node2 varnish-poc bash 

