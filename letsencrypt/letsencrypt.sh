#! /bin/bash

~/.local/bin/letsencrypt --config-dir ./config --work-dir ./work --logs-dir ./logs \
    --renew-by-default --text \
    --agree-tos -a certbot-s3front:auth \
    --certbot-s3front:auth-s3-bucket blog.jvtrigueros.com \
    -i certbot-s3front:installer \
    --certbot-s3front:installer-cf-distribution-id $DISTRIBUTION_ID \
    -d blog.jvtrigueros.com

