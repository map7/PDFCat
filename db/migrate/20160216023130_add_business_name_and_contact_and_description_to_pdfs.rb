class AddBusinessNameAndContactAndDescriptionToPdfs < ActiveRecord::Migration
  def self.up
    add_column :pdfs, :business_name, :string
    add_column :pdfs, :contact, :string
    add_column :pdfs, :description, :string
  end

  def self.down
    remove_column :pdfs, :description
    remove_column :pdfs, :contact
    remove_column :pdfs, :business_name
  end
end
