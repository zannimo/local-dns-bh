# Launch Docker Desktop on macOS
```
open -a Docker 
```
# Create your cutomized Docker bridge network 
```
docker network create my-dns-lan 
```
```
docker network inspect my-dns-lan
```
```
[
    {
        "Name": "my-dns-lan",
        "Id": "df70166c8ca35a8bee9679591ea00ae149bb3cca81aacd3a23cb86bb4266e362",
        "Created": "2025-11-07T17:13:43.663576887Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv4": true,
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.enable_ipv4": "true",
            "com.docker.network.enable_ipv6": "false"
        },
        "Labels": {}
    }
]
```

# Create config files for the future DNS BIND server which will run in the container (in /etc/bind) 

## Create named.conf.local (see file)

## Create db.lab.luigi (see file)
Your zone file, where you configure your records.

## Create named.conf.options (see file)
So you add recursion (by default disabled in BIND)

# Launch the container:
We are creating the dns-server in the my-dns-lan network
```
docker run -d --name dns-server --network my-dns-lan --dns 172.18.0.2 --ip 172.18.0.2 \
-v $(pwd)/named.conf.local:/etc/bind/named.conf.local \
-v $(pwd)/db.lab.luigi:/etc/bind/db.lab.luigi \
-v $(pwd)/named.conf.options:/etc/bind/named.conf.options \
-p 53:53/udp -p 53:53/tcp \
ubuntu/bind9
```

# Test it with a disposable container 

## Run a disposable linux container and launch the shell from within
```
docker run --rm -it --network my-dns-lan --dns 172.18.0.2 busybox sh
```

## Check if it recognizes the dns server with the address 172.18.0.2
```
nslookup ns.lab.luigi
```

# Time to create 2 persistent (not disposable) Linux containers on the same Docker network and test name resolution and connectivity between them
```
docker run -d \
  --name client1 \
  --network my-dns-lan \
  --dns 172.18.0.2 \
  --ip 172.18.0.3 \
  busybox tail -f /dev/null

docker run -d \
  --name client2 \
  --network my-dns-lan \
  --dns 172.18.0.2 \
  --ip 172.18.0.4 \
  busybox tail -f /dev/null
```

# Test if they can resolve each other's names
```
docker exec client1 nslookup client2.lab.luigi
```



