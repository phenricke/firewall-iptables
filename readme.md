# Projeto Firewall com iptables

## Introdução
Este projeto tem como objetivo implementar e validar um **firewall com iptables** em uma máquina virtual (VM) Ubuntu Server.  
A ideia é permitir apenas tráfego HTTP/HTTPS, restringir conexões SSH externas e registrar tentativas bloqueadas em log.  

O projeto foi desenvolvido em ambiente de laboratório utilizando **VirtualBox** e documentado passo a passo para fins de estudo e prática em **CCST Networking**.

---

## Criação da VM

### Requisitos
- VirtualBox ou VMware Workstation Player
- ISO do Ubuntu Server 22.04 LTS
- Host: Windows 11

### Configuração da VM
- Nome: `firewall-lab`
- Memória: 2 GB
- Disco: 20 GB
- Rede: **Bridge Adapter** (para estar na mesma rede que o host)
- Sistema Operacional: Ubuntu Server 22.04 LTS

### Instalação
Dentro da VM Ubuntu:
sudo apt update && sudo apt upgrade -y
sudo apt install iptables iptables-persistent openssh-server apache2 -y

- iptables → firewall
- iptables-persistent → salvar regras após reboot
- openssh-server → serviço SSH para testes
- apache2 → servidor web para validar portas abertas

### Configuração do Firewall
Crie o arquivo firewall.sh dentro da VM:
nano firewall.sh

Conteúdo:

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

Salvar e executar:

chmod +x firewall.sh
sudo ./firewall.sh
sudo netfilter-persistent save
sudo netfilter-persistent reload

### Testes
1. HTTP (porta 80)
No host (Windows):
curl http://192.168.100.12 # IP da VM

Resultado: resposta HTML da página padrão do Apache.

2. HTTPS (porta 443)
curl -I https://192.168.100.12 # IP da VM

Resultado: cabeçalhos HTTPS (se configurado).

3. SSH bloqueado (externo)
curl http://192.168.100.12:22 # IP da VM

Resultado: erro de conexão (timeout), indicando bloqueio externo.

4. SSH interno (permitido)
ssh localhost

Resultado: conexão bem-sucedida, confirmando que o serviço está ativo e o firewall permite acesso local.

5. Escaneamento com nmap
No host:
nmap -Pn 192.168.100.11

Resultado: porta 80 aberta, porta 22 filtrada/fechada.

6. Logs de bloqueio
sudo tail -f /var/log/syslog | grep IPTABLES

Resultado: registros de tentativas bloqueadas.

## Resultados
- Porta 80 (HTTP) → aberta e acessível
- Porta 443 (HTTPS) → aberta (se configurado)
- Porta 22 (SSH) → bloqueada externamente, acessível internamente
- Tentativas bloqueadas registradas em log

## Topologia
+------------------+           +------------------+
|   Host Windows   |  <---->   |   VM Ubuntu      |
| 192.168.100.5    |           | 192.168.100.12   |
| curl / nmap      |           | iptables + Apache|
+------------------+           +------------------+

## Estrutura do Repositório
firewall-iptables/
├── firewall.sh        # Script com regras iptables
├── README.md          # Documentação completa
└── resultados/        # Capturas de tela dos testes (opcional)

## Conclusão
Este projeto demonstrou a criação de um firewall com iptables em ambiente de laboratório.
Foi possível validar:
- Configuração de regras de acesso
- Bloqueio seletivo de serviços
- Registro de tentativas em log
- Integração com serviços reais (Apache e SSH)

O repositório serve como guia prático para quem deseja aprender iptables e segurança de rede em ambiente controlado.