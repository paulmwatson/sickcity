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

ActiveRecord::Schema.define(:version => 20090429170354) do

  create_table "all_tweets", :force => true do |t|
    t.datetime "mentioned_at"
    t.string   "link"
    t.string   "exact_location"
    t.integer  "city_id"
    t.string   "mentioner"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message"
    t.integer  "source_id"
  end

  add_index "all_tweets", ["source_id"], :name => "index_mentions_on_source_id"
  add_index "all_tweets", ["source_id"], :name => "source_id_index", :unique => true

  create_table "blacklist", :force => true do |t|
    t.integer "phrase_id", :null => false
    t.string  "term",      :null => false
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",     :default => false
  end

  create_table "counts", :id => false, :force => true do |t|
    t.integer "city_id",                      :null => false
    t.date    "date",                         :null => false
    t.integer "last_found_id",                :null => false
    t.integer "count",         :default => 0, :null => false
  end

  create_table "histories", :force => true do |t|
    t.integer  "city_id"
    t.integer  "phrase_id"
    t.datetime "last_get"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mentions", :force => true do |t|
    t.datetime "mentioned_at"
    t.string   "link"
    t.string   "exact_location"
    t.integer  "phrase_id"
    t.integer  "city_id"
    t.string   "mentioner"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message"
    t.integer  "source_id"
  end

  add_index "mentions", ["source_id"], :name => "index_mentions_on_source_id"
  add_index "mentions", ["source_id"], :name => "source_id_index", :unique => true

  create_table "photos", :force => true do |t|
    t.integer  "city_id"
    t.string   "photographer"
    t.string   "url"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phrases", :force => true do |t|
    t.string   "title"
    t.string   "search"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "removed_mentions", :force => true do |t|
    t.datetime "mentioned_at"
    t.string   "link"
    t.string   "exact_location"
    t.integer  "phrase_id"
    t.integer  "city_id"
    t.string   "mentioner"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message"
    t.integer  "source_id"
  end

  add_index "removed_mentions", ["source_id"], :name => "index_removed_mentions_on_source_id", :unique => true

  create_table "stats", :primary_key => "city_id", :force => true do |t|
    t.float "quotient", :default => 0.0, :null => false
  end

  add_index "stats", ["city_id"], :name => "city_id", :unique => true

end
