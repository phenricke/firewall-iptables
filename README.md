# Firewall com iptables

## Visão Geral

Este projeto demonstra a implementação de um firewall utilizando iptables em uma máquina virtual Ubuntu Server.  
O objetivo é restringir o tráfego de entrada, permitindo apenas HTTP e HTTPS, limitar acesso SSH e registrar tentativas bloqueadas.

O ambiente foi construído em laboratório utilizando virtualização para fins de estudo em redes e segurança.

---

## Ambiente

- Hypervisor: VirtualBox ou VMware Workstation Player  
- Sistema operacional da VM: Ubuntu Server 22.04 LTS  
- Host: Windows 11  

### Configuração da VM

- Nome: firewall-lab  
- Memória: 2 GB  
- Disco: 20 GB  
- Rede: Bridge Adapter  

---

## Instalação

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install iptables iptables-persistent openssh-server apache2 -y
```

Componentes instalados:

- iptables: controle de firewall  
- iptables-persistent: persistência das regras  
- openssh-server: acesso remoto para testes  
- apache2: serviço HTTP para validação  

---

## Configuração do Firewall

Criar o script:

```bash
nano firewall.sh
```

Conteúdo:

```bash
#!/bin/bash

echo "Aplicando regras de firewall..."

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -s 192.168.100.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

iptables -A INPUT -j LOG --log-prefix "IPTABLES-DROP: "

echo "Regras aplicadas com sucesso!"
```

Aplicar e persistir:

```bash
chmod +x firewall.sh
sudo ./firewall.sh
sudo netfilter-persistent save
sudo netfilter-persistent reload
```

---

## Validação

### HTTP

```bash
curl http://192.168.100.12
```

Resultado esperado: resposta HTTP do Apache.

---

### HTTPS

```bash
curl -I https://192.168.100.12
```

Resultado esperado: retorno de cabeçalhos HTTPS (se configurado).

---

### SSH externo

```bash
curl http://192.168.100.12:22
```

Resultado esperado: timeout ou falha de conexão.

---

### SSH local

```bash
ssh localhost
```

Resultado esperado: conexão estabelecida.

---

### Varredura de portas

```bash
nmap -Pn 192.168.100.12
```

Resultado esperado: porta 80 aberta e porta 22 filtrada.

---

### Logs

```bash
sudo tail -f /var/log/syslog | grep IPTABLES
```

Resultado esperado: registros de pacotes bloqueados.

---

## Resultados

- Porta 80 (HTTP): acessível  
- Porta 443 (HTTPS): acessível (quando configurado)  
- Porta 22 (SSH): restrita à rede interna  
- Logs de bloqueio ativos  

---

## Topologia

```
+------------------+           +------------------+
| Host             |           | VM Ubuntu        |
| 192.168.100.5    | <-------> | 192.168.100.12   |
| curl / nmap      |           | iptables         |
+------------------+           +------------------+
```

---

## Estrutura do Repositório

```
firewall-iptables/
├── firewall.sh
├── README.md
└── resultados/
```

---

## Considerações

A configuração utiliza política padrão restritiva (deny by default), liberando apenas serviços necessários.  
O uso de logs permite rastreabilidade de tentativas de acesso indevido.  
O cenário pode ser expandido com regras adicionais, integração com fail2ban ou migração para nftables.
