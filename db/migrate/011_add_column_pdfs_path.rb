class AddColumnPdfsPath < ActiveRecord::Migration
  def self.up
	  add_column :pdfs, :path, :string
  end

  def self.down
	  remove_column :pdfs, :path
  end
end
