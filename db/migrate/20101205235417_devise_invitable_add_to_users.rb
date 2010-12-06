class DeviseInvitableAddToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string   :invitation_token, :limit => 20
      t.datetime :invitation_sent_at
      t.index    :invitation_token # for invitable
    end
    
    # And allow null encrypted_password and password_salt:
    change_column :users, :encrypted_password, :string, :null => true
    change_column :users, :password_salt,      :string, :null => true
  end
  
  def self.down
    remove_column :users, :invitation_sent_at
    remove_column :users, :invitation_token
  end
end
