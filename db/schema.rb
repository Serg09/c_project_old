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

ActiveRecord::Schema.define(version: 20160114005357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "username",                               null: false
    t.string   "first_name",                             null: false
    t.string   "last_name",                              null: false
    t.string   "phone_number"
    t.boolean  "contactable",            default: false, null: false
    t.integer  "package_id"
  end

  add_index "authors", ["confirmation_token"], name: "index_authors_on_confirmation_token", unique: true, using: :btree
  add_index "authors", ["email"], name: "index_authors_on_email", unique: true, using: :btree
  add_index "authors", ["reset_password_token"], name: "index_authors_on_reset_password_token", unique: true, using: :btree
  add_index "authors", ["unlock_token"], name: "index_authors_on_unlock_token", unique: true, using: :btree
  add_index "authors", ["username"], name: "index_authors_on_username", unique: true, using: :btree

  create_table "inquiries", force: :cascade do |t|
    t.string   "first_name",                 null: false
    t.string   "last_name",                  null: false
    t.string   "email",                      null: false
    t.text     "body",                       null: false
    t.boolean  "archived",   default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

end
