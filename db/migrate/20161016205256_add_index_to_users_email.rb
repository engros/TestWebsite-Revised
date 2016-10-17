class AddIndexToUsersEmail < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :email, unique: true
  end
end


#This uses a Rails method called add_index to add an index on the email column of the users table.
#The index by itself doesn’t enforce uniqueness, but the option unique: true does.
#An index prevents full scan search on database, instead index directs to a specific address on database.

