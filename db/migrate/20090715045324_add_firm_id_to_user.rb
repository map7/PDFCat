class AddFirmIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :firm_id, :integer
  end

  def self.down
    remove_column :users, :firm_id
  end
end
