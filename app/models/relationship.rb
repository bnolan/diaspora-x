class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User', :foreign_key => "friend_id"
  default_scope :conditions => {:deleted => false}
  
  validates_uniqueness_of :friend_id, :scope => :user_id
  scope :unfederated, :conditions => ['federated = ?', false]

  # attr_protected :accepted
  
  def accept!
    self.accepted = true
    self.federated = false
    save!
    update_reverse!
  end

  def mark_as_deleted!
    self.deleted = true
    self.federated = false
    save!
    update_reverse!
  end
  
  def federated!
    self.federated = true
    save!
  end

  def create_reverse!
    update_reverse!
  end
  
  protected

  def update_reverse!
    r = Relationship.find_by_user_id_and_friend_id(friend_id, user_id) || Relationship.new(:user_id => friend_id, :friend_id => user_id)
    r.accepted = accepted?
    r.federated = federated?
    r.deleted = deleted?
    r.save!
  end
  
end
