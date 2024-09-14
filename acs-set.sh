#!/bin/bash
domainSock_dir="/run/v2ray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
chown www-data.www-data $domainSock_dir

systemctl restart v2ray
