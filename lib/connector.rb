#!/usr/bin/env ruby

require 'xmpp4r/framework/bot'
require 'xmpp4r/pubsub'
require 'xmpp4r/vcard'
require 'xmpp4r/caps'
require 'xmpp4r/roster/helper/roster'

class ConnectorBot < Jabber::Framework::Bot
  include REXML
  
  def initialize(user)
    @user = user

    super(@user.jid, @user.encrypted_password)

    add_capabilities
    set_presence(nil, "I'm busy aggregating PEP events...")

    @vcard = Jabber::Vcard::Helper.new(stream)
    get_roster
  end
  
  def accept_subscription_from?(jid)
    friend = self.find_by_jid(jid)
  
    relationship = Relationship.find(:first, :conditions => {:user_id => friend.id, :friend_id => @user.id})
    
    if not relationship
      relationship = Relationship.create! :user_id => friend.id, :friend_id => @user.id, :accepted => false
    end
      
    if relationship.accepted?
      relationship.create_reverse!
      roster.add(friend.jid, nil, true)
    else
      # nothing...
    end
  end
  
  def on_microblog(jid, item)
    friend = self.find_by_jid(jid)
    
    activity = friend.activities.find_or_create_by_uuid item.attributes['id']
  
    if e = XPath.first(item, "//atom:content", { "atom" => "http://www.w3.org/2005/Atom" })
      activity.content = e.text
    end
    
    if e = XPath.first(item, "//activity:verb", { "atom" => "http://activitystrea.ms/spec/1.0/" })
      activity.verb = e.text.sub('http://activitystrea.ms/schema/1.0/','')
    end
    
    if e = XPath.first(item, "//atom:published", { "atom" => "http://www.w3.org/2005/Atom" })
      activity.created_at = DateTime.parse(e.text)
    end
    
    if e = XPath.first(item, "//atom:updated", { "atom" => "http://www.w3.org/2005/Atom" })
      activity.updated_at = DateTime.parse(e.text)
    end
  
    puts " < #{@user.jid} recieved #{activity.verb} from #{activity.user.jid}"

    activity.save!
  end
  
  def process_records!
    @user.activities.unfederated.each do |a|
      
    end
    
    relationships = Relationship.find(:all, :conditions => ['federated = ? and user_id = ?', false, @user.id])
    relationships.each do |r|
      if r.friend.jid.present?  # fixme - needs refactoring.
        roster.add Jabber::JID.new(r.friend.jid), nil, true
        puts " > #{@user.jid} friended #{r.friend.jid}"
      end
      
      r.federated!
    end
  end
  
  protected
  
  def update_user(user)
    if user.local?
      # fixme - log this.
      return
    end
    
    vcard = @vcard.get(user.jid)
  
    if vcard
      user.update_attributes!(
        :description => vcard['DESC'],
        :url => vcard['URL'],
        :email => (vcard['USERID'] or user.jid), # unknown-email-address-plz-fix@devise.me - fixme
        :phone => vcard['NUMBER'],
        :dob => begin
            Date.parse(vcard['BDAY'])
          rescue TypeError
            nil
          rescue ArgumentError
            nil
          end
      )
    end
  end
  
  def add_capabilities
    add_pep_notification("urn:xmpp:microblog:0") do |jid,node|
      on_microblog(jid,  XPath.first(node, '//item'))
    end
  end
  
  def get_roster
    roster.groups.each do |g|
      roster.find_by_group(g).each do |item|
        friend = self.find_by_jid(item.jid)
        relationship = @user.relationships.find_by_friend_id(friend.id) || @user.relationships.build(:friend_id => friend.id)
        relationship.update_attributes! :accepted => true, :federated => true
      end
    end
  end
  
  def find_by_jid(jid)
    user = User.find_by_jid(jid.to_s)
    
    if not user
      user = User.new(
        :jid => jid.to_s,
        :local => (jid.domain == Diaspora::Application.config.server_name)
        # :email => jid.to_s,
        # :password => 'plz-fix' # fix devise validation - fixme
      )
      
      user.save(:validate => false)
      
      update_user(user) unless user.local?
    end
    
    user
  end
  
end

class Connector
  def initialize
    # Jabber::debug = (Rails::env != 'production')

    @bots = {}
    
    User.find(:all, :conditions => ['local=? AND jid is not null AND encrypted_password <> ? AND confirmed_at is not null', true, ""]).each do |user|
      begin
        @bots[user.id] = ConnectorBot.new(user)
        puts " * Connected as #{user.jid}"
      rescue Jabber::ClientAuthenticationFailure
        puts " ! Unable to authenticate as #{user.jid}"
      end
    end
    
    loop do
      @bots.each do |id, bot|
        bot.process_records!
      end
      
      sleep 5
    end
  end
end
