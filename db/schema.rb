# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 11) do

  create_table "categories", :force => true do |t|
    t.string "name"
    t.string "description"
  end

  create_table "clients", :force => true do |t|
    t.string "name"
    t.string "email"
  end

  create_table "pdfs", :force => true do |t|
    t.date    "pdfdate"
    t.string  "pdfname"
    t.string  "filename"
    t.text    "pdfnote"
    t.integer "category_id"
    t.integer "client_id"
    t.string  "md5"
    t.string  "path"
  end

end
