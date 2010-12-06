require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  test "replies" do
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben), :verb => 'post', :content => "Blah blah blah!"
  end
  
end