# Creating the Nginx websites, properly and fast

The main idea is to create the PHP (at this point) websites which will work as **isolated "users"**.
We're using PHP-FPM and `fastcgi_pass`-ing the requests to the *separate* php-fpm-sockets, running as separate users.

### Usage:

`./create-website.sh`

Or if the file hasn't become executable on your side, run it with `bash`:

`bash create-website.sh`

It will ask you just 2 things: _username_ and website's _domain name_

In order to use the prepared templates for some CMSs, just start the script (it should be a symlink) from the folder e.g. 'bitrix':

`cd bitrix && ./create-website.sh`


### Description

The permissions model is as follows:
* a Unix user is created for every website (e.g. 'website1')
* a primary Unix group (with the same name - 'website1') is also created for it
* we're adding the Nginx user (which is 'www-data' by default) to this new group, to let Nginx serve the static content

A new separate PHP-FPM pool is also created, just for the new website, which will run as the 'website1' user.

The following folders are created in e.g. `/home/website1` for placing the website's files:
* 'public_html' with `website1:website1` ownership and 750 mode, so that only the web-app would have rw-access, and Nginx would only read it
* 'private_html' with `website1:website1` ownership and 700 mode, so that only the web-app could get there, and keep some configuration files or backups for example
* only the 'public_html' folder becomes the www-root for the website

As for the OS-level configuration:
* if the directory /var/log/php doesn't exist, it's created


There are some examples for different CMSs available, each one in its folder here, symlinking to the main script.
Feel free to fine-tune them for your case.


TODO:
* ! check if php-pools path exists, also the systemctl service; before starting the script
* check if the user or group already exists, the same for paths/folders
* make the non-interactive mode, to call the scripts and make them do everything automatically and optionally silently
* add calling of LetsEncrypt (if it's installed) after creating the website


--  
Danil V. Gerun  
danil@625.ru
