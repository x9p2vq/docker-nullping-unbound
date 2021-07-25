Additional local unbound conf files can be plaed here and volume mapped into the container by editing the [docker-compose.yaml](https://github.com/x9p2vq/docker-nullping-unbound/docker-compose.yaml).
 
The **/runtime/unbound/conf.d/** directory is read at startup.  You can quickly test conf files by placing them in this runtime directory and performing **docker restart unbound**.  The unbound configuration is checked at startup and reported in the container logs.
