class ActivitiesController < ApplicationController

  def destroy
    activity = current_user.activities.find params[:id]
    activity.mark_as_deleted!
    redirect_to root_url
  end
  
  def create
    activity = current_user.activities.create! params[:activity]
    redirect_to root_url
  end
  
  def like
    @activity = Activity.find(params[:id])
    if @activity.replies.find_by_verb_and_user_id('like', current_user.id)
      flash[:message] = "You already like this."
    else
      activity = current_user.activities.create!(:in_reply => @activity, :verb => 'like')
    end
    redirect_to root_url
  end

  def unlike
    current_user.activities.find(:first, :conditions => {:in_reply_to => params[:id], :verb => 'like'}).mark_as_deleted!
    redirect_to root_url
  end


end
