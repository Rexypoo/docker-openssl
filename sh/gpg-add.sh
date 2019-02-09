#!/usr/bin/env sh

key_id="$1"

gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys $key_id || \
gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys $key_id || \
gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys $key_id || \
gpg --keyserver hkp://keys.gnupg.net --recv-keys $key_id
