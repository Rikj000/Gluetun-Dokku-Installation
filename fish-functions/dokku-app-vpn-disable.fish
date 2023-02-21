function dokku-app-vpn-disable
    dokku docker-options:remove $argv deploy,run '--network=container:gluetun.worker.1';
    echo {(dokku run $argv curl -s ipinfo.io/json | grep city),}
end
