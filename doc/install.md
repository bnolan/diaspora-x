# Fork the official repository (10 minutes)

You will probably want to set up diaspora\*x on your laptop / development machine, so that you can test changes locally and make contributions to the project. Just go to the [github page](http://github.com/bnolan/diaspora-x/) and hit fork. Read [this documentation](http://help.github.com/forking/) at github to understand more about how to get your improvements merged back into Diaspora\*x.

<small>Note that changes to diaspora*x are bundled up into semi-regular pushes back to Diaspora trunk.</small>

Then go to config/

# Register a virtual private server (5 minutes)

_Diaspora\*x is under constant development and it's recommended you use a virtual private server until a stable release is available._

[Linode](http://linode.com/), [Slicehost](http://slicehost.com/) and [Amazon ec2](http://aws.amazon.com/ec2/) are all good options for a VPS. Make sure you purchase a server with at least 256mb of RAM. Choose Ubuntu 10.04 LTD (lucid) when setting up your operating system.

# Log in as root and secure your box (20 minutes)

Go through the usual steps on a new box, if you are new to ubuntu - slicehost has a [good guide](http://articles.slicehost.com/2008/4/25/ubuntu-hardy-setup-page-1). You should take care to set up your iptables (firewall) rules correctly.

Make sure you run:

    sudo aptitude update
    
# Install ejabberd (10 minutes)

    sudo aptitude install ejabberd

Configure the jabber server to allow registrations by editing `/etc/ejabberd/ejabberd.cfg`.

    %% No username can be registered via in-band registration:
    %% To enable in-band registration, replace 'deny' with 'allow'
    % (note that if you remove mod_register from modules list then users will not
    % be able to change their password as well as register).
    % This setting is default because it's more safe.
    {access, register, [{allow, all}]}.
    
Set the delay between registrations to 0.

    %% By default frequency of account registrations from the same IP
    %% is limited to 1 account every 10 minutes. To disable put: infinity
    {registration_timeout, 0}.

Set your domain name:

    %% Hostname
    {hosts, ["jabber.diaspora-x.com", "localhost"]}.

Restart ejabberd:

    sudo /etc/init.d/ejabberd restart

If you are having problems configuring ejabberd, seed [this guide](http://library.linode.com/communications/xmpp/ejabberd/ubuntu-9.04-jaunty) from Linode.

# Purchase a domain (5 minutes)

It works best if you set up diaspora-x on your own domain. Support for subdomains and different domains between the jabber server and the rails app aren't supported yet.

# Configure DNS (10 minutes)

Log into your registrar and open the DNS zone file editor. At godaddy this is called the DNS Manager. Configure your domain as follows. Note to change 123.4.5.67 to the IP address of your server.

A records:

    @ => 123.4.5.67
    
CNAME records:
  
    www => @
    jabber => @
    
SRV records:

    _xmpp-client._tcp:5222 jabber.yourdomain.com
    _xmpp-server._tcp:5269 jabber.yourdomain.com
    _jabber._tcp:5269 jabber.yourdomain.com

On GoDaddy - your SRV records should look like this:

<img src="..." />

You can use this [tool](http://dopeman.org/xmpp_srv_test/?domain=yourdomain.com) to check your srv records are set correctly, or run:

    dig -t srv _xmpp-client._tcp.yourdomain.com

Once you have your records set up correctly you're ready to move on.

# Test your jabber setup

Install [PSI](http://.../) and try and register an account with `jabber.yourdomain.com`.

# Install ruby on rails and passenger (5 minutes)

Again - I'll defer to the [slicehost guide](http://articles.slicehost.com/2008/5/1/ubuntu-hardy-mod_rails-installation) for this one.

    sudo aptitude install ruby1.8-dev ruby1.8 ri1.8 rdoc1.8 irb1.8 libreadline-ruby1.8 libruby1.8 libopenssl-ruby sqlite3 libsqlite3-ruby1.8

And then

    sudo ln -s /usr/bin/ruby1.8 /usr/bin/ruby
    sudo ln -s /usr/bin/ri1.8 /usr/bin/ri
    sudo ln -s /usr/bin/rdoc1.8 /usr/bin/rdoc
    sudo ln -s /usr/bin/irb1.8 /usr/bin/irb 
 
Run `ruby -v` and check you have ruby 1.8.7. Now install apache, passenger and build-essential:

    sudo aptitude install apache2 apache2.2-common apache2-mpm-prefork apache2-utils libexpat1 ssl-cert build-essential libapache2-mod-passenger
  
Now install rubygems from source. First download it from [rubygems.org](http://rubygems.org/pages/download).

    cd ~
    mkdir build
    cd build
    wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
    tar xvfz rubygems-1.3.7.tgz
    cd rubygems-1.3.7
    ruby setup.rb
    ln -s /usr/bin/gem1.8 /usr/bin/gem
    
Finally - install bundler and rake.

    gem install bundler rake

# Install postgres

    sudo aptitude install postgresql

Set the postgres authentication settings. `Edit /etc/postgresql/8.4/main/pg_hba.conf` and change the first ident line to:

    local   all         all                               ident sameuser

Then restart postgres:

    /etc/init.d/postgresql-8.4 restart
    
Create the database

    createdb -E utf8 diasporax_production

# Install the diaspora-x app


These [installation instructions](http://sam.minnee.co.nz/deployment-using-git) use git from your local box. If you are experienced with using Capistrano, you might want to configure your deployment using Capistrano. Once you've got this set up, you will be able to deploy from your development box in about 20 seconds, so it's good for making changes to your production set up.

First up - install git

    sudo aptitude install git-core

On your server - set up your deployment system like so:

    mkdir -p /var/apps/diaspora-x
    cd /var/apps/diaspora-x
    git init
    git config receive.denyCurrentBranch ignore
    echo "cd .." >> .git/hooks/post-receive
    echo "env -i git reset --hard HEAD" >> .git/hooks/post-receive
    echo "env -i git checkout -f" >> .git/hooks/post-receive
    echo "make post-deploy" >> .git/hooks/post-receive
    chmod +x .git/hooks/post-receive
    
Then make sure your normal user has permissions to deploy:

    chown -R your_username:your_username .

Then create a Makefile in /var/apps/diaspora-x that looks like this:

    post-deploy:
        bundle install
        RAILS_ENV=production rake db:migrate
        touch tmp/restart.txt

Then on your _local box_:

    git remote add prod yourdomain.com:/var/apps/diaspora-x
    git config remote.prod.fetch +master:master
    git push prod master:master

# Configure apache

Edit `config/apache.conf` on your local box, to match the domain name that you set diaspora-x up on. Then deploy it to production and copy the config to `/etc/apache2/sites-available/diaspora-x`.

Then enable your site:

    sudo a2enmod headers
    sudo a2enmod rewrite
    sudo a2ensite diaspora-x
    /etc/init.d/apache2 restart

If everything went well - you should now be able to browse to http://yoursite.com/ and be presented by the login page.

# Set up monit to run connector.rb

The connector