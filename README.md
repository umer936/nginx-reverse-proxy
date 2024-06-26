# ARCHIVED


# JUST USE https://cosmos-cloud.io/ INSTEAD. 

1. Don't include ports in the containers
2. ServApps > New URL > Use Host > **can do [url]:[port #]!!**


----------
# Historical

## 1) 
Add to docker-compose of the services you want reverse-proxied:

```
# on each container to expose
    networks:
      - reverseproxy


# at the bottom
networks:
  reverseproxy:
    external: true


# may need an additional network if multiple services
# do not include a "ports:" section, but note down the internal port for the service
```

## 2) 
`./make_new_proxy.sh`

prompts for service/container name, external/url port, and internal/docker container port

- makes a new sites-available/sites-enabled entry for the service
- makes a redirect so sodasdev.space.swri.edu/[service name] redirects to the port
  - TODO: keep the parameters after / so that API into the service can be done by name rather than port number 

## 3) 
Add the port to `docker-compose.yml`, should be `$external_port:$external_port`
- TODO: use a file (e.g. `ports.txt`) or variable so that it can be changed more dynamically. Include the container name as a comment
  - Harder to do without this closed issue: https://github.com/docker/compose/issues/10556

## 4) 
`docker-compose restart`

***


### TODO:
- Make a GUI
- Make a default (e.g. dashy)
- Combine the common bits

- Maybe instead of `make_new_proxy.sh`, on `docker-compose up`, it runs a script that takes in a file like:
`[external port] [internal port] [container name]` and generates the files then. Then would modify the ports flag in the `docker-compose.yml`
  - Downside: if need a custom config

- Make it easier to do step 1
- Make it check whether the port chosen is valid and not in use

- Return an error somewhere notifying if a config is wrong.
- Return logs to a logs folder - both for errors and for checking for hackers/unauthorized users


- Make the ports allocated the way cosmos-server does (not sure atm) so that configs can just be enabled/disabled and based on if a container is running
  - I believe cosmos hooks into docker.sock instead of having a defined set of ports allocated
  - Allows for changes without restarting nginx

- https://www.reddit.com/r/selfhosted/comments/znm7vt/cant_forward_ports_in_nginx_proxy_manager/
  - have each only mapped to reverseproxy and have nginx-reverse-proxy the only one on a bridge network



## Umer Notes section:
### How I got here: 

- Tried Traefik, nginx-proxy-manager, nginx-proxy, SWAG, cosmos-server, etc

- All assumed I could allocate [container name].sodasdev.space.swri.edu, but I wanted something like sodasdev.space.swri.edu/[container name] (as my cert is for *.space.swri.edu AND I don't control the DNS)

- This proved to be awful as most services assumed they were at a baseURL, not /[container name]
- Considered adding this to /etc/hosts, but didn't want to do on every system 
- Tried patching the request with /[container name]
- Tried including all kinds of headers

- Switched to cosmos-server, which I noticed basically "ate" all the ports and then decided from there

- Then found this most helpful article https://www.bogotobogo.com/DevOps/Docker/Docker-Compose-Nginx-Reverse-Proxy-Multiple-Containers.php

- Then was implementing


### Other notes: 
#### restart just nginx:
`docker exec -it nginx-reverse-proxy-reverseproxy-1 nginx -s reload`

#### inspect network to see what containers are connected:
`docker network inspect reverseproxy`



### Issues this solves:
- https://stackoverflow.com/questions/44656188/implementing-reverse-proxy-with-nginx-and-docker-containers-with-different-ports
- https://www.reddit.com/r/docker/comments/xxhxzr/comment/ircl2m5/
- https://www.reddit.com/r/nginxproxymanager/comments/10mt5qc/config_help_custom_locations/
