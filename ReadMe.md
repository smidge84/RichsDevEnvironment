# Rich's Dev Environnmennt Container

Rather than installing loads of binaries onto my Laptops and also so I can version my developmet environnmennt, I have decided to make my own dev container and use VS Code Remote Containers extetsion.

This Docker image will be a heavy weight image, approximately 600MB

All this should be put into one of my own GitHub repos, so I can maintain the files correctly, and can easily rebuild things when I get new laptops.

## Pre-requisites
To be able to utilise this, the following pre-requisites need to be satisfied:

* VS Code installed
* Remote Containers extension installed
* Docker Desktop installed
* Packer installed

## Useful Documentation on Remote Contaiers

* [Please, everyone, put your entire development environment in Github](https://www-freecodecamp-org.cdn.ampproject.org/v/s/www.freecodecamp.org/news/put-your-dev-env-in-github/amp/?amp_js_v=a2&amp_gsa=1#referrer=https%3A%2F%2Fwww.google.com&amp_tf=From%20%251%24s&ampshare=https%3A%2F%2Fwww.freecodecamp.org%2Fnews%2Fput-your-dev-env-in-github%2F)
* [Packer - Getting Started with building Docker images](https://learn.hashicorp.com/collections/packer/docker-get-started)
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
  * Support the location of this config for both Mac, Liux & Windows
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

## Tutorials

Once the Dev Contaier is setup and working, I can then try it out by working through some of this guy's Ansible tutorial videos:

* [Rapidly Build & Test Ansible Roles with Molecule + Docker](https://www.youtube.com/watch?v=DAnMyBZ8-Qs&list=PLMyOob-UkeytIleCbMlFfCzaunOh27hm6&index=11)

## Docker Support

The Dev container can support working with Docker. This is implemented by using a technique called *"Docker in Docker"* or also *"Docker from Docker"*, where the Docker socket from the host machine is bind mounted into the Dev container, so that any Docker commands are redirected to the Docker daemon of the host machine. This means we don't need to run another Docker daemon inside the Dev cotainer (this approach is referred to as *"Docker inside of Docker"*). The added benefit of the "Docker in Docker" approach is that all the rsources of the host Docker daemon are shared and available inside the Dev container. However, this approach does have some practical issues, which are explained here:

* [VS Code Dev Containers - Docker from Docker](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/docker-from-docker)

### Enabling non-root access to Docker in the container

The points about a non-root user access the Docker socket seems to have been resolved without the use of `socat`. For some reason, now the image seems to have the standard permissions on the Docker socket inside the dev container by default, `root:docker`. This means that to give the runtime user access to the Docker socket, the user just needs to be added to the `docker` group. Will have to investigate if this works on a different machine to know if something on my Mac has caused this to work now.

### Using bind mounts when working with Docker inside the container

Working with filesystem mounts within the container is going to be tricky. In the use case of bind mounts, when the command is issued to the Docker daemon on the host machine, the source path of the bind mount is evaluated on the host machine's filesystem. This means that if the filesystem path inside the dev container is given as the source path, then the mount and command will fail. The Docker daemon needs the filesystem path as it is on the host system.
To work around this, an environment variable is available inside the dev container, `HOST_WORKSPACE_FOLDER`. This is the path to the workspace on the host filesyetem which has been mounted inside the dev container. This environment variable should be used in place of `pwd` when specifying the absolute path for the source of the bind mount.

This is by no means perfect because when working with files checked into version control which use relative paths to the mount sources (likely to be found in Docker compose files or scripts) they will not be able to work in their official form because the dev container is using *Docker from Docker*, and adding the special environment variable is not desirable because we don't want that to be checked into version control because it will not be available when the version controlled files are used on other hosts, such as build agents, which aren't using *Docker from Docker*. I might need to find a more creative workaround for this, in the guise of something which will be begine when used of standard Linux systems. Something like having a shell alias for the `pwd` command which would return a modified path.
