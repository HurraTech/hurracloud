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

ActiveRecord::Schema.define(version: 20190211224920) do

  create_table "drive_partitions", force: :cascade do |t|
    t.integer "source_id"
    t.string "uuid"
    t.integer "partitionNumber"
    t.string "deviceFile"
    t.string "label"
    t.string "filesystem"
    t.integer "size"
    t.integer "available"
    t.integer "status"
    t.text "raw"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id"], name: "index_drive_partitions_on_source_id"
  end

  create_table "google_drive_accounts", force: :cascade do |t|
    t.string "accessToken"
    t.string "googleId"
    t.integer "expires_in"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "index_segments", force: :cascade do |t|
    t.integer "index_id"
    t.integer "parent_segment_id"
    t.string "relative_path"
    t.datetime "last_run"
    t.datetime "last_run_started_at"
    t.integer "last_duration_seconds"
    t.integer "current_status"
    t.integer "actual_count"
    t.integer "total_count"
    t.integer "actual_size"
    t.integer "total_size"
    t.integer "crawler_pid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["index_id", "relative_path"], name: "index_index_segments_on_index_id_and_relative_path", unique: true
    t.index ["index_id"], name: "index_index_segments_on_index_id"
    t.index ["parent_segment_id"], name: "index_index_segments_on_parent_segment_id"
  end

  create_table "indices", force: :cascade do |t|
    t.integer "drive_partition_id"
    t.text "settings"
    t.integer "status"
    t.integer "count"
    t.integer "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drive_partition_id"], name: "index_indices_on_drive_partition_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name"
    t.integer "source_type"
    t.string "url"
    t.string "unique_id"
    t.integer "capacity", limit: 8
    t.integer "available", limit: 8
    t.text "metadata"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
