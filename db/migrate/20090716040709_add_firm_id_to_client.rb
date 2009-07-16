class AddFirmIdToClient < ActiveRecord::Migration
  def self.up
    add_column :clients, :firm_id, :integer
  end

  def self.down
    remove_column :clients, :firm_id
  end
end
