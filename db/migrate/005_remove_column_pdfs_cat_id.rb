class RemoveColumnPdfsCatId < ActiveRecord::Migration
  def self.up
#	  remove_column :pdfs, :cat_id
  end

  def self.down
#	  add_column :pdfs, :cat_id, :integer
  end
end
