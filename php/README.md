### [PHP](https://github.com/zhuwenbing/dockerfiles/blob/master/php/Dockerfile)
1. Based on the PHP's official image of "fpm-alpine".
1. Add PHP extends of "gd", "zip", and "MySQL".
1. Add healthcheck.
##### Example of php-fpm healthcheck configuration in docker compose
```script
healthcheck:
  # [Ping mode](https://github.com/renatomefi/php-fpm-healthcheck#ping-mode)
  test: [ "CMD", "php-fpm-healthcheck", "&&", "exit", "$$?", "||", "exit", "1" ]
  interval: 1m30s
  timeout: 3s
```
##### More usages see [php-fpm-healthcheck](https://github.com/renatomefi/php-fpm-healthcheck).
