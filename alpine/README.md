### [Alpine](https://github.com/zhuwenbing/dockerfiles/blob/master/alpine/Dockerfile)
1. Based on Alpine's official image.
1. Add bash to run some special shell.
1. Add ca-certificates for using HTTPS.
1. Add coreutils for full usage of the date command, e.g. 'date -d'.
1. Add curl instead of curl in busybox.
1. Add tzdate for setting the custom timezone.
1. Add wget instead of busybox wget.
