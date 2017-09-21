# testmagentoinstall
This project can be used as a base for a build and deployment system for magento.

after cloning initialise the composer and docker submodules

  git submodule init
  
  git submodule update

You can add 3rd party 'composerized' modules in composer.json.

your custom, non composer code goes in src (use magento file layout, so src/app/code, src/app/design etc )

rebuild.sh runs a new build using your local files (runs composer install, pulls in magento files etc)

run a docker test/development environment:

    put your database dump in /magentodocker/import
    
    cd magentodocker && docker-compose up

deploy to servers defined in 'configs' (deploy.sh)

  your server web root needs to look like:
  
 - /webroot/
 - /webroot/config/
 - /webroot/config/local.xml (magento local.xml config settings)
 - /webroot/releases/
 - /webroot/static/
 - /webroot/static/media/ (magento media folder)

  the deployment script (deploy.sh) first checks out a branch into /deployment, builds it, deploys it to a subfolder of 'releases', then symlinks that into htdocs

  your web server needs to point at /webroot/htdocs

  your host needs to be defined in your .ssh/config file

  the user you connect as needs passwordless sudo permissions.

Tested on macOS, should work on a linux box though!

No warranty implied or otherwise conferred via use of this software.  use at your own risk.
