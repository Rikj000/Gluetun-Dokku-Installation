function dokku-app-vpn-status
    echo {(dokku run $argv curl -s ipinfo.io/json | grep city),}
end
