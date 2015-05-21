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

ActiveRecord::Schema.define(:version => 20150518163003) do

  create_table "mc_actionable_actions", :force => true do |t|
    t.string  "name",            :null => false
    t.integer "actionable_id",   :null => false
    t.string  "actionable_type", :null => false
  end

  add_index "mc_actionable_actions", ["actionable_type", "actionable_id", "name"], :name => "unique_mc_actionable_actions", :unique => true

  create_table "mc_architectures", :force => true do |t|
    t.integer "bits"
    t.string  "abbreviation", :null => false
    t.string  "endianness"
    t.string  "family"
    t.string  "summary",      :null => false
  end

  add_index "mc_architectures", ["abbreviation"], :name => "index_mc_architectures_on_abbreviation", :unique => true
  add_index "mc_architectures", ["family", "bits", "endianness"], :name => "index_mc_architectures_on_family_and_bits_and_endianness", :unique => true
  add_index "mc_architectures", ["summary"], :name => "index_mc_architectures_on_summary", :unique => true

  create_table "mc_authorities", :force => true do |t|
    t.string  "abbreviation",                    :null => false
    t.boolean "obsolete",     :default => false, :null => false
    t.string  "summary"
    t.text    "url"
  end

  add_index "mc_authorities", ["abbreviation"], :name => "index_mc_authorities_on_abbreviation", :unique => true
  add_index "mc_authorities", ["summary"], :name => "index_mc_authorities_on_summary", :unique => true
  add_index "mc_authorities", ["url"], :name => "index_mc_authorities_on_url", :unique => true

  create_table "mc_authors", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "mc_authors", ["name"], :name => "index_mc_authors_on_name", :unique => true

  create_table "mc_auxiliary_instances", :force => true do |t|
    t.text    "description",        :null => false
    t.date    "disclosed_on"
    t.string  "name",               :null => false
    t.string  "stance",             :null => false
    t.integer "auxiliary_class_id", :null => false
    t.integer "default_action_id"
  end

  add_index "mc_auxiliary_instances", ["auxiliary_class_id"], :name => "index_mc_auxiliary_instances_on_auxiliary_class_id", :unique => true

  create_table "mc_direct_classes", :force => true do |t|
    t.integer "ancestor_id", :null => false
    t.integer "rank_id",     :null => false
  end

  add_index "mc_direct_classes", ["ancestor_id"], :name => "unique_mc_direct_classes", :unique => true

  create_table "mc_email_addresses", :force => true do |t|
    t.string "domain", :null => false
    t.string "full",   :null => false
    t.string "local",  :null => false
  end

  add_index "mc_email_addresses", ["domain", "local"], :name => "index_mc_email_addresses_on_domain_and_local", :unique => true
  add_index "mc_email_addresses", ["domain"], :name => "index_mc_email_addresses_on_domain"
  add_index "mc_email_addresses", ["full"], :name => "index_mc_email_addresses_on_full", :unique => true
  add_index "mc_email_addresses", ["local"], :name => "index_mc_email_addresses_on_local"

  create_table "mc_encoder_instances", :force => true do |t|
    t.text    "description",      :null => false
    t.string  "name",             :null => false
    t.integer "encoder_class_id", :null => false
  end

  add_index "mc_encoder_instances", ["encoder_class_id"], :name => "index_mc_encoder_instances_on_encoder_class_id", :unique => true

  create_table "mc_exploit_instances", :force => true do |t|
    t.text    "description",               :null => false
    t.date    "disclosed_on",              :null => false
    t.string  "name",                      :null => false
    t.boolean "privileged",                :null => false
    t.string  "stance",                    :null => false
    t.integer "default_exploit_target_id"
    t.integer "exploit_class_id",          :null => false
  end

  add_index "mc_exploit_instances", ["default_exploit_target_id"], :name => "index_mc_exploit_instances_on_default_exploit_target_id", :unique => true
  add_index "mc_exploit_instances", ["exploit_class_id"], :name => "index_mc_exploit_instances_on_exploit_class_id", :unique => true

  create_table "mc_exploit_targets", :force => true do |t|
    t.integer "index",               :null => false
    t.string  "name",                :null => false
    t.integer "exploit_instance_id", :null => false
  end

  add_index "mc_exploit_targets", ["exploit_instance_id", "index"], :name => "index_mc_exploit_targets_on_exploit_instance_id_and_index", :unique => true
  add_index "mc_exploit_targets", ["exploit_instance_id", "name"], :name => "index_mc_exploit_targets_on_exploit_instance_id_and_name", :unique => true
  add_index "mc_exploit_targets", ["exploit_instance_id"], :name => "index_mc_exploit_targets_on_exploit_instance_id"

  create_table "mc_licensable_licenses", :force => true do |t|
    t.integer  "licensable_id",   :null => false
    t.string   "licensable_type", :null => false
    t.integer  "license_id",      :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "mc_licensable_licenses", ["licensable_type", "licensable_id", "license_id"], :name => "unique_mc_licensable_licenses", :unique => true
  add_index "mc_licensable_licenses", ["licensable_type", "licensable_id"], :name => "mc_licensable_polymorphic"
  add_index "mc_licensable_licenses", ["license_id"], :name => "index_mc_licensable_licenses_on_license_id"

  create_table "mc_licenses", :force => true do |t|
    t.string "abbreviation", :null => false
    t.text   "summary",      :null => false
    t.string "url",          :null => false
  end

  add_index "mc_licenses", ["abbreviation"], :name => "index_mc_licenses_on_abbreviation", :unique => true
  add_index "mc_licenses", ["summary"], :name => "index_mc_licenses_on_summary", :unique => true
  add_index "mc_licenses", ["url"], :name => "index_mc_licenses_on_url", :unique => true

  create_table "mc_module_actions", :force => true do |t|
    t.integer "module_instance_id", :null => false
    t.text    "name",               :null => false
  end

  add_index "mc_module_actions", ["module_instance_id", "name"], :name => "index_mc_module_actions_on_module_instance_id_and_name", :unique => true

  create_table "mc_module_ancestors", :force => true do |t|
    t.string   "type"
    t.datetime "real_path_modified_at",                   :null => false
    t.string   "real_path_sha1_hex_digest", :limit => 40, :null => false
    t.text     "relative_path",                           :null => false
    t.integer  "parent_path_id",                          :null => false
  end

  add_index "mc_module_ancestors", ["parent_path_id"], :name => "index_mc_module_ancestors_on_parent_path_id"
  add_index "mc_module_ancestors", ["real_path_sha1_hex_digest"], :name => "index_mc_module_ancestors_on_real_path_sha1_hex_digest", :unique => true
  add_index "mc_module_ancestors", ["relative_path"], :name => "index_mc_module_ancestors_on_relative_path", :unique => true

  create_table "mc_module_architectures", :force => true do |t|
    t.integer "architecture_id",    :null => false
    t.integer "module_instance_id", :null => false
  end

  add_index "mc_module_architectures", ["module_instance_id", "architecture_id"], :name => "unique_mc_module_architectures", :unique => true

  create_table "mc_module_authors", :force => true do |t|
    t.integer "author_id",          :null => false
    t.integer "email_address_id"
    t.integer "module_instance_id", :null => false
  end

  add_index "mc_module_authors", ["author_id"], :name => "index_mc_module_authors_on_author_id"
  add_index "mc_module_authors", ["email_address_id"], :name => "index_mc_module_authors_on_email_address_id"
  add_index "mc_module_authors", ["module_instance_id", "author_id"], :name => "index_mc_module_authors_on_module_instance_id_and_author_id", :unique => true
  add_index "mc_module_authors", ["module_instance_id"], :name => "index_mc_module_authors_on_module_instance_id"

  create_table "mc_module_classes", :force => true do |t|
    t.text    "full_name",      :null => false
    t.string  "module_type",    :null => false
    t.string  "payload_type"
    t.text    "reference_name", :null => false
    t.integer "rank_id",        :null => false
  end

  add_index "mc_module_classes", ["full_name"], :name => "index_mc_module_classes_on_full_name", :unique => true
  add_index "mc_module_classes", ["module_type", "reference_name"], :name => "index_mc_module_classes_on_module_type_and_reference_name", :unique => true
  add_index "mc_module_classes", ["rank_id"], :name => "index_mc_module_classes_on_rank_id"

  create_table "mc_module_instances", :force => true do |t|
    t.text    "description",       :null => false
    t.date    "disclosed_on"
    t.string  "license",           :null => false
    t.text    "name",              :null => false
    t.boolean "privileged",        :null => false
    t.string  "stance"
    t.integer "default_action_id"
    t.integer "default_target_id"
    t.integer "module_class_id",   :null => false
  end

  add_index "mc_module_instances", ["default_action_id"], :name => "index_mc_module_instances_on_default_action_id", :unique => true
  add_index "mc_module_instances", ["default_target_id"], :name => "index_mc_module_instances_on_default_target_id", :unique => true
  add_index "mc_module_instances", ["module_class_id"], :name => "index_mc_module_instances_on_module_class_id", :unique => true

  create_table "mc_module_paths", :force => true do |t|
    t.string "gem"
    t.string "name"
    t.text   "real_path", :null => false
  end

  add_index "mc_module_paths", ["gem", "name"], :name => "index_mc_module_paths_on_gem_and_name", :unique => true
  add_index "mc_module_paths", ["real_path"], :name => "index_mc_module_paths_on_real_path", :unique => true

  create_table "mc_module_platforms", :force => true do |t|
    t.integer "module_instance_id", :null => false
    t.integer "platform_id",        :null => false
  end

  add_index "mc_module_platforms", ["module_instance_id", "platform_id"], :name => "index_mc_module_platforms_on_module_instance_id_and_platform_id", :unique => true

  create_table "mc_module_ranks", :force => true do |t|
    t.string  "name",   :null => false
    t.integer "number", :null => false
  end

  add_index "mc_module_ranks", ["name"], :name => "index_mc_module_ranks_on_name", :unique => true
  add_index "mc_module_ranks", ["number"], :name => "index_mc_module_ranks_on_number", :unique => true

  create_table "mc_module_references", :force => true do |t|
    t.integer "module_instance_id", :null => false
    t.integer "reference_id",       :null => false
  end

  add_index "mc_module_references", ["module_instance_id", "reference_id"], :name => "unique_mc_module_references", :unique => true

  create_table "mc_module_relationships", :force => true do |t|
    t.integer "ancestor_id",   :null => false
    t.integer "descendant_id", :null => false
  end

  add_index "mc_module_relationships", ["descendant_id", "ancestor_id"], :name => "index_mc_module_relationships_on_descendant_id_and_ancestor_id", :unique => true

  create_table "mc_module_target_architectures", :force => true do |t|
    t.integer "architecture_id",  :null => false
    t.integer "module_target_id", :null => false
  end

  add_index "mc_module_target_architectures", ["module_target_id", "architecture_id"], :name => "unique_mc_module_target_architectures", :unique => true

  create_table "mc_module_target_platforms", :force => true do |t|
    t.integer "module_target_id", :null => false
    t.integer "platform_id",      :null => false
  end

  add_index "mc_module_target_platforms", ["module_target_id", "platform_id"], :name => "unique_mc_module_target_platforms", :unique => true

  create_table "mc_module_targets", :force => true do |t|
    t.integer "index",              :null => false
    t.text    "name",               :null => false
    t.integer "module_instance_id", :null => false
  end

  add_index "mc_module_targets", ["module_instance_id", "index"], :name => "index_mc_module_targets_on_module_instance_id_and_index", :unique => true
  add_index "mc_module_targets", ["module_instance_id", "name"], :name => "index_mc_module_targets_on_module_instance_id_and_name", :unique => true

  create_table "mc_nop_instances", :force => true do |t|
    t.text    "description",  :null => false
    t.string  "name",         :null => false
    t.integer "nop_class_id", :null => false
  end

  add_index "mc_nop_instances", ["nop_class_id"], :name => "index_mc_nop_instances_on_nop_class_id", :unique => true

  create_table "mc_payload_handlers", :force => true do |t|
    t.string "general_handler_type", :null => false
    t.string "handler_type",         :null => false
  end

  add_index "mc_payload_handlers", ["handler_type"], :name => "index_mc_payload_handlers_on_handler_type", :unique => true

  create_table "mc_payload_single_instances", :force => true do |t|
    t.text    "description",             :null => false
    t.string  "name",                    :null => false
    t.boolean "privileged",              :null => false
    t.integer "handler_id",              :null => false
    t.integer "payload_single_class_id", :null => false
  end

  add_index "mc_payload_single_instances", ["handler_id"], :name => "index_mc_payload_single_instances_on_handler_id"
  add_index "mc_payload_single_instances", ["payload_single_class_id"], :name => "index_mc_payload_single_instances_on_payload_single_class_id", :unique => true

  create_table "mc_payload_stage_instances", :force => true do |t|
    t.text    "description",            :null => false
    t.string  "name",                   :null => false
    t.boolean "privileged",             :null => false
    t.integer "payload_stage_class_id", :null => false
  end

  add_index "mc_payload_stage_instances", ["payload_stage_class_id"], :name => "index_mc_payload_stage_instances_on_payload_stage_class_id", :unique => true

  create_table "mc_payload_stager_instances", :force => true do |t|
    t.text    "description",             :null => false
    t.string  "handler_type_alias"
    t.string  "name",                    :null => false
    t.boolean "privileged",              :null => false
    t.integer "handler_id",              :null => false
    t.integer "payload_stager_class_id", :null => false
  end

  add_index "mc_payload_stager_instances", ["handler_id"], :name => "index_mc_payload_stager_instances_on_handler_id"
  add_index "mc_payload_stager_instances", ["payload_stager_class_id"], :name => "index_mc_payload_stager_instances_on_payload_stager_class_id", :unique => true

  create_table "mc_platforms", :force => true do |t|
    t.text    "fully_qualified_name", :null => false
    t.text    "relative_name",        :null => false
    t.integer "parent_id"
    t.integer "right",                :null => false
    t.integer "left",                 :null => false
  end

  add_index "mc_platforms", ["fully_qualified_name"], :name => "index_mc_platforms_on_fully_qualified_name", :unique => true
  add_index "mc_platforms", ["parent_id", "relative_name"], :name => "index_mc_platforms_on_parent_id_and_relative_name", :unique => true

  create_table "mc_post_instances", :force => true do |t|
    t.text    "description",   :null => false
    t.date    "disclosed_on",  :null => false
    t.string  "name",          :null => false
    t.boolean "privileged",    :null => false
    t.integer "post_class_id", :null => false
  end

  add_index "mc_post_instances", ["post_class_id"], :name => "index_mc_post_instances_on_post_class_id", :unique => true

  create_table "mc_references", :force => true do |t|
    t.string  "designation"
    t.text    "url"
    t.integer "authority_id"
  end

  add_index "mc_references", ["authority_id", "designation"], :name => "index_mc_references_on_authority_id_and_designation", :unique => true
  add_index "mc_references", ["url"], :name => "index_mc_references_on_url", :unique => true

end
