class UsersController < ApplicationController
  
  def show
    @user = User.find params[:id]
    @activities = @user.activities.visible_to(current_user)
  end
  
end
