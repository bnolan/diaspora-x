require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  test "like uniqueness" do
    Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben)
    
    assert_raises ActiveRecord::RecordInvalid do
      Activity.create! :in_reply => activities(:ben_hello), :user => users(:ben)
    end
  end
  
end