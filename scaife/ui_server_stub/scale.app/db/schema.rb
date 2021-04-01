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

ActiveRecord::Schema.define(version: 2021_01_29_183901) do

  create_table "checkers", force: :cascade do |t|
    t.string "name"
    t.integer "tool_id"
    t.boolean "regex"
    t.string "scaife_checker_id"
  end

  create_table "classifier_metrics", force: :cascade do |t|
    t.integer "project_id"
    t.string "scaife_classifier_instance_id"
    t.datetime "transaction_timestamp"
    t.integer "num_labeled_meta_alerts_used_for_classifier_evaluation"
    t.float "test_accuracy"
    t.float "test_precision"
    t.float "test_recall"
    t.float "test_f1"
    t.integer "num_labeled_meta_alerts_used_for_classifier_training"
    t.integer "num_labeled_T_test_suite_used_for_classifier_training"
    t.integer "num_labeled_F_test_suite_used_for_classifier_training"
    t.integer "num_labeled_T_manual_verdicts_used_for_classifier_training"
    t.integer "num_labeled_F_manual_verdicts_used_for_classifier_training"
    t.integer "num_code_metrics_tools_used_for_classifier_training"
    t.text "top_features_impacting_classifier"
    t.float "train_accuracy"
    t.float "train_precision"
    t.float "train_recall"
    t.float "train_f1"
  end

  create_table "classifier_schemes", force: :cascade do |t|
    t.string "classifier_instance_name"
    t.string "classifier_type"
    t.text "source_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "adaptive_heuristic_name"
    t.text "adaptive_heuristic_parameters"
    t.text "ahpo_name"
    t.text "ahpo_parameters"
    t.string "scaife_classifier_id"
    t.string "scaife_classifier_instance_id"
    t.string "feature_category"
    t.boolean "semantic_features"
    t.boolean "use_pca"
    t.integer "num_meta_alert_threshold"
    t.index ["classifier_instance_name"], name: "index_classifier_schemes_on_classifier_instance_name", unique: true
  end

  create_table "condition_checker_links", id: false, force: :cascade do |t|
    t.integer "condition_id", null: false
    t.integer "checker_id", null: false
    t.index ["checker_id", "condition_id"], name: "index_condition_checker_links_on_checker_id_and_condition_id"
    t.index ["condition_id", "checker_id"], name: "index_condition_checker_links_on_condition_id_and_checker_id"
  end

  create_table "conditions", force: :cascade do |t|
    t.integer "taxonomy_id"
    t.string "name"
    t.string "title"
    t.string "formatted_data"
    t.string "scaife_cond_id"
  end

  create_table "determinations", force: :cascade do |t|
    t.integer "project_id"
    t.integer "meta_alert_id"
    t.datetime "time"
    t.integer "verdict"
    t.boolean "flag"
    t.string "notes"
    t.boolean "ignored"
    t.boolean "dead"
    t.boolean "inapplicable_environment"
    t.string "dangerous_construct"
    t.index ["meta_alert_id", "project_id"], name: "idx_metaid_projectid"
  end

  create_table "displays", force: :cascade do |t|
    t.boolean "flag"
    t.integer "verdict"
    t.integer "previous"
    t.string "path"
    t.integer "line"
    t.string "link"
    t.string "message"
    t.string "checker"
    t.string "tool"
    t.string "condition"
    t.string "title"
    t.integer "severity"
    t.integer "likelihood"
    t.integer "remediation"
    t.integer "priority"
    t.integer "level"
    t.string "cwe_likelihood"
    t.string "notes"
    t.boolean "ignored"
    t.boolean "dead"
    t.boolean "inapplicable_environment"
    t.integer "dangerous_construct"
    t.decimal "confidence"
    t.integer "meta_alert_priority"
    t.datetime "time"
    t.integer "project_id", default: 0
    t.integer "meta_alert_id", default: 0
    t.integer "alert_id", default: 0
    t.string "scaife_alert_id"
    t.string "scaife_meta_alert_id"
    t.integer "taxonomy_id"
    t.string "taxonomy"
    t.string "taxonomy_version"
    t.integer "tool_id"
    t.string "tool_version"
    t.string "code_language"
    t.decimal "next_confidence"
    t.string "class_label"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.string "platform"
    t.string "version"
    t.string "scaife_language_id"
    t.index ["name", "version"], name: "index_languages_on_name_and_version", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.integer "project_id"
    t.integer "alert_id"
    t.string "path"
    t.integer "line"
    t.string "link"
    t.string "message"
  end

  create_table "performance_metrics", force: :cascade do |t|
    t.string "scaife_mode"
    t.string "function_name"
    t.string "metric_description"
    t.datetime "transaction_timestamp"
    t.string "user_id"
    t.string "user_organization_id"
    t.integer "project_id"
    t.float "elapsed_time"
    t.float "cpu_time"
  end

  create_table "priority_schemes", force: :cascade do |t|
    t.string "name"
    t.integer "project_id"
    t.text "formula"
    t.text "weighted_columns"
    t.decimal "confidence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cert_severity"
    t.integer "cert_likelihood"
    t.integer "cert_remediation"
    t.integer "cert_priority"
    t.integer "cert_level"
    t.integer "cwe_likelihood"
    t.string "scaife_p_scheme_id"
    t.string "p_scheme_type"
    t.index ["name"], name: "index_priority_schemes_on_name", unique: true
  end

  create_table "project_languages", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "language_id", null: false
    t.index ["language_id", "project_id"], name: "index_project_languages_on_language_id_and_project_id", unique: true
    t.index ["project_id", "language_id"], name: "index_project_languages_on_project_id_and_language_id", unique: true
  end

  create_table "project_taxonomies", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "taxonomy_id", null: false
    t.index ["project_id", "taxonomy_id"], name: "index_project_taxonomies_on_project_id_and_taxonomy_id", unique: true
    t.index ["taxonomy_id", "project_id"], name: "index_project_taxonomies_on_taxonomy_id_and_project_id", unique: true
  end

  create_table "project_tools", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "tool_id", null: false
    t.index ["project_id", "tool_id"], name: "index_project_tools_on_project_id_and_tool_id", unique: true
    t.index ["tool_id", "project_id"], name: "index_project_tools_on_tool_id_and_project_id", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "version"
    t.integer "last_used_confidence_scheme"
    t.integer "last_used_priority_scheme"
    t.string "current_classifier_scheme"
    t.string "source_url"
    t.string "test_suite_version"
    t.string "manifest_file"
    t.string "manifest_url"
    t.string "function_info_file"
    t.string "file_info_file"
    t.string "scaife_project_id"
    t.string "scaife_package_id"
    t.string "project_data_source"
    t.datetime "scaife_uploaded_on"
    t.boolean "publish_data_updates", default: false
    t.string "test_suite_name"
    t.string "author_source"
    t.string "source_file"
    t.string "license_file"
    t.integer "test_suite_sard_id"
    t.string "scaife_test_suite_id"
    t.string "test_suite_type"
    t.boolean "subscribe_to_data_updates", default: false
    t.string "data_subscription_id"
    t.integer "confidence_lock"
  end

  create_table "taxonomies", force: :cascade do |t|
    t.string "name"
    t.string "version_string"
    t.float "version_number"
    t.text "type"
    t.text "author_source"
    t.text "user_id"
    t.text "user_org_id"
    t.text "format"
    t.string "scaife_tax_id"
  end

  create_table "tools", force: :cascade do |t|
    t.string "name"
    t.string "platform"
    t.string "version"
    t.string "label"
    t.string "scaife_tool_id"
    t.index ["name", "platform", "version"], name: "index_tools_on_name_and_platform_and_version", unique: true
  end

  create_table "user_uploads", force: :cascade do |t|
    t.integer "meta_alert_id"
    t.text "user_columns"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
