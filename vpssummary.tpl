%{ for index, addr in server_ip ~}
${server_fqdn[index]} ${server_ip[index]} ${rootpass[index]}
%{ endfor ~}
