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

ActiveRecord::Schema.define(:version => 20130313144301) do

  create_table "contributors", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.string   "github_url"
    t.string   "avatar_url"
    t.datetime "last_contributed_at"
    t.integer  "repo_id"
    t.integer  "project_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "contributors", ["login"], :name => "index_contributors_on_login"

  create_table "git_hubs", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.string   "api_endpoint"
    t.string   "client_id"
    t.string   "client_secret"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "repo_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "projects", ["name"], :name => "index_projects_on_name"
  add_index "projects", ["repo_id"], :name => "index_projects_on_repo_id"

  create_table "repos", :force => true do |t|
    t.string   "github_name"
    t.string   "oauth_token"
    t.string   "ticket_url"
    t.string   "branch_naming_convention"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "git_hub_id"
    t.boolean  "numeric_tickets"
  end

end
