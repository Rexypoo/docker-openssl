# docker-openssl

A Docker build context create a clean Docker image with [OpenSSL]. The resulting files can be copied into another image to [update OpenSSL](#updating-openssl-in-docker-images) or the image can be [run from the command line](#running-openssl-from-the-command-line).

# Prerequisites

[Docker] 17.05+

# Usage

## Retrieving the Image

For basic usage fetch the image using the stable release of OpenSSL (1.1.1).
```shell
docker pull rexypoo/openssl:stable
```

## Running OpenSSL from the Command Line

You can run the basic command line interface for OpenSSL by running the image interactively:
```shell
docker run -it --rm rexypoo/openssl
```
You can also provide command line arguments to OpenSSL:
```shell
docker run -it --rm rexypoo/openssl genpkey -algorithm ed25519
```

See the Dockerfile labels related to `org.label-schema.docker.cmd` for more information.

## Updating OpenSSL in Docker Images

The OpenSSL binary compiled by this Dockerfile is statically linked such that you should be able to overwrite the existing binary as a layer of your Dockerfile build e.g.:
```docker
COPY --from=rexypoo/openssl:1.1.1a-distroless /usr/local/bin/openssl </path/to/openssl>
```

Some features of OpenSSL cannot be statically linked and may not work with the above. In that case you'll need to copy the entire contents of `/usr/local` e.g.:
```docker
COPY --from=rexypoo/openssl:1.1.1a /usr/local /usr/local
```
You may need to adjust the `$PATH` environment variable in your image to prioritize the copy of OpenSSL at `/usr/local/bin`.

# License

This project is subject to the MIT license included in this repository.

The OpenSSL project is covered by one of two [licenses][OpenSSL Licenses]:
1. For releases below 3.0.0 the [dual OpenSSL and SSLeay license] applies.
2. For OpenSSL versions 3.0.0 and above the [Apache License v2] applies.

# Legal

Please be advised that cryptographic software may be illegal to export/import or use in some jurisdictions. The maintainer of this repository is not liable for any violations. Per the [OpenSSL download webpage]:
> Please remember that export/import and/or use of strong cryptography software, providing cryptography hooks, or even just communicating technical details about cryptography software is illegal in some parts of the world. So when you import this package to your country, re-distribute it from there or even just email technical suggestions or even source patches to the authors or other people you are strongly advised to pay close attention to any laws or regulations which apply to you. The authors of OpenSSL are not liable for any violations you make here. So be careful, it is your responsibility.

[Docker]: https://www.docker.com
[OpenSSL]: https://www.openssl.org
[OpenSSL Signatures]: https://www.openssl.org/community/omc.html
[OpenSSL Licenses]: https://www.openssl.org/source/license.html
[dual OpenSSL and SSLeay license]: https://www.openssl.org/source/license-openssl-ssleay.txt
[Apache License v2]: https://www.openssl.org/source/apache-license-2.0.txt
[OpenSSL download webpage]: https://www.openssl.org/source/
