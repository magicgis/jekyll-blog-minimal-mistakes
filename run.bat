@echo off

set SSL_CERT_FILE=C:\Ruby200\bin\cacert.pem
::jekyll serve -w --incremental
::bundle exec jekyll serve --incremental
bundle exec jekyll serve --config _config.dev.yml --incremental