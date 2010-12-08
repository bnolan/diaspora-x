require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "username validation" do
    u = User.new(:username => 'x\'"', :email => 'blah@blah.com', :password => 'password')
    assert !u.save
    assert u.errors[:username].any?

    u = User.new(:username => 'johnxxx', :email => 'blah@blah.com', :password => 'password')
    assert u.save
  end

end
