require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "destroy" do
    sign_in :user, users(:ben)
    a = Activity.count
    post :destroy, :id => activities(:ben_hello).id
    assert_equal a-1, Activity.count
    assert_redirected_to root_url
  end

  test "destroy wrong" do
    sign_in :user, users(:rissa)
    a = Activity.count
    assert_raises ActiveRecord::RecordNotFound do
      post :destroy, :id => activities(:ben_hello).id
    end
    assert_equal a, Activity.count
  end
  
  test "create" do
    sign_in :user, users(:ben)
    post :create, :activity => {:verb => "post", :content => "ZING!"}
    assert_equal 2, users(:ben).activities.wall_posts.length
    assert_redirected_to root_url
  end
  
  test "create reply" do
    sign_in :user, users(:ben)
    post :create, :activity => {:verb => "post", :content => "ha ha ha!", :in_reply_to => activities(:ben_hello).id}
    assert_equal 1, users(:ben).activities.wall_posts.length
    assert_equal 2, activities(:ben_hello).replies.length
    assert_redirected_to root_url
  end
  
  test "like and unlike" do
    sign_in :user, users(:rissa)
    post :like, :id => activities(:ben_hello).id
    assert_equal 1, activities(:ben_hello).likes.length
    assert_redirected_to root_url

    post :unlike, :id => activities(:ben_hello).id
    assert_equal 0, activities(:ben_hello).likes.length
    assert_redirected_to root_url
  end

end
