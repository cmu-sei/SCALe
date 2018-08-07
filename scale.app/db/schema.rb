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

ActiveRecord::Schema.define(:version => 20171220174632) do

  create_table "displays", :force => true do |t|
    t.boolean "flag"
    t.integer "verdict"
    t.integer "previous"
    t.string  "path"
    t.integer "line"
    t.string  "link"
    t.string  "message"
    t.string  "checker"
    t.string  "tool"
    t.string  "rule"
    t.string  "title"
    t.integer "severity"
    t.integer "liklihood"
    t.integer "remediation"
    t.integer "priority"
    t.integer "level"
    t.string  "cwe_likelihood"
    t.string  "notes"
    t.boolean "ignored"
    t.boolean "dead"
    t.boolean "inapplicable_environment"
    t.integer "dangerous_construct"
    t.decimal "confidence"
    t.integer "alert_priority"
    t.integer "project_id",               :default => 0
    t.integer "meta_alert_id",            :default => 0
    t.integer "diagnostic_id",            :default => 0
  end

  create_table "messages", :force => true do |t|
    t.integer "project_id"
    t.integer "diagnostic_id"
    t.string  "path"
    t.integer "line"
    t.string  "link"
    t.string  "message"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
