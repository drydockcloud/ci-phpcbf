# Duplicated from https://github.com/cytopia/docker-phpcbf
# but using PHPCSStandards/PHP_CodeSniffer instead of
# abandoned squizlabs/PHP_CodeSniffer.

ARG PHP_IMG_TAG=cli-alpine
FROM php:${PHP_IMG_TAG} AS builder

# Install build dependencies
RUN set -eux \
	&& apk add --no-cache \
		ca-certificates \
		# coreutils add 'sort -V'
		coreutils \
		curl \
		git \
	&& git clone https://github.com/PHPCSStandards/PHP_CodeSniffer

ARG PCS_VERSION=latest
RUN set -eux \
	&& cd PHP_CodeSniffer \
	&& if [ "${PCS_VERSION}" = "latest" ]; then \
		VERSION="$( git describe --abbrev=0 --tags )"; \
	else \
		VERSION="$( git tag | grep -E "^v?${PCS_VERSION}\.[.0-9]+\$" | sort -V | tail -1 )"; \
	fi \
	&& echo "Version: ${VERSION}" \
	&& curl -sS -L https://github.com/PHPCSStandards/PHP_CodeSniffer/releases/download/${VERSION}/phpcbf.phar -o /phpcbf.phar \
	&& chmod +x /phpcbf.phar \
	&& mv /phpcbf.phar /usr/bin/phpcbf \
	\
	&& phpcbf --version


ARG PHP_IMG_TAG=cli-alpine
FROM php:${PHP_IMG_TAG} AS production

COPY --from=builder /usr/bin/phpcbf /usr/bin/phpcbf
ENV WORKDIR /data
WORKDIR /data

ENTRYPOINT ["phpcbf"]
CMD ["--version"]
