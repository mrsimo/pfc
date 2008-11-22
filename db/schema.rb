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

ActiveRecord::Schema.define(:version => 20081122123130) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id",     :limit => 11
    t.integer  "document_id", :limit => 11
    t.datetime "when"
    t.boolean  "anonymous",                 :default => false
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "permalink"
    t.text     "value"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "configurations", ["permalink"], :name => "index_configurations_on_permalink"

  create_table "document_permissions", :force => true do |t|
    t.integer  "document_id", :limit => 11,                :null => false
    t.integer  "user_id",     :limit => 11,                :null => false
    t.integer  "permission",  :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "current_page", :limit => 11, :default => 1
    t.integer  "user_id",      :limit => 11,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "height",       :limit => 11, :default => 600
    t.integer  "width",        :limit => 11, :default => 800
    t.boolean  "has_file",                   :default => false
    t.boolean  "public",                     :default => false
  end

  add_index "documents", ["user_id"], :name => "index_documents_on_user_id"

  create_table "elements", :force => true do |t|
    t.text     "attr",                     :null => false
    t.integer  "page_id",    :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elements", ["page_id"], :name => "index_elements_on_page_id"

  create_table "group_permissions", :force => true do |t|
    t.integer  "document_id", :limit => 11,                :null => false
    t.integer  "group_id",    :limit => 11,                :null => false
    t.integer  "permission",  :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",                      :default => "", :null => false
    t.text     "description"
    t.integer  "owner_id",    :limit => 11,                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["owner_id"], :name => "index_groups_on_owner_id"

  create_table "images", :force => true do |t|
    t.integer  "parent_id",    :limit => 11
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size",         :limit => 11
    t.integer  "width",        :limit => 11
    t.integer  "height",       :limit => 11
    t.integer  "page_id",      :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "target_id",  :limit => 11
    t.integer  "source_id",  :limit => 11
    t.integer  "group_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "group_id",   :limit => 11,                    :null => false
    t.integer  "user_id",    :limit => 11,                    :null => false
    t.boolean  "admin",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "number",      :limit => 11, :null => false
    t.integer  "document_id", :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cursorx",     :limit => 11
    t.integer  "cursory",     :limit => 11
    t.integer  "cursorr",     :limit => 11
  end

  add_index "pages", ["document_id"], :name => "index_pages_on_document_id"

  create_table "tasks", :force => true do |t|
    t.string   "file"
    t.string   "dir"
    t.boolean  "done",                      :default => false
    t.integer  "document_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thumbnails", :force => true do |t|
    t.integer  "parent_id",    :limit => 11
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size",         :limit => 11
    t.integer  "width",        :limit => 11
    t.integer  "height",       :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
