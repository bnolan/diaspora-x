class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :user_id, :friend_id
      t.boolean :accepted, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :relationships
  end
end
