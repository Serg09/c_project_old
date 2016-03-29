### CrowdScribe ###

Website facilitating book publishing

(http://www.crowdscribed.com/)

### How do I get set up? ###

Clone the repo
```
git clone git@bitbucket.org:dgknght/crowdscribe.git
```

Install gems
```
bundle install
```

Setup the database
```
rake db:setup
```

Start the web server
```
puma
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

### Who do I talk to? ###

* [Doug Knight](mailto:doug.knight@crowdscribed.com)
* [Christian Piatt](mailto:christian.piatt@crowdscribed.com)
