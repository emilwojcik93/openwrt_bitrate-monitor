# openwrt_bitrate-monitor
This script is used to monitor bitrate of choosen iface (useful for WDS connections)

## Install using `git`: 
Clone it in current directory and then proceed installation:
```
# git clone git://github.com/emilwojcik93/openwrt_bitrate-monitor.git
# cd openwrt_bitrate-monitor
# chmod 755 "./bitrate_check.sh" && ./bitrate_check.sh wlan1 auto
```

## Install using `curl` or `wget`: 

#### NOTE: curl / wget may fail because of missing SSL certificates.
You may choose to ignore the certificates check using:
 - `curl -k`
 - `wget --no-check-certificate` 

Or you will need to fix your `/etc/ssl/certs/ca-certificates.crt` installation. 
Please note that SSL support takes quite a lot of storage space. 

This should be enough to make SSL work: 
```
opkg install ca-certificates openssl-util
```
And this may be a workaround if you still have problems:
```
mkdir -p -m0755 /etc/ssl/certs && curl -k -o /etc/ssl/certs/ca-certificates.crt -L http://curl.haxx.se/ca/cacert.pem
```
Relevant links:
 - [OpenWRT Wiki](https://wiki.openwrt.org/doc/howto/wget-ssl-certs){:target="_blank" rel="noopener"}
 - [OpenWRT Forum](https://forum.openwrt.org/viewtopic.php?pid=284368#p284368){:target="_blank" rel="noopener"}
 - [OpenWRT Development](https://dev.openwrt.org/ticket/19621){:target="_blank" rel="noopener"}

### Oneliners to run from internet ( downloads to `/tmp` ) :
```bash
# using wget with SSL
wget 'https://raw.githubusercontent.com/emilwojcik93/openwrt_bitrate-monitor/main/bitrate_check.sh' -O "/tmp/bitrate_check.sh" && chmod 755 "/tmp/bitrate_check.sh" && /tmp/bitrate_check.sh wlan1 auto

# using wget WITHOUT SSL
wget --no-check-certificate 'https://raw.githubusercontent.com/emilwojcik93/openwrt_bitrate-monitor/main/bitrate_check.sh' -O "/tmp/bitrate_check.sh" && chmod 755 "/tmp/bitrate_check.sh" && /tmp/bitrate_check.sh wlan1 auto

# using curl with SSL
curl -L 'https://raw.githubusercontent.com/emilwojcik93/openwrt_bitrate-monitor/main/bitrate_check.sh' -o "/tmp/bitrate_check.sh" && chmod 755 "/tmp/bitrate_check.sh" && /tmp/bitrate_check.sh wlan1 auto

# using curl WITHOUT SSL
curl -k -L 'https://raw.githubusercontent.com/emilwojcik93/openwrt_bitrate-monitor/main/bitrate_check.sh' -o "/tmp/bitrate_check.sh" && chmod 755 "/tmp/bitrate_check.sh" && /tmp/bitrate_check.sh wlan1 auto
```
