### [Alpine](https://github.com/zhuwenbing/dockerfiles/blob/master/alpine/Dockerfile)
1. Based on Alpine's official image.
2. Add bash to run some special shell.
3. Add bind-tools for some special use, e.g. dig xxx.
4. Add ca-certificates for using HTTPS.
5. Add coreutils for full usage of the date command, e.g. 'date -d'.
6. Add curl instead of curl in busybox.
7. Add tzdate for setting the custom timezone.
8. Add wget instead of busybox wget.
