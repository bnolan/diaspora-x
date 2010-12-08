class RelationshipsController < ApplicationController
  
  def accept
    r = Relationship.find_by_friend_id_and_id(current_user.id, params[:id]) or raise(ActiveRecord::RecordNotFound)
    r.accept!
    
    flash[:message] = "Yay. You are now friends with #{r.user.jid}"
    
    redirect_to root_url
  end
  
  def destroy
    r = Relationship.find(:first, :conditions => ["(user_id = ? or friend_id = ?) and id = ?", current_user.id, current_user.id, params[:id]])
    
    if r.accepted?
      flash[:message] = "Your friendship was deleted"
    else
      flash[:message] = "The friend request was rejected"
    end
    
    r.mark_as_deleted!
    
    redirect_to root_url
  end

  def create
    if user = User.find_by_email(params[:friend][:email]) || User.find_by_jid(params[:friend][:email])
      relationship = current_user.relationships.build(:friend => user)
      relationship.save
    else
      user = User.new(:email => params[:friend][:email], :jid => params[:friend][:email])
      user.skip_confirmation!
      user.save(:validate => false)
      
      relationship = current_user.relationships.build(:friend => user)
      relationship.save

      user.invite!
    end

    flash[:message] = "Friend request sent to #{user.name}. We'll let you know if they accept."

    redirect_to root_url
  end
  
end
