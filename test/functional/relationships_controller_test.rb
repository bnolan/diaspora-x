require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "accept" do
    sign_in :user, users(:ben)
    post :accept, :id => relationships(:sam_ben).id
    assert users(:ben).friends.include? users(:sam)
    assert_redirected_to root_url
  end

  test "accept fail" do
    sign_in :user, users(:sam)
    assert_raises ActiveRecord::RecordNotFound do
      post :accept, :id => relationships(:sam_ben).id
    end
  end
  
  test "create" do
    
  end
  
  test "destroy" do
    sign_in :user, users(:ben)
    post :destroy, :id => relationships(:sam_ben).id
    assert users(:sam).reload.relationships.empty?
    assert_redirected_to root_url
  end
  
end
