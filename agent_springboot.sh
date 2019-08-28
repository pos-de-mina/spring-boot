#!/bin/bash
#
# S E T U P
#     chmod +x /omd/agent_springboot.sh
#     ln -s /omd/agent_springboot.sh /omd/versions/default/share/check_mk/agents/special/agent_springboot
#
# P A R A M E T E R S
#     $1 | Hostanme
#
# (c) 2019-05-03 António Pós-de-Mina
#

echo "<<<check_mk>>>"
echo "Version: 1.0"
echo "AgentOS: Spring Boot"
echo "<<<local:sep(9)>>>"

# ------------------
# Spring Boot Performance

curl https://$1/actuator/prometheus --connect-timeout 5 --insecure --silent -o /tmp/spring-boot-$$-body.txt --write-out "HTTP_CODE=%{http_code}\nHTTP_TIME=%{time_total}\nHTTP_SIZE=%{size_download}\n" &> /tmp/spring-boot-$$-stderr.txt
#curl -s --insecure --connect-timeout 5 https://$1/actuator/prometheus | awk '/^[^#]/ { value=$NF; gsub($NF,"",$0); print "0\tSpring Boot "$0"\tvalue="value"\t-" }'

HTTP_ERROR=$?

if [ $HTTP_ERROR -eq 0 ]
then
	source /tmp/spring-boot-$$-stderr.txt

	awk '/^[^#]/ { value=$NF; gsub($NF,"",$0); print "0\tSpring Boot "$0"\tvalue="value"\t-" }' /tmp/spring-boot-$$-body.txt
fi


# ------------------
# Spring Boot Health

curl https://$1/actuator/health --connect-timeout 5 --insecure --silent -o /tmp/spring-boot-$$-body.txt --write-out "HTTP_CODE=%{http_code}\nHTTP_TIME=%{time_total}\nHTTP_SIZE=%{size_download}\n" &> /tmp/spring-boot-$$-stderr.txt

HTTP_ERROR=$?

if [ $HTTP_ERROR -ne 0 ]
then
	echo -e "2\tSpring Boot Health\t-\tHTTP timeout"
else
	source /tmp/spring-boot-$$-stderr.txt

	# evaluate status 
	declare -x STATUS=2
	if grep 'UP' --silent /tmp/spring-boot-$$-body.txt
	then
		STATUS=0
	fi
	
	echo -e "$STATUS\tSpring Boot Health\tHTTP_STATUS=$HTTP_CODE|HTTP_TIME=${HTTP_TIME}s|HTTP_SIZE=${HTTP_SIZE}B\tHTTP status $HTTP_CODE, HTTP response time $HTTP_TIME, HTTP size $HTTP_SIZE"
fi

rm -f /tmp/spring-boot-$$*
