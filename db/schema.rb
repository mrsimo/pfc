# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "document_permissions", :force => true do |t|
    t.integer  "document_id",                :null => false
    t.integer  "user_id",                    :null => false
    t.integer  "permission",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "num_pages"
    t.integer  "current_page", :default => 1
    t.integer  "user_id",                     :null => false
    t.integer  "height"
    t.integer  "width"
    t.integer  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["user_id"], :name => "index_documents_on_user_id"

  create_table "elements", :force => true do |t|
    t.string   "attr",       :null => false
    t.integer  "page_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elements", ["page_id"], :name => "index_elements_on_page_id"

  create_table "group_permissions", :force => true do |t|
    t.integer  "document_id",                :null => false
    t.integer  "group_id",                   :null => false
    t.integer  "permission",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description"
    t.integer  "owner_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["owner_id"], :name => "index_groups_on_owner_id"

  create_table "pages", :force => true do |t|
    t.integer  "number",      :null => false
    t.string   "background"
    t.integer  "document_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["document_id"], :name => "index_pages_on_document_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
