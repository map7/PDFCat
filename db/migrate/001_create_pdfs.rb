class CreatePdfs < ActiveRecord::Migration
  def self.up
    create_table :pdfs do |t|
		t.column :pdfdate,	:date
		t.column :pdfname,	:string
		t.column :filename, :string
		t.column :pdfnote,	:text
    end
  end

  def self.down
    drop_table :pdfs
  end
end
