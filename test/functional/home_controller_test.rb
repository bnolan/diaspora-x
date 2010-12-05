require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "index" do
    sign_in :user, users(:ben)
    get :index
    assert_template 'index'
  end
  
  test "index markup" do
    sign_in :user, users(:ben)
    get :index
    
    assert_select '.friend a', /rissa/
  end
end
