class Activity < ActiveRecord::Base
  belongs_to :user

  scope :visible_to, lambda { |user|
    where("in_reply_to is null AND user_id in (?)", user.friends.collect(&:id).push(user.id))
  }
  
  def likes
    Activity.find(:all, :conditions => {:verb => 'like', :in_reply_to => id})
  end

  def comments
    Activity.find(:all, :conditions => {:verb => 'comment', :in_reply_to => id})
  end

  def summary
    if verb == 'post'
      "updated their status:\n\n" + content
    elsif verb == 'like'
      "liked your status update."
    end
  end
      
      
end
