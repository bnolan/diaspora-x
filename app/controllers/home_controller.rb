class HomeController < ApplicationController
  
  def index
    @relationships = current_user.relationships
    @friend_requests = current_user.friend_requests
    @activities = Activity.visible_to(current_user).order('created_at desc')
  end
  
end
