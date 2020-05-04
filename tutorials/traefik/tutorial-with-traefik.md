# Running FVTT-Docker with Traefik and Portainer
<a href="https://patreon.com/direckthit"><img src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fshieldsio-patreon.herokuapp.com%2Fdireckthit&style=for-the-badge" /> </a>

## Introduction
Docker is a great way to run applications. It will keep it separate from the rest of your system and you're running in the same environment regardless of the system hosting the container.

Traefik is a Docker-aware reverse proxy with a monitoring dashboard. Traefik also handles setting up your SSL certificates using Let's Encrypt allowing you to securely serve everything over HTTPS.

Portainer is a web interface for managing Docker. This allows you to easily start/stop/restart your docker containers, manage their settings, or add more containers in the future.

## Prerequisites

To follow along with this tutorial, you will need the following:
- A Debian based server - I recommend using Ubuntu 20.04.
    - Check out the [README](https://github.com/BenjaminPrice/fvtt-docker/blob/master/README.md) if you need some server hosting recommendations.
- Basic understanding of how to use the Linux command line
- A domain with three A records, each pointing to your servers IP address. I recommend, and for the tutorial will be using, the following: monitor, manage, play. You're free to use any A records you wish, just modify the steps below as appropriate.

## Tutorial

### Note
Throughout the tutorial I will use `nano` as the text editor as I find it's the most friendly to newer users. You're welcome to use whatever editor your prefer.

#### Saving and Exiting with `nano`
- `CTRL+X`
- Press `Y` - to save modifications
- `Enter`

### Step 1 - Setting up your server
This section will assume you're running as the root user, if you're not you can switch to root with the following command:

```sh
sudo su -
```

#### Installing the required packages:

Use the following command to install all of the required packages:
```sh
apt install apache2-utils docker.io docker-compose
```

Start docker and enable it to start on reboot
```sh
systemctl enable --now docker
```

Setup your firewall - we will only allow traffic to the server over SSH, HTTP and HTTPS.
```sh
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable
```
*When you enable ufw there will be a warning that your SSH connection may get closed. It shouldn't actually get closed as we've left port 22 open.*

### Step 2 - Configuring and Running Traefik

Generating a secure password. In the command below, substitute `secure_password` with the actual password you want to use.

```sh
htpasswd -nb admin secure_password
```

The output will look something like this:
```
admin:$apr1$ruca84Hq$mbjdMZBAG.KWn7vfN/SNK/
```

Take note of the output, we will need it near the end of this step.

Next up, we will start creating our config files. I recommend making a separate directory for each container. So, let's make a folder and switch into it.

```sh
mkdir traefik && cd traefik
```

Now, let's make our config file and start to edit it

```sh
nano traefik.yml
```

Copy and paste the following into your editor.

```yaml
api:
  dashboard: true

entryPoints:
  http:
    address: ":80"
  https:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false

certificatesResolvers:
  http:
    acme:
      email: email@example.com
      storage: acme.json
      httpChallenge:
        entryPoint: http
```

Modify the email address from `email@example.com` to a valid email address. This is used for generating your SSL certificates.

Save and exit your editor *(for `nano` check the Notes section above on how to Save & Exit)*

On the topic of SSL, we're going to need a file for our SSL information to be stored and persisted outside of the container. Let's create that file now.

```sh
touch acme.json
```

Let's lock down the permissions on this file so other users can't read it.

```sh
chmod 600 acme.json
```

Up next is the `docker-compose` configuration.

```sh
nano docker-compose.yaml
```

Same as before, copy/paste the contents below into your editor and get ready to make a few modifications.

```yaml
version: '3'

services:
  traefik:
    image: traefik:v2.0
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    ports:
      - 80:80
      - 443:443
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml:ro
      - ./acme.json:/acme.json
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=http"
      - "traefik.http.routers.traefik.rule=Host(`monitor.yourdomain.com`)"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=admin:$apr1$ruca84Hq$mbjdMZBAG.KWn7vfN/SNK/"
      - "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
      - "traefik.http.routers.traefik-secure.entrypoints=https"
      - "traefik.http.routers.traefik-secure.rule=Host(`monitor.yourdomain.com`)"
      - "traefik.http.routers.traefik-secure.middlewares=traefik-auth"
      - "traefik.http.routers.traefik-secure.tls=true"
      - "traefik.http.routers.traefik-secure.tls.certresolver=http"
      - "traefik.http.routers.traefik-secure.service=api@internal"

networks:
  proxy:
    external: true
```

Replace `monitor.yourdomain.com` with your own domain on the following lines:

```yaml
- "traefik.http.routers.traefik.rule=Host(`monitor.yourdomain.com`)"
```
```yaml
- "traefik.http.routers.traefik-secure.rule=Host(`monitor.yourdomain.com`)"
```

Replace the auth information from the first command we ran, in this Step, on this line:

```yaml
- "traefik.http.middlewares.traefik-auth.basicauth.users=admin:$apr1$ruca84Hq$mbjdMZBAG.KWn7vfN/SNK/"
```

Save and exit your editor.

We're nearly there. Now we need to create the docker network with a quick command.

```sh
docker network create proxy
```

With that done, we're ready to start our Traefik container.

### Step 3 - Running the Traefik Container

Alright, we did all the heavy lifting for Traefik in Step 1. Time to start the container.

```sh
docker compose up -d
```

This will build the docker container and start it up.

In your web browser, you should now be able to navigate to your Traefik monitoring page. You will be prompted to login with the `secure_password` you used at the start of Step 1. In your browser, replace `yourdomain.com` with your domain to login.

```
https://monitor.yourdomain.com
```

### Step 4 - Configuring and Running Portainer

Assuming you're still where we left off, let's go back up 1 level of our directory path, create a new directory for portainer, and switch into it.

```sh
cd .. && mkdir portainer && cd portainer
```

Portainer will create a fair number of files and directories that it needs to persist between runs. Let's make a directory for all that.

```sh
mkdir data
```

Now, we're going to create our `docker-compose` config file.

```sh
nano docker-compose.yaml
```

Copy/paste the contents below. We have 2 lines to modify after.

```yaml
version: '3'

services:
  portainer:
    image: portainer/portainer:latest
    container_name: portainer
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.entrypoints=http"
      - "traefik.http.routers.portainer.rule=Host(`manage.yourdomain.com`)"
      - "traefik.http.middlewares.portainer-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.portainer.middlewares=portainer-https-redirect"
      - "traefik.http.routers.portainer-secure.entrypoints=https"
      - "traefik.http.routers.portainer-secure.rule=Host(`manage.yourdomain.com`)"
      - "traefik.http.routers.portainer-secure.tls=true"
      - "traefik.http.routers.portainer-secure.tls.certresolver=http"
      - "traefik.http.routers.portainer-secure.service=portainer"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"
      - "traefik.docker.network=proxy"

networks:
  proxy:
    external: true
```

Modify the two lines below, replacing `yourdomain.com` with your domain.

```yaml
- "traefik.http.routers.portainer.rule=Host(`manage.yourdomain.com`)"
```
```yaml
- "traefik.http.routers.portainer-secure.rule=Host(`manage.yourdomain.com`)"
```

With that done, we're ready to start the Portainer container.

### Step 5 - Running the Portainer Container

Exactly the same as starting the Traefik container, we're going to run:

```sh
docker-compose up -d
```

Now, if you browse to `https://manage.yourdomain.com` (replacing yourdomain.com with your domain) you will be prompted to set up your login information.

We will use Portainer to setup and manage FoundryVTT

### Step 6 - Configuring and Running FoundryVTT


