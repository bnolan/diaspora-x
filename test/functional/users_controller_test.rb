require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "show" do
    sign_in :user, users(:rissa)
    get :show, :id => users(:ben).to_param
    assert_template 'show'
    assert_equal 1, assigns(:activities).length
  end
  
end
