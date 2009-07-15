class CreateFirms < ActiveRecord::Migration
  def self.up
    create_table :firms do |t|
      t.string :name
      t.string :store_dir
      t.string :upload_dir

      t.timestamps
    end
  end

  def self.down
    drop_table :firms
  end
end
