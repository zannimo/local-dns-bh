# Launch Docker Desktop on macOS
```
open -a Docker 
```
# Create your Docker bridge 
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

# Create config files for the future DNS BIND server which will run in the container 

# Create named.conf.local:
```
zone "lab.luigi" {
    type master;
    file "/etc/bind/db.lab.luigi";
};
```

# Create db.lab.luigi with:
```
$TTL    604800 
@       IN      SOA     ns.lab.luigi. root.lab.luigi. (
                2025111502         ; Serial
                    604800         ; Refresh
                     86400         ; Retry
                   2419200         ; Expire
                    604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.lab.luigi.
@       IN      A       172.18.0.2  ; Server IP
ns      IN      A       172.18.0.2
client  IN      A       172.18.0.20  ; Client IP placeholder
```


# Launch the container:
```
docker run -d --name dns-server --network my-dns-lan \
-v $(pwd)/named.conf.local:/etc/bind/named.conf.local \
-v $(pwd)/db.mydomain.local:/etc/bind/db.lab.luigi \
-p 53:53/udp -p 53:53/tcp \
ubuntu/bind9
```

