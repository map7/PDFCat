class AddColumnPdfsMd5 < ActiveRecord::Migration
  def self.up
	  add_column :pdfs, :md5, :string
  end

  def self.down
	  remove_column :pdfs, :md5
  end
end
