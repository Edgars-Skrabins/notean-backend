# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_09_24_150001) do
  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "team_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_active_at", null: false
    t.index ["team_id"], name: "index_memberships_on_team_id"
    t.index ["team_id"], name: "index_memberships_on_team_id_unique_owner", unique: true, where: "role = 'owner'"
    t.index ["user_id", "team_id"], name: "index_memberships_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "page_contributors", force: :cascade do |t|
    t.integer "page_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id", "user_id"], name: "index_page_contributors_on_page_id_and_user_id", unique: true
    t.index ["page_id"], name: "index_page_contributors_on_page_id"
    t.index ["user_id"], name: "index_page_contributors_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "created_by_user_id", null: false
    t.string "title", null: false
    t.text "content", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_user_id"], name: "index_pages_on_created_by_user_id"
    t.index ["team_id"], name: "index_pages_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "code"
    t.string "password"
    t.string "password_digest"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_teams_on_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
  add_foreign_key "page_contributors", "pages"
  add_foreign_key "page_contributors", "users"
  add_foreign_key "pages", "teams"
  add_foreign_key "pages", "users", column: "created_by_user_id"
end
