# Rich's Dev Environnmennt Container

Rather than installing loads of binaries onto my Laptops and also so I can version my developmet environnmennt, I have decided to make my own dev container and use VS Code Remote Containers extetsion.

This Docker image will be a heavy weight image, approximately 600MB

All this should be put into one of my own GitHub repos, so I can maintain the files correctly, and can easily rebuild things when I get new laptops.

## Pre-requisites
To be able to utilise this, the following pre-requisites need to be satisfied:

* VS Code installed
* Remote Containers extension installed
* Docker Desktop installed

## Useful Documentation on Remote Contaiers

* [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)
* [Getting Started with development in Containers](https://code.visualstudio.com/docs/remote/containers-tutorial)
* [Create a development container](https://code.visualstudio.com/docs/remote/create-dev-container)
* [Advanced development container configuration](https://code.visualstudio.com/remote/advancedcontainers/overview)

## Main Requirements

* Based on Alpine 3
* Start from the official "Docker in Docker" image (provided by Docker)
  * Fortunately this is based on Alpine 3, and will save me a lot of work ennsuring Docker works correctly
  * `docker:20.10.17`
* Install Ansible 2.9.6 (because this is the version in Ubuntu 20.04)
  * Follow the steps in my existing "ansible-docker" project in Luminate/DevOpsPOCs repo
* Install Molecule (for Ansibile)
  * This must be Molecule version 5.4.0 because in version 6.0.0 they discontinued support for Ansible 2.9 (unless I want to use the latest release of Ansible)
  * If we don't use this specific version of Molecule, PIP will update Ansible
  * [Molecule Docs - Installation](https://molecule.readthedocs.io/en/latest/installation.html#install)
* Try to install the latest available version of the VS code server program at build time. This is to hopefully improve the start-up time of the contnainer
  * Without the code-server installed, this will have to be installed everytime the container is started
  * The performance improvement of doing this will be lost when a newer version of the VS Code Server becomes available, as it will need to be updated upon container initialisation anyway
  * Might be good to setup an automated pipeline to check for a new version and re-build the docker image if necessary

Be sure to clean up build depenndencies and caches.

```bash
echo "==> Cleaning up..."  && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip/*
```

## Python User Environment

Even though there is no system install of Python in Alpine Linux, it will still be good to follow best practices and setup as much in the user space as possible.
This will require the definition of a step-down user, which will need to be part of the Docker group.
By installing Python and Ansible module in the User space, it will avoid the warnings about doing such things as the root user.

This step-down will become the main runtime user, and as such all runtime files should be mounted into that user's home directory.
Maybe setup a working directory `/home/cayde/work/` into which the development files from the host will be bind mounted into.
This means also that SSH keys can go into the user's SSH directory like normal.

## Secondary Requirements

* Bind mount in host Git config
  * Support the location of this config for both Mac, Liux & Windows
* Bind mount in SSH keys
  * * Support the location of this config for both Mac, Liux & Windows
* Ensure that we can utilise Git from within the Dev Container

## Building Requiremets

* Use Packer to build the Docker image rather than a Dockerfile
  * This will enable us to utilise Ansible collections/roles to orchestrate as much of the setup as possible
* Packer will use the shell provisioner to first install Python 3 and then Ansible (via PIP)
* Versions of everything should be specified in a variables file
* Packer will then user the ansible-local provisioer to configure the remainder of the image
  * As defied in a separately mainted Ansible Collection

## VS Code Dev Container Configuration

What sort of things will I need to setup in the `devcontainer.json` file?

## Questions

* How do you bind mount in the Docker Socket on Windows so that Docker in Docker (DooD) works?
* 

## Tutorials

Once the Dev Contaier is setup and working, I can then try it out by working through some of this guy's Ansible tutorial videos:

* [Rapidly Build & Test Ansible Roles with Molecule + Docker](https://www.youtube.com/watch?v=DAnMyBZ8-Qs&list=PLMyOob-UkeytIleCbMlFfCzaunOh27hm6&index=11)
