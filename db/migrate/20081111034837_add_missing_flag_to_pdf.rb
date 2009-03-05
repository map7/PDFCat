class AddMissingFlagToPdf < ActiveRecord::Migration
  def self.up
    add_column :pdfs, :missing_flag, :boolean
  end

  def self.down
    remove_column :pdfs, :missing_flag
  end
end
