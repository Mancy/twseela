# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130314125720) do

  create_table "accounts", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "image"
    t.string   "provider_token"
    t.string   "provider_secret"
    t.integer  "user_id"
    t.boolean  "default_account", :default => false
    t.datetime "last_update"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "node_id"
  end

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "blocks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "blocked_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_profiles", :force => true do |t|
    t.string   "number"
    t.string   "color"
    t.date     "make_date"
    t.string   "model_name"
    t.integer  "cars_make_id"
    t.integer  "user_id"
    t.integer  "gasoline_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cars_makes", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ar"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string   "name_ar"
    t.string   "name_en"
    t.float    "lng"
    t.float    "lat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.datetime "start_time"
    t.float    "start_lng"
    t.float    "start_lat"
    t.string   "page_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flags", :force => true do |t|
    t.string   "flag"
    t.string   "comment"
    t.integer  "level"
    t.integer  "flaggable_id"
    t.string   "flaggable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gasoline_types", :force => true do |t|
    t.string   "name_ar"
    t.string   "name_en"
    t.float    "price",      :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "small_image_url"
    t.string   "image_url"
    t.boolean  "is_free",         :default => false
  end

  create_table "groups_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "subject"
    t.string   "body",         :limit => 1024
    t.boolean  "checked",                      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "money_transactions", :force => true do |t|
    t.integer  "user_id"
    t.float    "credit"
    t.float    "debit"
    t.string   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "transactable_id"
    t.string   "transactable_type"
    t.integer  "money_transaction_type_id"
  end

  create_table "newsletters", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.string   "notification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.float    "amount",         :default => 0.0
    t.integer  "payment_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
    t.string   "token"
    t.string   "session_id"
    t.string   "transaction_id"
  end

  create_table "rates", :force => true do |t|
    t.integer  "rate"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", :force => true do |t|
    t.datetime "start_time_from"
    t.datetime "start_time_to"
    t.integer  "cost_type"
    t.boolean  "air_cond"
    t.boolean  "cassette"
    t.boolean  "smoking"
    t.boolean  "return_back"
    t.string   "start_place"
    t.float    "start_lng"
    t.float    "start_lat"
    t.string   "road_path"
    t.string   "search_name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gender"
  end

  create_table "searches_paths", :force => true do |t|
    t.string   "start_place"
    t.float    "start_lng"
    t.float    "start_lat"
    t.integer  "search_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transports", :force => true do |t|
    t.datetime "start_time"
    t.datetime "return_back_start_time"
    t.integer  "allowed_persons",        :default => 1
    t.integer  "available_persons",      :default => 1
    t.integer  "cost_type"
    t.float    "cost",                   :default => 0.0
    t.boolean  "air_cond",               :default => false
    t.boolean  "cassette",               :default => false
    t.boolean  "smoking",                :default => false
    t.boolean  "return_back",            :default => false
    t.integer  "user_id"
    t.integer  "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flags_count",            :default => 0
    t.integer  "car_profile_id"
    t.integer  "rates_count",            :default => 0
    t.string   "title"
    t.boolean  "templ_saved"
    t.integer  "mileage",                :default => 0
    t.string   "start_place",            :default => ""
    t.string   "end_place",              :default => ""
  end

  create_table "transports_paths", :force => true do |t|
    t.string   "start_place"
    t.float    "start_lng"
    t.float    "start_lat"
    t.string   "road_path"
    t.boolean  "return_back",  :default => false
    t.integer  "transport_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transports_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "transport_id"
    t.integer  "for_persons"
    t.integer  "status"
    t.integer  "money_back"
    t.string   "requester_message"
    t.string   "requester_meet_place"
    t.float    "requester_meet_lng"
    t.float    "requester_meet_lat"
    t.boolean  "requester_return_back",             :default => false
    t.string   "requester_return_back_meet_place"
    t.float    "requester_return_back_meet_lng"
    t.float    "requester_return_back_meet_lat"
    t.integer  "requester_notify_type"
    t.float    "requester_cost"
    t.string   "transporter_message"
    t.datetime "transporter_meet_time"
    t.datetime "transporter_return_back_meet_time"
    t.integer  "transporter_notify_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flags_count",                       :default => 0
    t.integer  "rates_count",                       :default => 0
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.integer  "gender"
    t.string   "email"
    t.string   "mobile"
    t.boolean  "has_car"
    t.integer  "trust_level",                  :default => 1
    t.date     "birthdate"
    t.float    "credits",                      :default => 0.0
    t.string   "default_locale",               :default => "ar"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flags_weight",                 :default => 0
    t.integer  "rates_weight",                 :default => 0
    t.integer  "blocked_weight",               :default => 0
    t.datetime "last_login"
    t.datetime "before_last_login"
    t.integer  "city_id"
    t.float    "reserved_credits",             :default => 0.0
    t.integer  "mileage_sum",                  :default => 0
    t.float    "init_credits",                 :default => 0.0
    t.integer  "last_friends_count",           :default => 0
    t.integer  "last_transports_count",        :default => 0
    t.boolean  "transports_notifications",     :default => true
    t.boolean  "new_transports_notifications", :default => true
    t.boolean  "friends_notifications",        :default => true
    t.boolean  "newsletter_notifications",     :default => true
    t.integer  "friends_type",                 :default => 1
    t.boolean  "is_free",                      :default => false
  end

  create_table "users_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "requester_id"
    t.integer  "requestable_id"
    t.string   "requestable_type"
    t.string   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
