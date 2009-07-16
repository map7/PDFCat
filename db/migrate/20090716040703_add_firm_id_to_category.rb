class AddFirmIdToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :firm_id, :integer
  end

  def self.down
    remove_column :categories, :firm_id
  end
end
