#!/usr/bin/env ruby

require 'xmpp4r/framework/bot'
require 'xmpp4r/pubsub'
require 'xmpp4r/vcard'
require 'xmpp4r/caps'

Jabber::debug = true

# class VcardCache < Jabber::Vcard::Helper
#   attr_reader :vcards
# 
#   def initialize(stream)
#     super
#     @vcards = {}
#   end
# 
#   def get(jid)
#     unless @vcards[jid]
#       begin
#         @vcards[jid] = super
#       rescue Jabber::ServerError
#         @vcards[jid] = :error
#       end
#     end
# 
#     @vcards[jid]
#   end
# 
#   def get_until(jid, timeout=10)
#     begin
#       Timeout::timeout(timeout) {
#         get(jid)
#       }
#     rescue Timeout::Error
#       @vcards[jid] = :timeout
#     end
# 
#     @vcards[jid]
#   end
# end
# 
# MAX_ITEMS = 50
# $jid_items = []

class ConnectorBot < Jabber::Framework::Bot
  include REXML
  
  def initialize(user)
    @user = user
    super(@user.jid, @user.encrypted_password)
    @vcard_helper = Jabber::Vcard::Helper.new(stream)
    add_capabilities
    set_presence(nil, "I'm busy aggregating PEP events...")
  end
  
  def accept_subscription_from?(jid)
    friend = User.find_or_create_by_jid(jid.to_s)
    
    update_user(friend)

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
    friend = User.find_or_create_by_jid(jid.to_s)
    
    update_user(friend)
    
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

    activity.save!
  end
  
  protected
  
  def update_user(user)
    vcard = @vcard_helper.get(user.jid)

    if vcard
      user.update_attributes!(
        :description => vcard['DESC'],
        :local => false, # (Jabber::JID.new(user.jid).domain == Diaspora::Application.config.server_name),
        :url => vcard['URL'],
        :email => (vcard['USERID'] or user.jid), # unknown-email-address-plz-fix@devise.me - fixme
        :phone => vcard['NUMBER'],
        :password => 'plz-fix', # fix devise validation - fixme
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
end

class Connector
  def initialize
    @bots = {}
    
    User.find(:all, :conditions => { :local => true }).each do |user|
      @bots[user.id] = ConnectorBot.new(user)
    end
    
    p = fork do
      sleep 3600 * 24 # wait 24 hours...
    end
    Process.waitpid(p)
  end
end


# $bot = Jabber::Framework::Bot.new(JID, PASSWORD)

# caps = Jabber::Caps::Helper.new($bot.client,
#   [Jabber::Discovery::Identity.new('client', nil, 'pc')],
#   [Jabber::Discovery::Feature.new('urn:xmpp:microblog:0')]
# )

# class << $bot
#   def accept_subscription_from?(jid)
#     roster.add(jid, nil, true)
#     true
#   end
# end

# $vcards = VcardCache.new($bot.stream)
# xml_namespaces('index.xsl', %w(xmlns xsl pa j p)).each { |prefix,node|
#         $bot.add_pep_notification(node) do |from,item|
#           
#           puts item.inspect
#           
#           from.strip!
#           item.add_namespace(Jabber::PubSub::NS_PUBSUB)
#           item.attributes['node'] = node
#           is_duplicate = false
#           $jid_items.each { |jid1,item1|
#             if jid1.to_s == from.to_s and node == item1.attributes['node']
#               is_duplicate = (item.to_s == item1.to_s)
#               break
#             end
#           }
#           unless is_duplicate
#             $jid_items.unshift([from, item])
#             $jid_items = $jid_items[0..(MAX_ITEMS-1)]
#           end
#         end
#       }
# 

# class WebController < Ramaze::Controller
#   map '/'
#   # template_root __DIR__
#   # engine :XSLT
# 
#   def index
#     "<?xml version='1.0' encoding='UTF-8'?>" +
#       "<items xmlns:jabber='jabber:client' jabber:to='#{Jabber::JID.new(JID).strip}'>" +
#       $jid_items.collect do |jid,item_orig|
#         item = item_orig.deep_clone
#         item.attributes['jabber:from'] = jid.to_s
#         vcard = $vcards.get_until(jid)
#         if vcard.kind_of? Jabber::Vcard::IqVcard
#           item.attributes['jabber:from-name'] = vcard['NICKNAME'] || vcard['FN'] || jid.node
#           item.attributes['jabber:has-avatar'] = (vcard['PHOTO/TYPE'] and
#                                                   vcard['PHOTO/BINVAL']) ? 'true' : 'false'
#         else
#           item.attributes['jabber:from-name'] = jid.node
#           item.attributes['jabber:has-avatar'] = 'false'
#         end
#         item
#       end.join +
#       "</items>"
#   end
# 
#   def avatar(jid)
#     trait :engine => :None
# 
#     vcard = $vcards.get_until(jid)
#     if vcard.kind_of? Jabber::Vcard::IqVcard
#       if vcard['PHOTO/TYPE'] and vcard.photo_binval
#         response['Content-Type'] = vcard['PHOTO/TYPE']
#         response.body = vcard.photo_binval
#       else
#         response['Status'] = 404
#       end
#     else
#         response['Status'] = 404
#     end
# 
#     throw :respond
#   end
# end
# 
# Ramaze::start(:port => HTTP_PORT)
