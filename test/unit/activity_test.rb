require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  test "replies" do
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
  end
  
  test "unfederated" do
    assert_equal 1, Activity.unfederated.length
  end
  
  test "federated!" do
    activities(:ben_reply).federated!
    assert_equal 0, Activity.unfederated.length
  end
  
end