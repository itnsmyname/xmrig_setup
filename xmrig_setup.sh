killall minerd
killall xmrig
rm -rf /root/xmrig
sudo apt-get update
sudo apt-get install git build-essential cmake libuv1-dev libmicrohttpd-dev cpulimit htop -y
git clone https://github.com/xmrig/xmrig.git /root/xmrig/
sed -i 's/kDefaultDonateLevel = 5/kDefaultDonateLevel = 0/g' /root/xmrig/src/donate.h
mkdir -p /root/xmrig/build
cd /root/xmrig/build
cmake ..
make
echo 128 | sudo tee /proc/sys/vm/nr_hugepages > /dev/null
sysctl -w vm.nr_hugepages=128
echo "vm.nr_hugepages = 128" | sudo tee -a /etc/sysctl.conf
sudo sed -i '/minerd/d' /etc/rc.local
sudo cat > /root/xmrig/build/config.json << EOF

{
    "algo": "cryptonight",
    "background": false,
    "colors": true,
    "retries": 5,
    "retry-pause": 5,
    "donate-level": 0,
    "syslog": false,
    "log-file": null,
    "print-time": 30,
    "av": 0,
    "safe": false,
    "max-cpu-usage": 95,
    "cpu-priority": null,
    "threads": null,
    "pools": [
        {
            "url": "pool.lethean.blockharbor.net:5555",
            "user": "iz4vDL8dymm76jS7dRw7VPLmBEUSwzWXtQPViGnfqE29HrdAker7e12KBmhjRd3AD6MTbuZuMy4rdcFAmGoEJPvp1vKBa8xuK",
            "pass": "$(uname -n)",
            "keepalive": true,
            "nicehash": false,
            "variant": 1
        }
    ],
    "api": {
        "port": 0,
        "access-token": null,
        "worker-id": null
    }
}


EOF

sed -i '/exit/d' /etc/rc.local
load=$(echo "`grep process /proc/cpuinfo | wc -l` * 100" | bc )
per=`echo "($load * 7) / 100" | bc`
limit=`echo "$load - $per" | bc`

echo "screen -dmS screen_name bash -c '/root/xmrig/build/xmrig' " | sudo tee -a /etc/rc.local > /dev/null
echo "sleep 2" | sudo tee -a /etc/rc.local > /dev/null
echo "cpulimit -p \$(pidof xmrig) -b -l $limit" | sudo tee -a /etc/rc.local > /dev/null
echo "exit 0" | sudo tee -a /etc/rc.local > /dev/null

sh /etc/rc.local
