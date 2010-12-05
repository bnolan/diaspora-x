require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "show" do
    get :show, :id => users(:sam).to_param
    assert_template 'show'
  end
  
end
