class AddColumnPdfsClientId < ActiveRecord::Migration
  def self.up
	  add_column :pdfs, :client_id, :integer
  end

  def self.down
	  remove_column :pdfs, :client_id
  end
end
