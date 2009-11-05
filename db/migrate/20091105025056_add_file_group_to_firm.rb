class AddFileGroupToFirm < ActiveRecord::Migration
  def self.up
    add_column :firms, :file_group, :string
  end

  def self.down
    remove_column :firms, :file_group
  end
end
