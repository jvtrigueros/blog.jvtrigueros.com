~/.local/bin/letsencrypt --config-dir ./config --work-dir ./work --logs-dir ./logs \
    --renew-by-default --text \
    --agree-tos -a letsencrypt-s3front:auth \
    --letsencrypt-s3front:auth-s3-bucket blog.jvtrigueros.com \
    -i letsencrypt-s3front:installer \
    --letsencrypt-s3front:installer-cf-distribution-id $DISTRIBUTION_ID \
    -d blog.jvtrigueros.com

