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

ActiveRecord::Schema.define(version: 20170220075000) do

  create_table "categories", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",                                                  null: false
    t.integer  "commentable_id",                                           null: false
    t.text     "comment",          limit: 2147483647,                      null: false
    t.datetime "created_at",                                               null: false
    t.datetime "modified_at"
    t.string   "commentable_type",                    default: "Slide"
    t.string   "role",                                default: "comments"
    t.index ["commentable_id"], name: "idx_comments_slide_id_key"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["user_id"], name: "idx_comments_user_id_key"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                           null: false
    t.text     "value",      limit: 2147483647
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "slides", force: :cascade do |t|
    t.integer  "user_id",                                           null: false
    t.string   "name",           limit: 255,                        null: false
    t.text     "description",    limit: 2147483647,                 null: false
    t.boolean  "downloadable",                      default: false, null: false
    t.integer  "category_id",                                       null: false
    t.datetime "created_at",                                        null: false
    t.datetime "modified_at"
    t.string   "object_key",     limit: 255,        default: ""
    t.string   "extension",      limit: 10,         default: "",    null: false
    t.integer  "convert_status",                    default: 0
    t.integer  "total_view",                        default: 0,     null: false
    t.integer  "page_view",                         default: 0
    t.integer  "download_count",                    default: 0,     null: false
    t.integer  "embedded_view",                     default: 0,     null: false
    t.integer  "num_of_pages",                      default: 0
    t.integer  "comments_count",                    default: 0,     null: false
    t.index ["category_id"], name: "idx_slides_category_id_key"
    t.index ["object_key"], name: "index_slides_on_object_key", unique: true
    t.index ["page_view"], name: "idx_slides_page_view_key"
    t.index ["user_id"], name: "idx_slides_user_id_key"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 32,                         null: false
    t.string   "display_name",           limit: 128,                        null: false
    t.string   "password",               limit: 255,        default: "",    null: false
    t.boolean  "admin",                                     default: false, null: false
    t.boolean  "disabled",                                  default: false
    t.datetime "created_at",                                                null: false
    t.datetime "modified_at"
    t.text     "biography",              limit: 2147483647
    t.integer  "slides_count",                              default: 0
    t.string   "encrypted_password",                        default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "username",                                                  null: false
    t.index ["email"], name: "idx_username_ukey", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
