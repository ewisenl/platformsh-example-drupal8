# docker build --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG}
ARG BASE_IMAGE_TAG

FROM wodby/drupal-php:${BASE_IMAGE_TAG}
WORKDIR /var/www/html

USER root
RUN composer self-update 1.10.1
RUN curl --silent --output '/cloud_sql_proxy' 'https://storage.googleapis.com/ewise-public-files/gke/cloud_sql_proxy' \
    && chmod ugo+x '/cloud_sql_proxy'
COPY --chown=wodby:wodby gke/cron.sh gke/buildscript.sh /var/www/html/gke/
RUN crontab -l | { cat; echo "*/15       *       *       *       *       /var/www/html/gke/cron.sh"; } | crontab -

USER wodby
COPY scripts/composer /var/www/html/scripts/composer/
COPY patches /var/www/html/patches/
COPY composer.* /var/www/html/
RUN gke/buildscript.sh
COPY . /var/www/html/