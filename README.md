# Foundry VTT - Docker

<a href="https://patreon.com/direckthit"><img src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fshieldsio-patreon.herokuapp.com%2Fdireckthit&style=for-the-badge" /> </a>

## Foundry VTT - Docker

This repository hosts the Foundry VTT `Dockerfile` for [direckthit/fvtt-docker](https://hub.docker.com/r/direckthit/fvtt-docker) on Docker Hub.

> [Foundry VTT](https://foundryvtt.com/) is a virtual tabletop for playing tabletop RPG games such as Dungeons & Dragons 5e.

I've also included a basic `docker-compose.yaml` file which you can use to get things up and running quickly.

### **Note**
At the request of the author of Foundry VTT, the source code for Foundry VTT is not included in this image. 

You will need to manually download the zip file from your Foundry VTT account on the [official Foundry VTT website](https://foundryvtt.com/).

---

## **Recommended Hosting**

I recommend you host your server on a dedicated server. They can be quite cheap.

If you don't have a preferred provider, a $5 Ubuntu server from either of the below options are good considerations.

### **Hosting Options**

#### Linode
A great cheap provider with servers all around the globe. They're one of the older VPS providers still around.

**This is where I personally choose to host my games**

[Sign Up](https://www.linode.com/?r=311b3d1469c9a251020a9385437b21266fa076f0)

A couple promo codes you can try during registration (no guarantees):

- `OBJECT20` - $20 Credit
- `LINODE10` - $10 Credit

#### Digital Ocean
Another great cheap provider with servers all around the globe.

[Sign Up](https://m.do.co/c/879607663421)

Using the above link should grant you a $100 credit (expires in 60 days).

---

## **Installation**

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Instructions

### Step 0 - Install Prerequisites

***Ensure you have both Docker and Docker Compose installed by following the directions in the links above.***

### Step 1 - Download the `docker-compose.yaml` file

Manually download it or use the command below

```shell
wget https://raw.githubusercontent.com/BenjaminPrice/fvtt-docker/master/docker-compose.yaml
```

### Step 2 - Download the Foundry VTT Zip File

- Navigate to your User Profile page and find your Software Download Links on your license page.
- Download the `Linux` version.
- Save it to the same directory as the `docker-compose.yaml` file from the previous step.

### Step 3 - Create your data directory

This directory is where your games, images, etc will all be stored and persisted when the docker container is restarted.

Either manually create the directory or use this shell command (linux/mac/WSL only) to create the directory in your user home:

```shell
mkdir $HOME/foundryvtt-data/
```

### Step 4 - Create your app directory (optional)

This is where you can place your custom login screen. You only need to perform this step if you want a custom login screen on foundryVTT.

Either manually create the directory or use this shell command (linux/mac/WSL only) to create the directory in your user home:

```shell
mkdir $HOME/foundryvtt-app/
```

### Step 5 - Modify the `docker-compose.yaml` file

#### Set your data directory by modifying this line:

```yaml
- /path/to/your/foundry/data/directory:/data/foundryvtt
```

Example:

```yaml
- /home/player1/foundryvtt-data:/data/foundryvtt
```

#### Set your download directory (where you saved your zip file) by modifying this line:

```yaml
- /path/to/your/foundry/zip/file:/host
```

Example:

```yaml
- /home/player1/downloads:/host
```

#### Set your app directory (where the app and login screen resides) by modifying this line:

```yaml
- /path/to/your/foundry/app/file:/opt/foundryvtt/app
```

Example:

```yaml
- /home/player1/foundryvtt-app:/opt/foundryvtt/app
```

### Step 6 - Run the server

```shell
docker-compose up -d
```

### Step 7 - Access the server

Navigate to your server in your webbrowser (by IP address, is recommended)

`http://127.0.0.1:30000/`

Replace `127.0.0.1` with your own IP address.
