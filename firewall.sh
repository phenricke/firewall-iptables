#!/bin/bash
# Projeto Firewall com iptables
# Autor: Pedro
# Objetivo: Permitir apenas HTTP/HTTPS, restringir SSH externo e logar tentativas bloqueadas

echo "Aplicando regras de firewall..."

# Limpar regras existentes
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Definir políticas padrão
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir tráfego local (loopback)
iptables -A INPUT -i lo -j ACCEPT

# Permitir conexões já estabelecidas
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir HTTP e HTTPS
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# SSH: permitir apenas da rede interna (exemplo 192.168.100.0/24)
iptables -A INPUT -p tcp --dport 22 -s 192.168.100.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

# Logar tentativas bloqueadas
iptables -A INPUT -j LOG --log-prefix "IPTABLES-DROP: "

echo "Regras aplicadas com sucesso!"