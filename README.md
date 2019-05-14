<h1>Refs</h1>
<li>https://docs.spring.io/spring-cloud-dataflow/docs/1.1.0.RELEASE/reference/html/configuration-monitoring-management.html</li>
<li>https://docs.spring.io/spring-boot/docs/current/actuator-api/html/</li>
<li>https://linux.die.net/man/1/curl</li>


<h1>New Host</h1>
Para criar um host que utilize o agente de Spring Boot é necessário selecionar as seguintes opções...

<h1>Host Tags</h1>
Foi criada a Tag para que possa ser utilizada no Host e nas regras


<h1>Rule</h1>
Criar uma regra para evocação do novo agente "Datasource Programs" -> "Individual program call instead of agent access"


<h1>Agent | agent_springboot.sh</h1>

	#!/bin/bash
	#
	# S E T U P
	#     chmod +x /omd/agent_springboot.sh
	#     ln /omd/agent_springboot.sh /omd/versions/default/share/check_mk/agents/special/agent_springboot
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
	
	curl -s --insecure --connect-timeout 5 https://$1/actuator/prometheus | awk '/^[^#]/ { value=$NF; gsub($NF,"",$0); print "0\tSpring Boot "$0"\tvalue="value"\t-" }'
	
	
	# ------------------
	# Spring Boot Health
	
	curl https://$1/actuator/health  --connect-timeout 5 --insecure --silent -o /tmp/spring-boot-$$-body.txt --write-out "HTTP_CODE=%{http_code}\nHTTP_TIME=%{time_total}\nHTTP_SIZE=%{size_download}\n" &> /tmp/spring-boot-$$-stderr.txt
	
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
		echo $STATUS
	
		echo -e "$STATUS\tSpring Boot Health\tHTTP_STATUS=$HTTP_CODE|HTTP_TIME=${HTTP_TIME}s|HTTP_SIZE=${HTTP_SIZE}B\tHTTP status $HTTP_CODE, HTTP response time $HTTP_TIME, HTTP size $HTTP_SIZE"
	fi
	
	rm -f /tmp/spring-boot-$$*
	

HTTP output
/actuator/health

Status = UP

	- HTTP Status
	- HTTP size
	- HTTP Response time
# spring-boot
Monitoring Spring Boot Framework as Check_MK Agent
