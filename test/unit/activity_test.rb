require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  test "like uniqueness" do
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'like'
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    
    assert_raises ActiveRecord::RecordInvalid do
      Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'like'
    end
  end

  test "replies" do
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
  end
  
end