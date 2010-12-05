# Diaspora X - Diaspora with XMPP support

Diaspora is a wonderful project with awesome community support and lovely design. This is a branch of Diaspora that supports [XMPP PEP](http://xmpp.org/extensions/xep-0163.html) and [Activitystreams](http://wiki.activitystrea.ms/w/page/1359319/Verb-Mapping) for federation.

## For end users

Go to [diaspora-x.com](http://www.diaspora-x.com/) to sign up for an account.

## Acknowledgments

The xmpp pep protocol that this project uses was pioneered by Vodafone R&D at the [OneSocialWeb](http://onesocialweb.org/) project. This project is derived from the Diaspora [github](http://github.com/diaspora) project. This project is inspired from the PEP aggregator that is included in the [xmpp4r](http://home.gna.org/xmpp4r/) distribution.

## Author

  * [Ben Nolan](http://www.bennolan.com/)
  
## Goals

Once this project has proven the viability of using XMPP for federation, I hope to merge the XMPP backend into Diaspora trunk. This branch may remain as a light weight 'diaspora light' that has lower system requirements - for example, this project has less gem dependencies than Diaspora trunk and uses relational databases instead of nosql as per Diaspora trunk.

# Installation on a development system

Install [ejabberd](http://www.ejabberd.im/) or [openfire](http://www.igniterealtime.org/projects/openfire/). Disapora-X has't tested with openfire, but I understand that it should work.

## Configure your jabber server

Set your jabber server domain to be the local name of your box - for example `mymachine.local`. It's better to use a name that is unique, and not just `localhost`, so that other devices on your local network can access your development environment for testing. 

Set the server to allow registrations, and disable a wait time between registartions. On ejabberd, set the `registration_timeout` to `1` in ejabberd.cfg.

Start the server.

### Test your jabber server

You may want to install [PSI](http://psi-im.org/), a powerful jabber client that lets you view the XML stream for debugging purposes. Try and register an account on your local jabber server and check that you can sign in.

If your jabber server works, you're ready to move on.

## Install and configure the rails app

Install ruby, rubygems and bundler. I'm not sure what will be required to get this project to work on a Window box, but it should be possible in theory. Edit `config/environments/development.rb` and change the following line to be the same domain as your jabber server:

    config.server_name = "boomba.local"

Now you can install the gem bundle, generate the database, start the connector and start the rails server.

    bundle install
    rake db:migrate
    script/runner Connector.new &
    script/server &
    
You should now be able to browse to the site at [localhost:3000](http://www.localhost:3000/).

## Sign up for an account

Try and sign up for an account and start using the system. Because you are running locally and you haven't set up server 2 server (s2s) federation for your jabber server, you won't be able to friend users who are running on other jabber servers on the wider net.

See the page on [production setup](#todo) for information about running Diaspora X in production.

# Design considerations

When building this system there are a few things that I haven't been able to solve to my complete satisfaction - so here are some issues that need to be resolved:

## Plaintext passwords

Because the `connector` needs access to the users password, the users password is stored in plaintext in our database. This needs to be solved asap. A good solution would be to provide an ejabberd [authentication script](http://www.ejabberd.im/extauth) that runs against devise.

## Connector

The connector runs in a seperate process, and currently polls the database for new records that are then serialized to xmpp commands. I'm unsure if this is the best way to do it, maybe a queue from the webserver processes to the connector would be better.

## Authoritative for email address

We don't check that the user is authoritative for an email address, some thought needs to go into how we prove a user has access to an email address in a federated system.

## Invite emails

Friend request emails need to let the invitee respond from their own Diaspora seed. I can see two solutions to this - a community-owned redirector that uses localStorage to track and redirect the user to their own seed, or have a UI device on each seed so that when an invitee follows a link in the invitation email, they can be specify the address of their seed, and have the invitation code forwarded to their seed.

# Todo list

1. Support buddycloud [geo nodes](http://open.buddycloud.com/channel-protocol)
