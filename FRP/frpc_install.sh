#/bin/bash
set -e

echo "Intalling FastReverseProxy Client"
read -p "Enter FRP Server ip:" FRPS_ip
read -p "Enter FRP Server port:" FRPS_port
read -p "Enter FRP Server token:" FRPS_token
read -p "Enter service name to proxy:" FRPC_service
read -p "Enter service port to proxy:" FRPC_port

echo "############################"
echo "FPR Server ip: "      $FRPS_ip
echo "FPR Server Port: "    $FRPS_port
echo "FPR Server Token: "   $FRPS_token
echo "FRP Client Service: " $FRPC_service
echo "FRP Client Port:"     $FRPC_port
read -p "Confirm configuration, press ENTER" confirm

cd /tmp
 echo "Downloading tar package from Github......"
 wget -q "https://github.com/fatedier/frp/releases/download/v0.51.3/frp_0.51.3_linux_amd64.tar.gz"
 echo "Download complete."
 echo "Unpacking......"
 tar -xzf frp_0.51.3_linux_amd64.tar.gz
 echo "Installing binary files......"
 cp ./frp_0.51.3_linux_amd64/frpc /usr/bin && chmod +x /usr/bin/frpc

echo "Installing configuration files......"
mkdir -p /etc/frp
cat > "/etc/frp/frpc.ini" << EOF
[common]
server_addr = $FRPS_ip
server_port = $FRPS_port
token = $FRPS_token

[$FRPC_service]
type = tcp
local_ip = 127.0.0.1
local_port = $FRPC_port
remote_port = $FRPC_port
EOF
echo "Configuration file is installed to /etc/frp ."

echo "Installing systemd service......"
cat > "/etc/systemd/system/frpc.service" << EOF
[Unit]
Description=frpc daemon
After=network.target
After=systemd-user-sessions.service
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/frpc -c /etc/frp/frpc.ini
Restart=on-failure
RestartSec=5
EOF
echo "Systemd service installed"

echo "Install complete."
echo "Use 'systemctl start frpc' or 'systemctl enable frpc' to start frpc service."
rm -rf /tmp/frp_0.51.3_linux_amd64*


# edit config
# sudo nano /etc/frp/frpc.ini