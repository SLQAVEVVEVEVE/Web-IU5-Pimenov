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

ActiveRecord::Schema[8.0].define(version: 2025_10_20_161444) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "beam_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "material", null: false
    t.integer "elasticity_gpa", null: false
    t.string "norm", null: false
    t.string "image_key"
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived"], name: "index_beam_types_on_archived"
    t.index ["name"], name: "index_beam_types_on_name"
  end

  create_table "load_forecasts", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.integer "requester_id", null: false
    t.integer "engineer_id"
    t.datetime "formed_at"
    t.datetime "completed_at"
    t.decimal "length_m", precision: 10, scale: 3
    t.decimal "load_kN_m", precision: 10, scale: 3
    t.decimal "result_mm", precision: 10, scale: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "moderator_id"
    t.index ["moderator_id"], name: "idx_load_forecasts_moderator_id"
    t.index ["requester_id"], name: "idx_load_forecasts_one_draft_per_user", unique: true, where: "(status = 0)"
    t.index ["requester_id"], name: "index_load_forecasts_on_requester_id"
  end

  create_table "load_forecasts_beam_types", force: :cascade do |t|
    t.bigint "load_forecast_id", null: false
    t.bigint "beam_type_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "position", null: false
    t.boolean "primary", default: false, null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "length_m", precision: 6, scale: 2, default: "3.0", null: false
    t.decimal "load_kn_m", precision: 6, scale: 2, default: "10.0", null: false
    t.datetime "deleted_at", precision: nil
    t.index ["beam_type_id"], name: "index_load_forecasts_beam_types_on_beam_type_id"
    t.index ["deleted_at"], name: "index_load_forecasts_beam_types_on_deleted_at"
    t.index ["load_forecast_id", "beam_type_id", "length_m", "load_kn_m"], name: "idx_lfbt_unique", unique: true
    t.index ["load_forecast_id"], name: "index_load_forecasts_beam_types_on_load_forecast_id"
    t.check_constraint "quantity > 0 AND \"position\" > 0", name: "chk_lfbt_quantity_position_pos"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "is_moderator", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "idx_users_email_unique", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "load_forecasts", "users", column: "moderator_id"
  add_foreign_key "load_forecasts", "users", column: "requester_id"
  add_foreign_key "load_forecasts_beam_types", "beam_types", on_delete: :restrict
  add_foreign_key "load_forecasts_beam_types", "load_forecasts", on_delete: :restrict
end
