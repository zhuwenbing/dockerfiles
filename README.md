# Dockerfiles for building custom docker images
### [Alpine](https://github.com/zhuwenbing/dockerfiles/blob/master/Dockerfile.alpine)
1. Add bash to run some special shell.
1. Add ca-certificates for using HTTPS.
1. Add curl instead of curl in busybox.
1. Add tzdate for setting the custom timezone.
1. Add wget instead of busybox wget.

### [Mongo](https://github.com/zhuwenbing/dockerfiles/blob/master/Dockerfile.mongo)
1. Reference to [mkscs/docker-alpine-mongodb](https://github.com/mkscs/docker-alpine-mongodb).
1. Reference to [mvertes/docker-alpine-mongo](https://github.com/mvertes/docker-alpine-mongo).

### [Nginx](https://github.com/zhuwenbing/dockerfiles/blob/master/Dockerfile.nginx)
1. Reference to [hermanbanken/Dockerfile](https://gist.github.com/hermanbanken/96f0ff298c162a522ddbba44cad31081).
1. Add brotli, dav-ext, fancyindex and headers-more modules.

### [PHP-FPM](https://github.com/zhuwenbing/dockerfiles/blob/master/Dockerfile.php-fpm)
1. Base on the image 'php:5-fpm-alpine'.
1. Add php exts of 'gd', 'zip' and 'mysql'.
