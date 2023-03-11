# Gluetun + Dokku - Installation Guide

<p>
    <a href="https://github.com/Rikj000/Gluetun-Dokku-Installation/blob/master/README.md">
        <img src="https://img.shields.io/badge/Docs-Gluetun+Dokku-blue?logo=libreoffice&logoColor=white" alt="The current place where you can find Gluetun Dokku Installation Documentation!">
    </a> <a href="https://github.com/Rikj000/Gluetun-Dokku-Installation/blob/master/LICENSE.md">
        <img src="https://img.shields.io/github/license/Rikj000/Gluetun-Dokku-Installation?label=License&logo=gnu" alt="GNU General Public License">
    </a> <a href="https://www.iconomi.com/register?ref=zQQPK">
        <img src="https://img.shields.io/badge/Join-ICONOMI-blue?logo=bitcoin&logoColor=white" alt="ICONOMI - The world’s largest crypto strategy provider">
    </a> <a href="https://www.buymeacoffee.com/Rikj000">
        <img src="https://img.shields.io/badge/-Buy%20me%20a%20Coffee!-FFDD00?logo=buy-me-a-coffee&logoColor=black" alt="Buy me a Coffee as a way to sponsor this project!">
    </a>
</p>

Another guide, this time to host [`gluetun`](https://github.com/qdm12/gluetun) in a [`dokku`](https://dokku.com/) container,   
so you can easily route individual dokku containers through a VPN!

Due to no clear documentation for this being available on the web,   
I've decided to write out some of my own after finally succeeding with my own setup.


## Prerequisites

Following prerequisites fall out of the scope of this installation guide:
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [Dokku](https://dokku.com/)
    - Linked domain name *(e.g. my-dokku-server.com)*
    - SSL Certification *(e.g. LetsEncrypt, Cloudflare, ...)*
- [Ledokku](https://www.ledokku.com/) *(Optional)*

## Installation

### **1.** Install a `gluetun` Dokku app

- **1.1.** Create a `gluetun` dokku app:   
    ***(If using `ledokku`, then use GUI instead, to create the `gluetun` app!)***   

    ```bash
    dokku apps:create gluetun
    ```

- **1.2.** Setup `volumes` to assure settings & storage will stick upon container re-creation:   

    ```bash
    sudo mkdir -p /var/lib/dokku/data/storage/gluetun
    sudo chown dokku:dokku /var/lib/dokku/data/storage/gluetun/
    dokku storage:mount gluetun /var/lib/dokku/data/storage/gluetun/:/gluetun
    ```

- **1.3.** Configure the required environment variables, change as needed:   

    This is an example using Perfect Privacy as the VPN provider.   
    **Check the required environment variables for your VPN provider at the `Setup/Providers` section of the [Gluetun Wiki](https://github.com/qdm12/gluetun/wiki)!**
    ```bash
    dokku config:set --no-restart gluetun \
        VPN_SERVICE_PROVIDER="perfect privacy" \
        OPENVPN_USER="username-here" \
        OPENVPN_PASSWORD="password-here" \
        SERVER_CITIES="Amsterdam,Basel,Belgrade,Berlin,Bucharest,Calais,Chicago,Copenhagen,Dallas,Erfurt,Frankfurt,Hamburg,Hongkong,Istanbul,Jerusalem,London,LosAngeles,Madrid,Malmoe,Manchester,Miami,Milan,Montreal,Moscow,NewYork,Nuremberg,Oslo,Paris,Prague,Reykjavik,Riga,Rotterdam,Singapore,Stockholm,Sydney,Tokyo,Vienna,Warsaw,Zurich" \
        TZ="UTC"
    ```

- **1.4.** Setup additional `deploy` and `run` `docker-options`:   

    ```bash
    # Allow modification of network interfaces on the host system:
    dokku docker-options:add gluetun deploy,run '--cap-add NET_ADMIN'
    ```

- **1.5.** Disable the `web` and enable a `worker` process:   

    ```bash
    dokku ps:scale gluetun worker=1 web=0
    ```

- **1.6.** Deploy the latest `gluetun` docker tag:   

    ```bash
    dokku git:from-image gluetun qmcgaw/gluetun:latest
    ```

### **2.** Install a `transmission` Dokku app for testing `gluetun`

- **2.1.** Create a `transmission` dokku app:   
    ***(If using `ledokku`, then use GUI instead, to create the `transmission` app!)***   

    ```bash
    dokku apps:create transmission
    ```

- **2.2.** Configure the required environment variables, change as needed or leave default:   

    ```bash
    dokku config:set --no-restart transmission \
        USER="admin" \
        PASS="password"
    ```

- **2.3.** **Glue `transmission` to the `gluetun` network!**

    ```bash
    dokku docker-options:add transmission deploy,run '--network=container:gluetun.worker.1'
    ```

- **2.4.** Deploy the latest `transmission` docker tag:   

    ```bash
    dokku git:from-image transmission lscr.io/linuxserver/transmission:latest
    ```

- **2.5.** Validate if `transmission` is being routed through the `gluetun` VPN connection:   

    ```bash
    # Print out in which city the dokku host resides:
    curl -s ipinfo.io/json | grep city
    # Print out "in which city" the transmission container resides:
    dokku run transmission curl -s ipinfo.io/json | grep city
    ```

## Updates

```bash
dokku ps:stop gluetun; sleep 2; docker pull qmcgaw/gluetun:latest; dokku ps:rebuild gluetun
```

## Bonus `fish`

If you're using [`fish`](https://fishshell.com/) as your shell,   
then you can add these [`fish-functions`](https://github.com/Rikj000/Pihole-Gluetun-Installation/tree/master/fish-functions) to your `~/.config/fish/functions/` directory.

This will make following commands available under `fish`,   
to ease up the usage of `gluetun` with `dokku`:

```bash
# Enable VPN for dokku app
dokku-app-vpn-enable <app-name>
# Disable VPN for dokku app
dokku-app-vpn-disable <app-name>
# Check current city of dokku app, requires curl + grep in container!
dokku-app-vpn-status <app-name>
# Updates Gluetun dokku app
dokku-update-gluetun
```

## Used Sources
- [Docs - Dokku](https://dokku.com/docs/getting-started/installation/)
- [Docs - Gluetun](https://github.com/qdm12/gluetun/wiki)
- [Github - Pihole-Dokku-Installation](https://github.com/Rikj000/Pihole-Dokku-Installation)
- [Blog - Put a docker container behind VPN](https://medium.com/linux-shots/put-a-docker-container-behind-vpn-fdc0e32c9ca5)
