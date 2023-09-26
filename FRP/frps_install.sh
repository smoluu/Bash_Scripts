#/bin/bash
set -e

echo "Intalling FastReverseProxy Server"
read -p "Enter FRP Server port:" FRPS_port
read -p "Enter FRP Server token:" FRPS_token

echo "############################"
echo "FPR Server ip: "      $FRPS_ip
echo "FPR Server Port: "    $FRPS_port
echo "FPR Server Token: "   $FRPS_token
read -p "Confirm configuration, press ENTER" confirm

cd /tmp
 echo "Downloading tar package from Github......"
 wget -q "https://github.com/fatedier/frp/releases/download/v0.51.3/frp_0.51.3_linux_amd64.tar.gz"
 echo "Download complete."
 echo "Unpacking......"
 tar -xzf frp_0.51.3_linux_amd64.tar.gz
 echo "Installing binary files......"
 cp ./frp_0.51.3_linux_amd64/frps /usr/bin && chmod +x /usr/bin/frps

echo "Installing configuration files......"
mkdir -p /etc/frp
cat > "/etc/frp/frps.ini" << EOF
[common]
bind_port = $FRPS_port
authentication_method = token
token = $FRPS_token
EOF
echo "Configuration file is installed to /etc/frp ."

echo "Installing systemd service......"
cat > "/etc/systemd/system/frps.service" << EOF
[Unit]
Description=frps daemon
After=network.target
After=systemd-user-sessions.service
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/frps -c /etc/frp/frps.ini
Restart=always
RestartSec=5
EOF
echo "Systemd service installed"

echo "Install complete."
echo "Use 'systemctl start frps' or 'systemctl enable frps' to start frps service."
rm -rf /tmp/frp_0.51.3_linux_amd64*


# edit config
# sudo nano /etc/frp/frpc.ini