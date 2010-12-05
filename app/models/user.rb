class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  validates_uniqueness_of :username
  
  has_many :activities
  has_many :relationships
  has_many :friends, :through => :relationships

  # def friends
  #   [
  #     Relationship.find(:all, :conditions => ["user_id=? and accepted = ?", id, true]).collect(&:friend),
  #     Relationship.find(:all, :conditions => ["friend_id=? and accepted = ?", id, true]).collect(&:user)
  #   ].flatten.uniq - [self]
  # end

  def username=(x)
    self.jid = "#{x}@#{Diaspora::Application.config.server_name}"
    super
  end
  
  def friend_requests
    Relationship.where(:friend_id => id, :accepted => false)
  end
  
  # end:conditions => {:}
  
  def gravatar
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest email}"
  end

  def name
    attributes[:name] or jid.sub(/@.+/,'').capitalize
  end

  def status
    if activities.any? and activities.first.content.present?
      activities.first.content.downcase
    else
      nil
    end
  end
  
  # @activities = Activity.find(:all, :order => 'created_at desc', :conditions => {:in_reply_to => nil, :type => 'status'}, :limit => 50)
end
