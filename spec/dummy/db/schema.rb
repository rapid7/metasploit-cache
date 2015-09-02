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

ActiveRecord::Schema.define(version: 20150716152805) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "mc_actionable_actions", force: true do |t|
    t.string  "name",            null: false
    t.integer "actionable_id",   null: false
    t.string  "actionable_type", null: false
  end

  add_index "mc_actionable_actions", ["actionable_type", "actionable_id", "name"], name: "unique_mc_actionable_actions", unique: true, using: :btree

  create_table "mc_architecturable_architectures", force: true do |t|
    t.integer "architecturable_id",   null: false
    t.string  "architecturable_type", null: false
    t.integer "architecture_id",      null: false
  end

  add_index "mc_architecturable_architectures", ["architecturable_type", "architecturable_id", "architecture_id"], name: "unique_mc_architecturable_architectures", unique: true, using: :btree
  add_index "mc_architecturable_architectures", ["architecturable_type", "architecturable_id"], name: "mc_architecturable_architechurables", using: :btree
  add_index "mc_architecturable_architectures", ["architecture_id"], name: "index_mc_architecturable_architectures_on_architecture_id", using: :btree

  create_table "mc_architectures", force: true do |t|
    t.integer "bits"
    t.string  "abbreviation", null: false
    t.string  "endianness"
    t.string  "family"
    t.string  "summary",      null: false
  end

  add_index "mc_architectures", ["abbreviation"], name: "index_mc_architectures_on_abbreviation", unique: true, using: :btree
  add_index "mc_architectures", ["family", "bits", "endianness"], name: "index_mc_architectures_on_family_and_bits_and_endianness", unique: true, using: :btree
  add_index "mc_architectures", ["summary"], name: "index_mc_architectures_on_summary", unique: true, using: :btree

  create_table "mc_authorities", force: true do |t|
    t.string  "abbreviation",                 null: false
    t.boolean "obsolete",     default: false, null: false
    t.string  "summary"
    t.text    "url"
  end

  add_index "mc_authorities", ["abbreviation"], name: "index_mc_authorities_on_abbreviation", unique: true, using: :btree
  add_index "mc_authorities", ["summary"], name: "index_mc_authorities_on_summary", unique: true, using: :btree
  add_index "mc_authorities", ["url"], name: "index_mc_authorities_on_url", unique: true, using: :btree

  create_table "mc_authors", force: true do |t|
    t.string "name", null: false
  end

  add_index "mc_authors", ["name"], name: "index_mc_authors_on_name", unique: true, using: :btree

  create_table "mc_auxiliary_instances", force: true do |t|
    t.text    "description",        null: false
    t.date    "disclosed_on"
    t.string  "name",               null: false
    t.string  "stance",             null: false
    t.integer "auxiliary_class_id", null: false
    t.integer "default_action_id"
  end

  add_index "mc_auxiliary_instances", ["auxiliary_class_id"], name: "index_mc_auxiliary_instances_on_auxiliary_class_id", unique: true, using: :btree

  create_table "mc_contributions", force: true do |t|
    t.integer "author_id",          null: false
    t.integer "contributable_id",   null: false
    t.string  "contributable_type", null: false
    t.integer "email_address_id"
  end

  add_index "mc_contributions", ["author_id"], name: "index_mc_contributions_on_author_id", using: :btree
  add_index "mc_contributions", ["contributable_type", "contributable_id", "author_id"], name: "unique_mc_contribution_authors", unique: true, using: :btree
  add_index "mc_contributions", ["contributable_type", "contributable_id", "email_address_id"], name: "unique_mc_contribution_email_addresses", unique: true, using: :btree
  add_index "mc_contributions", ["contributable_type", "contributable_id"], name: "mc_contribution_contributables", using: :btree
  add_index "mc_contributions", ["email_address_id"], name: "index_mc_contributions_on_email_address_id", using: :btree

  create_table "mc_direct_classes", force: true do |t|
    t.integer "ancestor_id", null: false
    t.integer "rank_id",     null: false
  end

  add_index "mc_direct_classes", ["ancestor_id"], name: "unique_mc_direct_classes", unique: true, using: :btree

  create_table "mc_email_addresses", force: true do |t|
    t.string "domain", null: false
    t.string "full",   null: false
    t.string "local",  null: false
  end

  add_index "mc_email_addresses", ["domain", "local"], name: "index_mc_email_addresses_on_domain_and_local", unique: true, using: :btree
  add_index "mc_email_addresses", ["domain"], name: "index_mc_email_addresses_on_domain", using: :btree
  add_index "mc_email_addresses", ["full"], name: "index_mc_email_addresses_on_full", unique: true, using: :btree
  add_index "mc_email_addresses", ["local"], name: "index_mc_email_addresses_on_local", using: :btree

  create_table "mc_encoder_instances", force: true do |t|
    t.text    "description",      null: false
    t.string  "name",             null: false
    t.integer "encoder_class_id", null: false
  end

  add_index "mc_encoder_instances", ["encoder_class_id"], name: "index_mc_encoder_instances_on_encoder_class_id", unique: true, using: :btree

  create_table "mc_exploit_instances", force: true do |t|
    t.text    "description",               null: false
    t.date    "disclosed_on",              null: false
    t.string  "name",                      null: false
    t.boolean "privileged",                null: false
    t.string  "stance",                    null: false
    t.integer "default_exploit_target_id"
    t.integer "exploit_class_id",          null: false
  end

  add_index "mc_exploit_instances", ["default_exploit_target_id"], name: "index_mc_exploit_instances_on_default_exploit_target_id", unique: true, using: :btree
  add_index "mc_exploit_instances", ["exploit_class_id"], name: "index_mc_exploit_instances_on_exploit_class_id", unique: true, using: :btree

  create_table "mc_exploit_targets", force: true do |t|
    t.integer "index",               null: false
    t.string  "name",                null: false
    t.integer "exploit_instance_id", null: false
  end

  add_index "mc_exploit_targets", ["exploit_instance_id", "index"], name: "index_mc_exploit_targets_on_exploit_instance_id_and_index", unique: true, using: :btree
  add_index "mc_exploit_targets", ["exploit_instance_id", "name"], name: "index_mc_exploit_targets_on_exploit_instance_id_and_name", unique: true, using: :btree
  add_index "mc_exploit_targets", ["exploit_instance_id"], name: "index_mc_exploit_targets_on_exploit_instance_id", using: :btree

  create_table "mc_licensable_licenses", force: true do |t|
    t.integer  "licensable_id",   null: false
    t.string   "licensable_type", null: false
    t.integer  "license_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mc_licensable_licenses", ["licensable_type", "licensable_id", "license_id"], name: "unique_mc_licensable_licenses", unique: true, using: :btree
  add_index "mc_licensable_licenses", ["licensable_type", "licensable_id"], name: "mc_licensable_polymorphic", using: :btree
  add_index "mc_licensable_licenses", ["license_id"], name: "index_mc_licensable_licenses_on_license_id", using: :btree

  create_table "mc_licenses", force: true do |t|
    t.string "abbreviation", null: false
    t.text   "summary"
    t.string "url"
  end

  add_index "mc_licenses", ["abbreviation"], name: "index_mc_licenses_on_abbreviation", unique: true, using: :btree
  add_index "mc_licenses", ["summary"], name: "index_mc_licenses_on_summary", unique: true, using: :btree
  add_index "mc_licenses", ["url"], name: "index_mc_licenses_on_url", unique: true, using: :btree

  create_table "mc_module_ancestors", force: true do |t|
    t.string   "type"
    t.datetime "real_path_modified_at",                null: false
    t.string   "real_path_sha1_hex_digest", limit: 40, null: false
    t.text     "relative_path",                        null: false
    t.integer  "parent_path_id",                       null: false
  end

  add_index "mc_module_ancestors", ["parent_path_id"], name: "index_mc_module_ancestors_on_parent_path_id", using: :btree
  add_index "mc_module_ancestors", ["real_path_sha1_hex_digest"], name: "index_mc_module_ancestors_on_real_path_sha1_hex_digest", unique: true, using: :btree
  add_index "mc_module_ancestors", ["relative_path"], name: "index_mc_module_ancestors_on_relative_path", unique: true, using: :btree

  create_table "mc_module_paths", force: true do |t|
    t.string "gem"
    t.string "name"
    t.text   "real_path", null: false
  end

  add_index "mc_module_paths", ["gem", "name"], name: "index_mc_module_paths_on_gem_and_name", unique: true, using: :btree
  add_index "mc_module_paths", ["real_path"], name: "index_mc_module_paths_on_real_path", unique: true, using: :btree

  create_table "mc_module_ranks", force: true do |t|
    t.string  "name",   null: false
    t.integer "number", null: false
  end

  add_index "mc_module_ranks", ["name"], name: "index_mc_module_ranks_on_name", unique: true, using: :btree
  add_index "mc_module_ranks", ["number"], name: "index_mc_module_ranks_on_number", unique: true, using: :btree

  create_table "mc_nop_instances", force: true do |t|
    t.text    "description",  null: false
    t.string  "name",         null: false
    t.integer "nop_class_id", null: false
  end

  add_index "mc_nop_instances", ["nop_class_id"], name: "index_mc_nop_instances_on_nop_class_id", unique: true, using: :btree

  create_table "mc_payload_handlers", force: true do |t|
    t.string "general_handler_type", null: false
    t.string "handler_type",         null: false
    t.string "name",                 null: false
  end

  add_index "mc_payload_handlers", ["handler_type"], name: "index_mc_payload_handlers_on_handler_type", unique: true, using: :btree
  add_index "mc_payload_handlers", ["name"], name: "index_mc_payload_handlers_on_name", unique: true, using: :btree

  create_table "mc_payload_single_unhandled_instances", force: true do |t|
    t.text    "description",                       null: false
    t.string  "name",                              null: false
    t.boolean "privileged",                        null: false
    t.integer "handler_id",                        null: false
    t.integer "payload_single_unhandled_class_id", null: false
  end

  add_index "mc_payload_single_unhandled_instances", ["handler_id"], name: "index_mc_payload_single_unhandled_instances_on_handler_id", using: :btree
  add_index "mc_payload_single_unhandled_instances", ["payload_single_unhandled_class_id"], name: "unique_mc_payload_single_unhandled_instances", unique: true, using: :btree

  create_table "mc_payload_stage_instances", force: true do |t|
    t.text    "description",            null: false
    t.string  "name",                   null: false
    t.boolean "privileged",             null: false
    t.integer "payload_stage_class_id", null: false
  end

  add_index "mc_payload_stage_instances", ["payload_stage_class_id"], name: "index_mc_payload_stage_instances_on_payload_stage_class_id", unique: true, using: :btree

  create_table "mc_payload_staged_classes", force: true do |t|
    t.integer "payload_stage_instance_id",  null: false
    t.integer "payload_stager_instance_id", null: false
  end

  add_index "mc_payload_staged_classes", ["payload_stage_instance_id"], name: "index_mc_payload_staged_classes_on_payload_stage_instance_id", using: :btree
  add_index "mc_payload_staged_classes", ["payload_stager_instance_id", "payload_stage_instance_id"], name: "unique_mc_payload_staged_classes", unique: true, using: :btree
  add_index "mc_payload_staged_classes", ["payload_stager_instance_id"], name: "index_mc_payload_staged_classes_on_payload_stager_instance_id", using: :btree

  create_table "mc_payload_staged_instances", force: true do |t|
    t.integer "payload_staged_class_id", null: false
  end

  add_index "mc_payload_staged_instances", ["payload_staged_class_id"], name: "index_mc_payload_staged_instances_on_payload_staged_class_id", unique: true, using: :btree

  create_table "mc_payload_stager_instances", force: true do |t|
    t.text    "description",             null: false
    t.string  "handler_type_alias"
    t.string  "name",                    null: false
    t.boolean "privileged",              null: false
    t.integer "handler_id",              null: false
    t.integer "payload_stager_class_id", null: false
  end

  add_index "mc_payload_stager_instances", ["handler_id"], name: "index_mc_payload_stager_instances_on_handler_id", using: :btree
  add_index "mc_payload_stager_instances", ["payload_stager_class_id"], name: "index_mc_payload_stager_instances_on_payload_stager_class_id", unique: true, using: :btree

  create_table "mc_platformable_platforms", force: true do |t|
    t.integer "platformable_id",   null: false
    t.string  "platformable_type", null: false
    t.integer "platform_id",       null: false
  end

  add_index "mc_platformable_platforms", ["platform_id"], name: "index_mc_platformable_platforms_on_platform_id", using: :btree
  add_index "mc_platformable_platforms", ["platformable_type", "platformable_id", "platform_id"], name: "unique_mc_platformable_platforms", unique: true, using: :btree
  add_index "mc_platformable_platforms", ["platformable_type", "platformable_id"], name: "mc_platformable_platformables", using: :btree

  create_table "mc_platforms", force: true do |t|
    t.text    "fully_qualified_name", null: false
    t.text    "relative_name",        null: false
    t.integer "parent_id"
    t.integer "right",                null: false
    t.integer "left",                 null: false
  end

  add_index "mc_platforms", ["fully_qualified_name"], name: "index_mc_platforms_on_fully_qualified_name", unique: true, using: :btree
  add_index "mc_platforms", ["parent_id", "relative_name"], name: "index_mc_platforms_on_parent_id_and_relative_name", unique: true, using: :btree

  create_table "mc_post_instances", force: true do |t|
    t.text    "description",       null: false
    t.date    "disclosed_on"
    t.string  "name",              null: false
    t.boolean "privileged",        null: false
    t.integer "default_action_id"
    t.integer "post_class_id",     null: false
  end

  add_index "mc_post_instances", ["default_action_id"], name: "index_mc_post_instances_on_default_action_id", unique: true, using: :btree
  add_index "mc_post_instances", ["post_class_id"], name: "index_mc_post_instances_on_post_class_id", unique: true, using: :btree

  create_table "mc_referencable_references", force: true do |t|
    t.integer  "referencable_id",   null: false
    t.string   "referencable_type", null: false
    t.integer  "reference_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mc_referencable_references", ["referencable_type", "referencable_id", "reference_id"], name: "unique_mc_referencable_references", unique: true, using: :btree
  add_index "mc_referencable_references", ["referencable_type", "referencable_id"], name: "mc_referencable_polymorphic", using: :btree
  add_index "mc_referencable_references", ["reference_id"], name: "index_mc_referencable_references_on_reference_id", using: :btree

  create_table "mc_references", force: true do |t|
    t.string  "designation"
    t.text    "url"
    t.integer "authority_id"
  end

  add_index "mc_references", ["authority_id", "designation"], name: "index_mc_references_on_authority_id_and_designation", unique: true, using: :btree
  add_index "mc_references", ["url"], name: "index_mc_references_on_url", unique: true, using: :btree

end
