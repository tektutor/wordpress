# Start from a lightweight PHP + Apache base image
FROM php:8.2-apache-bookworm

# Metadata
LABEL maintainer="https://www.tektutor.org <jegan@tektutor.org>" \
      org.opencontainers.image.source="https://github.com/tektutor/rootless-wordpress"

# -------------------------------------------------------------
# 1. Create a non-root user and adjust permissions
# -------------------------------------------------------------
ENV APP_HOME=/opt/app-root/src
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev libjpeg-dev libfreetype6-dev libzip-dev unzip mariadb-client curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli zip opcache \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${APP_HOME} /tmp/html \
    && chown -R 1001:0 ${APP_HOME} /tmp/html /var/www/html \
    && chmod -R g+rwX ${APP_HOME} /tmp/html /var/www/html

# -------------------------------------------------------------
# 2. Set Apache to listen on an unprivileged port (8080)
# -------------------------------------------------------------
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf

# -------------------------------------------------------------
# 3. Copy WordPress source (downloaded fresh at build time)
# -------------------------------------------------------------
RUN curl -o /tmp/latest.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf /tmp/latest.tar.gz -C /tmp/html --strip-components=1 \
    && rm /tmp/latest.tar.gz \
    && chown -R 1001:0 /tmp/html

# -------------------------------------------------------------
# 4. Move files into Apache web root
# -------------------------------------------------------------
RUN rm -rf /var/www/html/* && cp -r /tmp/html/* /var/www/html/ \
    && chown -R 1001:0 /var/www/html && chmod -R g+rwX /var/www/html

# -------------------------------------------------------------
# 5. Configure environment variables for WordPress
# -------------------------------------------------------------
ENV APACHE_RUN_USER=1001 \
    APACHE_RUN_GROUP=0 \
    WORDPRESS_DB_HOST="mysql" \
    WORDPRESS_DB_USER="wordpress" \
    WORDPRESS_DB_PASSWORD="wordpress" \
    WORDPRESS_DB_NAME="wordpress"

# -------------------------------------------------------------
# 6. Switch to non-root user
# -------------------------------------------------------------
USER 1001

# -------------------------------------------------------------
# 7. Expose and start Apache
# -------------------------------------------------------------
EXPOSE 8080
WORKDIR /var/www/html

CMD ["apache2-foreground"]
