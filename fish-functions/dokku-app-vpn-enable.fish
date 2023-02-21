function dokku-app-vpn-enable
    dokku docker-options:add $argv deploy,run '--network=container:gluetun.worker.1';
    echo {(dokku run $argv curl -s ipinfo.io/json | grep city),}
end
