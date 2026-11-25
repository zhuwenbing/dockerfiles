### [Mongo](https://github.com/zhuwenbing/dockerfiles/blob/master/mongo)
1. Reference to [mkscs/docker-alpine-mongodb](https://github.com/mkscs/docker-alpine-mongodb).
2. Reference to [mvertes/docker-alpine-mongo](https://github.com/mvertes/docker-alpine-mongo).
3. Reference to [docker-library/healthcheck/mongo](https://github.com/docker-library/healthcheck/tree/master/mongo).
4. MongoDB no longer provides `-latest` archives (and 9.0+ ships no Amazon Linux 2 packages), so:
   - Images based on Amazon Linux 2023 support `9.0`, `8.0` and `7.0` (`9.0` is tagged `amzn2023` and `latest`).
   - Images based on Amazon Linux 2 support `8.0`, `7.0`, `6.0`, `5.0`, `4.4`, `4.2`, `4.0` and `3.6` (`8.0` is tagged `amzn2`).
5. The exact patch release is resolved from <https://downloads.mongodb.org/current.json> at build time; end-of-life series are pinned to their last release. Pass `MONGO_VERSION` (e.g. `9.0.8`) to pin an exact version.
