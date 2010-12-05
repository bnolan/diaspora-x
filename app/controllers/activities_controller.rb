class ActivitiesController < ApplicationController
  
  def create
    activity = current_user.activities.create! params[:activity]
    redirect_to :back
  end
  
  def like
    @activity = Activity.find(params[:id])
    activity = current_user.activities.create!(:in_reply => @activity, :verb => 'like')
    redirect_to root_url
  end

  def unlike
    current_user.activities.find(:first, :conditions => {:in_reply_to => params[:id], :verb => 'like'}).mark_as_deleted!
    redirect_to root_url
  end


end
