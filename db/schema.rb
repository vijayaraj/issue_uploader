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

ActiveRecord::Schema.define(version: 20141028074844) do

  create_table "account_configurations", force: true do |t|
    t.text     "github"
    t.text     "gitlab"
    t.string   "notification_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exported_issue_data", force: true do |t|
    t.string   "cmc_id"
    t.integer  "github_id"
    t.string   "github_title"
    t.string   "github_status"
    t.text     "github_labels"
    t.string   "github_milestones"
    t.string   "github_last_updated"
    t.integer  "gitlab_id"
    t.string   "gitlab_title"
    t.string   "gitlab_status"
    t.text     "gitlab_labels"
    t.string   "gitlab_milestones"
    t.string   "gitlab_last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", force: true do |t|
    t.string   "cmc_id"
    t.integer  "github_id"
    t.integer  "gitlab_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues-T", force: true do |t|
    t.string   "cmc_id"
    t.integer  "github_id"
    t.integer  "gitlab_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
