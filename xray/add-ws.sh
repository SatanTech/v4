#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################



clear
source /var/lib/SIJA/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi

tls="$(cat ~/log-install.txt | grep -w "Vmess TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vmess None TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/v2ray/vmess-ntls.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vm-ntls$/a\#vm-ntls '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/v2ray/vmess-ntls.json
sed -i '/#vm-tls$/a\#vm-tls '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/v2ray/vmess-tls.json

cat > /etc/v2ray/$user-tls.json <<-EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "8443",
      "id": "${uuid}",
      "aid": "2",
      "net": "ws",
      "path": "/v2ray",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF

cat > /etc/v2ray/$user-none.json <<-EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "880",
      "id": "${uuid}",
      "aid": "2",
      "net": "ws",
      "path": "/v2ray",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF

vmesslink1="vmess://$(base64 -w 0 /etc/v2ray/$user-tls.json)"
vmesslink2="vmess://$(base64 -w 0 /etc/v2ray/$user-none.json)"
systemctl restart v2ray
systemctl restart v2ray@none
clear
echo -e ""
echo -e "==========-V2RAY/VMESS-=========="
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Server IP      : $PUBLIC_IP"
echo -e "port TLS       : 8443"
echo -e "port none TLS  : 880"
echo -e "id             : ${uuid}"
echo -e "alterId        : 2"
echo -e "Security       : auto"
echo -e "network        : ws"
echo -e "path           : /v2ray"
echo -e "================================="
echo -e "link TLS       : ${vmesslink1}"
echo -e "================================="
echo -e "link none TLS  : ${vmesslink2}"
echo -e "================================="
echo -e "Expired On     : $exp"
echo -e "--------Mod By OnePiece----------"
