class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User', :foreign_key => "friend_id"
  
  validates_uniqueness_of :friend_id, :scope => :user_id

  attr_protected :accepted
  
  def accept!
    self.accepted = true
    save!
    create_reverse!
  end

  def create_reverse!
    if not Relationship.find(:first, :conditions => {:user_id => friend_id, :friend_id => user_id})
      Relationship.create!(:user_id => friend_id, :friend_id => user_id, :accepted => accepted)
    end
  end
  
end
