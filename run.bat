@echo off

set SSL_CERT_FILE=C:\Ruby200\bin\cacert.pem
::bundle exec jekyll serve --incremental
bundle exec jekyll serve --config _config.dev.yml --incremental -H 0.0.0.0 -P 5000
