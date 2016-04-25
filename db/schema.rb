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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160425234901) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "administrators", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "administrators", ["email"], name: "index_administrators_on_email", unique: true, using: :btree
  add_index "administrators", ["reset_password_token"], name: "index_administrators_on_reset_password_token", unique: true, using: :btree
  add_index "administrators", ["unlock_token"], name: "index_administrators_on_unlock_token", unique: true, using: :btree

  create_table "app_settings", force: :cascade do |t|
    t.string   "name",       limit: 20,  null: false
    t.string   "value",      limit: 256, null: false
    t.string   "data_type",  limit: 20,  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "app_settings", ["name"], name: "index_app_settings_on_name", unique: true, using: :btree

  create_table "authors", force: :cascade do |t|
    t.string   "email",                             default: "",        null: false
    t.string   "encrypted_password",                default: "",        null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                   default: 0,         null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "username",                                              null: false
    t.string   "first_name",                                            null: false
    t.string   "last_name",                                             null: false
    t.string   "phone_number"
    t.boolean  "contactable",                       default: false,     null: false
    t.integer  "package_id"
    t.string   "status",                 limit: 10, default: "pending", null: false
  end

  add_index "authors", ["confirmation_token"], name: "index_authors_on_confirmation_token", unique: true, using: :btree
  add_index "authors", ["email"], name: "index_authors_on_email", unique: true, using: :btree
  add_index "authors", ["reset_password_token"], name: "index_authors_on_reset_password_token", unique: true, using: :btree
  add_index "authors", ["unlock_token"], name: "index_authors_on_unlock_token", unique: true, using: :btree
  add_index "authors", ["username"], name: "index_authors_on_username", unique: true, using: :btree

  create_table "bios", force: :cascade do |t|
    t.integer  "author_id",                      null: false
    t.text     "text",                           null: false
    t.integer  "photo_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "links"
    t.string   "status",     default: "pending", null: false
  end

  create_table "book_versions", force: :cascade do |t|
    t.integer  "book_id",                                            null: false
    t.string   "title",             limit: 255,                      null: false
    t.string   "short_description", limit: 1000,                     null: false
    t.text     "long_description"
    t.integer  "cover_image_id"
    t.integer  "sample_id"
    t.string   "status",                         default: "pending", null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "book_versions_genres", id: false, force: :cascade do |t|
    t.integer "book_version_id", null: false
    t.integer "genre_id",        null: false
  end

  add_index "book_versions_genres", ["book_version_id", "genre_id"], name: "index_book_versions_genres_on_book_version_id_and_genre_id", unique: true, using: :btree
  add_index "book_versions_genres", ["book_version_id"], name: "index_book_versions_genres_on_book_version_id", using: :btree
  add_index "book_versions_genres", ["genre_id"], name: "index_book_versions_genres_on_genre_id", using: :btree

  create_table "books", force: :cascade do |t|
    t.integer  "author_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "books", ["author_id"], name: "index_books_on_author_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.integer  "book_id"
    t.decimal  "target_amount"
    t.date     "target_date"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "state",         limit: 20, default: "unstarted", null: false
    t.boolean  "extended",                 default: false,       null: false
  end

  add_index "campaigns", ["book_id"], name: "index_campaigns_on_book_id", using: :btree

  create_table "donations", force: :cascade do |t|
    t.integer  "campaign_id",                                null: false
    t.decimal  "amount",                                     null: false
    t.string   "email",                                      null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "ip_address",  limit: 15,                     null: false
    t.string   "user_agent",                                 null: false
    t.string   "state",                  default: "pledged", null: false
  end

  add_index "donations", ["campaign_id"], name: "index_donations_on_campaign_id", using: :btree
  add_index "donations", ["email"], name: "index_donations_on_email", using: :btree

  create_table "fulfillments", force: :cascade do |t|
    t.string   "type",         limit: 50,                  null: false
    t.integer  "donation_id",                              null: false
    t.integer  "reward_id",                                null: false
    t.string   "email",        limit: 200
    t.string   "address1",     limit: 100
    t.string   "address2",     limit: 100
    t.string   "city",         limit: 100
    t.string   "state",        limit: 2
    t.string   "postal_code",  limit: 15
    t.string   "country_code", limit: 2
    t.boolean  "delivered",                default: false, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "first_name",   limit: 100,                 null: false
    t.string   "last_name",    limit: 100,                 null: false
  end

  add_index "fulfillments", ["donation_id"], name: "index_fulfillments_on_donation_id", unique: true, using: :btree
  add_index "fulfillments", ["reward_id"], name: "index_fulfillments_on_reward_id", using: :btree

  create_table "genres", force: :cascade do |t|
    t.string   "name",       limit: 50, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "genres", ["name"], name: "index_genres_on_name", unique: true, using: :btree

  create_table "house_rewards", force: :cascade do |t|
    t.string   "description",               limit: 255,                 null: false
    t.boolean  "physical_address_required",             default: false, null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "image_binaries", force: :cascade do |t|
    t.binary   "data",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.integer  "author_id",                  null: false
    t.integer  "image_binary_id",            null: false
    t.string   "hash_id",         limit: 40, null: false
    t.string   "mime_type",       limit: 20, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "images", ["author_id"], name: "index_images_on_author_id", using: :btree
  add_index "images", ["hash_id"], name: "index_images_on_hash_id", unique: true, using: :btree

  create_table "inquiries", force: :cascade do |t|
    t.string   "first_name",                 null: false
    t.string   "last_name",                  null: false
    t.string   "email",                      null: false
    t.text     "body",                       null: false
    t.boolean  "archived",   default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.integer  "payment_id",            null: false
    t.string   "intent",     limit: 20, null: false
    t.string   "state",      limit: 20, null: false
    t.text     "response",              null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "donation_id", null: false
    t.string   "external_id", null: false
    t.string   "state",       null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "payments", ["donation_id"], name: "index_payments_on_donation_id", using: :btree
  add_index "payments", ["external_id"], name: "index_payments_on_external_id", unique: true, using: :btree

  create_table "rewards", force: :cascade do |t|
    t.integer  "campaign_id",                                           null: false
    t.string   "description",               limit: 100,                 null: false
    t.text     "long_description"
    t.decimal  "minimum_donation",                                      null: false
    t.boolean  "physical_address_required",             default: false, null: false
    t.integer  "house_reward_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "rewards", ["campaign_id", "description"], name: "index_rewards_on_campaign_id_and_description", unique: true, using: :btree
  add_index "rewards", ["house_reward_id"], name: "index_rewards_on_house_reward_id", using: :btree

end
