class ChangeUserToRoleRelationship < ActiveRecord::Migration
  create_table :roles_users do |t|
  	t.belongs_to :user 
  	t.belongs_to :role
  end
  add_index :roles_users, :user
  add_index :roles_users, :role
end
