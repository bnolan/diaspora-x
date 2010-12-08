class Activity < ActiveRecord::Base
  belongs_to :user
  default_scope :conditions => {:deleted => false}
  belongs_to :in_reply, :class_name => 'Activity', :foreign_key => :in_reply_to
  has_many :replies, :class_name => 'Activity', :foreign_key => :in_reply_to

  scope :visible_to, lambda { |user|
    where("in_reply_to is null AND user_id in (?)", user.friends.collect(&:id).push(user.id))
  }
  scope :unfederated, :conditions => ['federated = ?', false]

  scope :wall_posts, :conditions => 'in_reply_to is null'
  
  # validates_uniqueness_of :user_id, :scope => [:in_reply_to, :verb, :deleted], :if => Proc.new { |activity| activity.verb == 'like' }
  
  def likes
    Activity.find(:all, :conditions => {:verb => 'like', :in_reply_to => id})
  end

  def comments
    Activity.find(:all, :conditions => {:verb => 'comment', :in_reply_to => id})
  end

  # def summary
  #   if verb == 'post'
  #     "updated their status:\n\n" + content
  #   elsif verb == 'like'
  #     "liked your status update."
  #   end
  # end

  def mark_as_deleted!
    self.deleted = true
    self.federated = false
    save!
  end

  def federated!
    self.federated = true
    save!
  end
  
end
