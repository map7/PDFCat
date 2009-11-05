class AddFileUserToFirm < ActiveRecord::Migration
  def self.up
    add_column :firms, :file_user, :string
  end

  def self.down
    remove_column :firms, :file_user
  end
end
