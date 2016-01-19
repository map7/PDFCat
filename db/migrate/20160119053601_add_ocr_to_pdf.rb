class AddOcrToPdf < ActiveRecord::Migration
  def self.up
    add_column :pdfs, :ocr, :boolean, default: false
  end

  def self.down
    remove_column :pdfs, :ocr
  end
end
