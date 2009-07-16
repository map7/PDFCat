class AddFirmIdToPdf < ActiveRecord::Migration
  def self.up
    add_column :pdfs, :firm_id, :integer
  end

  def self.down
    remove_column :pdfs, :firm_id
  end
end
