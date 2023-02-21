function dokku-update-gluetun
    dokku ps:stop gluetun;
    sleep 2;
    docker pull qmcgaw/gluetun:latest;
    dokku ps:rebuild gluetun;
end
