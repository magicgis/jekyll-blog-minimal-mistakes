@echo off

set SSL_CERT_FILE=C:\Ruby200\bin\cacert.pem

::setup
::bundle exec jekyll serve --incremental

::writing post
::rake post title=""

bundle exec jekyll serve --watch --config _config.dev.yml --incremental -H 0.0.0.0 -P 5000
