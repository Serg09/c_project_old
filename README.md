### Crowdscribed ###

Website facilitating book publishing

http://www.crowdscribed.com/

### How do I get set up? ###

[Install PostgreSQL](https://help.ubuntu.com/community/PostgreSQL) for development. (SQLite is used for tests.)
```
sudo apt-get install postgresql postgresql-contrib
sudo -u postgres createuser --superuser $USER
sudo -u postgres psql
```
Add a new role "app_user"
```
CREATE ROLE app_user SUPERUSER CREATEDB CREATEROLE LOGIN;
```
[Install PostgreSQL](https://help.ubuntu.com/community/PostgreSQL) client and server;

```
sudo apt-get install postgresql-client
sudo apt-get install postgresql-server-dev-9.5 # or whatever version is current
```

Install node.js
```
sudo apt-get install node.js
```

Install ImageMagick
```
sudo apt-get install imagemagick libmagickwand-dev
```

Install Redis
```
sudo apt-get install redis-server
```

Clone the repo
```
git clone git@bitbucket.org:crowdscribed/crowdscribed.git
```

If you see an error like this: ```Connection to bitbucket.org closed by remote host.
fatal: Could not read from remote repository.
Please make sure you have the correct access rights and the repository exists.```
 
Check firewall settings. SSH connection should be set to port 22 


Install gems
```
bundle install
```

Setup the database
```
rake db:setup
```

Start the web server and the resque workers. (You'll need to have the [heroku tookbelt](https://blog.heroku.com/the_heroku_toolbelt) installed.)
```
heroku local -p 3000
```

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Publish to Staging

Add the heroku staging repo to your git repo, if it's not already there
```
git remote add staging https://git.heroku.com/crowdscribe-staging.git
```

Install the [heroku toolbelt](https://toolbelt.heroku.com/), if it's not already there
```
wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
```

Publish to the staging repo
```
git push staging master
```

Run any pending database migrations
```
heroku run rake db:migrate
```

Confirm the deployment at http://staging.crowdscribed.com.

### Who do I talk to? ###

* [Doug Knight](mailto:doug.knight@crowdscribed.com)
* [Christian Piatt](mailto:christian.piatt@crowdscribed.com)