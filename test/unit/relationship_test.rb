require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  test "accept" do
    relationships(:sam_ben).accept!
    
    r = relationships(:sam_ben).reload
    
    assert_equal false, r.federated?
    assert_equal true, r.accepted?
    assert Relationship.find_by_friend_id_and_user_id_and_accepted(users(:ben), users(:sam), true)
    assert Relationship.find_by_friend_id_and_user_id_and_accepted(users(:sam), users(:ben), true)
  end

  test "update_reverse!" do
    # done implicity by the other tests
  end
  
  test "mark_as_deleted" do
    relationships(:ben_rissa).mark_as_deleted!
    assert users(:rissa).relationships.empty?
  end

  test "unfederated" do
    assert_equal 1, Relationship.unfederated.length
  end
  
  test "federated!" do
    relationships(:ben_rissa).federated!
    assert_equal 0, Relationship.unfederated.length
  end
  
end
