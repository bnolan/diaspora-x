class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :verb, :uuid
      t.integer :user_id, :in_reply_to
      t.text :content
      t.boolean :federated, :default => false
      t.boolean :deleted, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
