class AddIsValidToPdfs < ActiveRecord::Migration
  def self.up
    add_column :pdfs, :is_valid, :boolean
  end

  def self.down
    remove_column :pdfs, :is_valid
  end
end
