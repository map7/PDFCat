class AddColumnPdfsCategoryId < ActiveRecord::Migration
  def self.up
	  add_column :pdfs, :category_id, :integer
  end

  def self.down
	  remove_column :pdfs, :category_id
  end
end
