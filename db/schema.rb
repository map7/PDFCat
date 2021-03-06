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

ActiveRecord::Schema.define(:version => 20180402235552) do

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.integer "firm_id"
    t.string  "description"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
  end

  create_table "clients", :force => true do |t|
    t.string  "name"
    t.string  "email"
    t.integer "firm_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "firms", :force => true do |t|
    t.string   "name"
    t.string   "store_dir"
    t.string   "upload_dir"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_user"
    t.string   "file_group"
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
    t.boolean "missing_flag",  :default => false
    t.integer "firm_id"
    t.integer "page_count"
    t.boolean "ocr",           :default => false
    t.string  "business_name"
    t.string  "contact"
    t.string  "description"
    t.boolean "is_valid"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.boolean  "is_admin"
    t.integer  "firm_id"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
