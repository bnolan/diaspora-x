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
    
    assert_select '.friends.requests li', /sam/
    assert_select '.friends li', /Rissa/
  end
  
end
