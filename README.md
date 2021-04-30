# Dockerfiles for building custom docker images
### [Alpine](https://github.com/zhuwenbing/dockerfiles/blob/master/alpine/Dockerfile)
1. Add bash to run some special shell.
1. Add ca-certificates for using HTTPS.
1. Add curl instead of curl in busybox.
1. Add tzdate for setting the custom timezone.
1. Add wget instead of busybox wget.

### [Mongo](https://github.com/zhuwenbing/dockerfiles/blob/master/mongo/Dockerfile)
1. Reference to [mkscs/docker-alpine-mongodb](https://github.com/mkscs/docker-alpine-mongodb).
1. Reference to [mvertes/docker-alpine-mongo](https://github.com/mvertes/docker-alpine-mongo).
1. Version 4.0 and below are based on Alpine.
1. Version 4.2 and above are based on AmazonLinux2.

### [Nginx](https://github.com/zhuwenbing/dockerfiles/blob/master/nginx/Dockerfile)
1. Reference to [hermanbanken/Dockerfile](https://gist.github.com/hermanbanken/96f0ff298c162a522ddbba44cad31081).
1. Based on Nginx's official image which one was based on Alpine.
1. Add brotli, dav-ext, fancyindex and headers-more modules.

### [PHP](https://github.com/zhuwenbing/dockerfiles/blob/master/php/Dockerfile)
1. Based on the PHP's official image of "fpm-alpine".
1. Add PHP extends of "gd", "zip", and "MySQL".
