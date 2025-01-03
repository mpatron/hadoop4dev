#!/usr/bin/bash

proxy_one_on()
{
        server_proxy=squid1.jobjects.net
        server_port=8080
}
proxy_two_on()
{
        server_proxy=squid2.jobjects.net
        server_port=8080
}
proxy_off() {
        unset no_proxy_local
        unset http_proxy
        unset https_proxy
        unset no_proxy
        unset MAVEN_OPTS
        echo "PROXY set off"
}
proxy_set() {
        export http_proxy=$(echo "http://"${server_proxy}":"${server_port})
        export https_proxy=$(echo "http://"${server_proxy}":"${server_port})
        printf -v no_proxy_local '%s,' 10.7.173.{1..255};
        export no_proxy=127.0.0.1,localhost,.jobjects.net,${no_proxy_local%,}
        export MAVEN_OPTS="-Djava.net.preferIPv4Stack=true -Dhttp.proxyHost=${server_proxy} -Dhttp.proxyPort=${server_port} -Dhttps.proxyHost=${server_proxy} -Dhttps.proxyPort=${server_port}"
        echo "PROXY set on ${http_proxy}"
}
proxy_off

proxy_one_on
ping -c 1 ${server_proxy}  > /dev/null 2>&1
if [[ $(echo $?) -eq 0 ]]; then
        proxy_set
else
        proxy_two_on
        ping -c 1 ${server_proxy}  > /dev/null 2>&1
        if [[ $(echo $?) -eq 0 ]]; then
                proxy_set
        else
                proxy_off
        fi
fi