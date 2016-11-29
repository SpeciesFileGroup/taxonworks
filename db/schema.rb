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

ActiveRecord::Schema.define(version: 20161109214506) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "hstore"
  enable_extension "fuzzystrmatch"

  create_table "alternate_values", force: :cascade do |t|
    t.text     "value",                            null: false
    t.string   "type",                             null: false
    t.integer  "language_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "created_by_id",                    null: false
    t.integer  "updated_by_id",                    null: false
    t.string   "alternate_value_object_attribute"
    t.integer  "alternate_value_object_id",        null: false
    t.string   "alternate_value_object_type",      null: false
    t.integer  "project_id"
  end

  add_index "alternate_values", ["alternate_value_object_id", "alternate_value_object_type"], name: "index_alternate_values_on_alternate_value_object_id_and_type", using: :btree
  add_index "alternate_values", ["created_by_id"], name: "index_alternate_values_on_created_by_id", using: :btree
  add_index "alternate_values", ["language_id"], name: "index_alternate_values_on_language_id", using: :btree
  add_index "alternate_values", ["project_id"], name: "index_alternate_values_on_project_id", using: :btree
  add_index "alternate_values", ["type"], name: "index_alternate_values_on_type", using: :btree
  add_index "alternate_values", ["updated_by_id"], name: "index_alternate_values_on_updated_by_id", using: :btree

  create_table "asserted_distributions", force: :cascade do |t|
    t.integer  "otu_id",             null: false
    t.integer  "geographic_area_id", null: false
    t.integer  "project_id",         null: false
    t.integer  "created_by_id",      null: false
    t.integer  "updated_by_id",      null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.boolean  "is_absent"
  end

  add_index "asserted_distributions", ["created_by_id"], name: "index_asserted_distributions_on_created_by_id", using: :btree
  add_index "asserted_distributions", ["geographic_area_id"], name: "index_asserted_distributions_on_geographic_area_id", using: :btree
  add_index "asserted_distributions", ["otu_id"], name: "index_asserted_distributions_on_otu_id", using: :btree
  add_index "asserted_distributions", ["project_id"], name: "index_asserted_distributions_on_project_id", using: :btree
  add_index "asserted_distributions", ["updated_by_id"], name: "index_asserted_distributions_on_updated_by_id", using: :btree

  create_table "biocuration_classifications", force: :cascade do |t|
    t.integer  "biocuration_class_id",            null: false
    t.integer  "biological_collection_object_id", null: false
    t.integer  "position",                        null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "created_by_id",                   null: false
    t.integer  "updated_by_id",                   null: false
    t.integer  "project_id",                      null: false
  end

  add_index "biocuration_classifications", ["biocuration_class_id"], name: "index_biocuration_classifications_on_biocuration_class_id", using: :btree
  add_index "biocuration_classifications", ["biological_collection_object_id"], name: "bio_c_bio_collection_object", using: :btree
  add_index "biocuration_classifications", ["created_by_id"], name: "index_biocuration_classifications_on_created_by_id", using: :btree
  add_index "biocuration_classifications", ["position"], name: "index_biocuration_classifications_on_position", using: :btree
  add_index "biocuration_classifications", ["project_id"], name: "index_biocuration_classifications_on_project_id", using: :btree
  add_index "biocuration_classifications", ["updated_by_id"], name: "index_biocuration_classifications_on_updated_by_id", using: :btree

  create_table "biological_associations", force: :cascade do |t|
    t.integer  "biological_relationship_id",          null: false
    t.integer  "biological_association_subject_id",   null: false
    t.string   "biological_association_subject_type", null: false
    t.integer  "biological_association_object_id",    null: false
    t.string   "biological_association_object_type",  null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "created_by_id",                       null: false
    t.integer  "updated_by_id",                       null: false
    t.integer  "project_id",                          null: false
  end

  add_index "biological_associations", ["biological_association_object_id", "biological_association_object_type"], name: "index_biological_associations_on_object_id_and_type", using: :btree
  add_index "biological_associations", ["biological_association_subject_id", "biological_association_subject_type"], name: "index_biological_associations_on_subject_id_and_type", using: :btree
  add_index "biological_associations", ["biological_relationship_id"], name: "index_biological_associations_on_biological_relationship_id", using: :btree
  add_index "biological_associations", ["created_by_id"], name: "index_biological_associations_on_created_by_id", using: :btree
  add_index "biological_associations", ["project_id"], name: "index_biological_associations_on_project_id", using: :btree
  add_index "biological_associations", ["updated_by_id"], name: "index_biological_associations_on_updated_by_id", using: :btree

  create_table "biological_associations_biological_associations_graphs", force: :cascade do |t|
    t.integer  "biological_associations_graph_id", null: false
    t.integer  "biological_association_id",        null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "created_by_id",                    null: false
    t.integer  "updated_by_id",                    null: false
    t.integer  "project_id",                       null: false
  end

  add_index "biological_associations_biological_associations_graphs", ["biological_association_id"], name: "bio_asc_bio_asc_graph_bio_asc", using: :btree
  add_index "biological_associations_biological_associations_graphs", ["biological_associations_graph_id"], name: "bio_asc_bio_asc_graph_bio_asc_graph", using: :btree
  add_index "biological_associations_biological_associations_graphs", ["created_by_id"], name: "bio_asc_bio_asc_graph_created_by", using: :btree
  add_index "biological_associations_biological_associations_graphs", ["project_id"], name: "bio_asc_bio_asc_graph_project", using: :btree
  add_index "biological_associations_biological_associations_graphs", ["updated_by_id"], name: "bio_asc_bio_asc_graph_updated_by", using: :btree

  create_table "biological_associations_graphs", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.string   "name"
  end

  add_index "biological_associations_graphs", ["created_by_id"], name: "index_biological_associations_graphs_on_created_by_id", using: :btree
  add_index "biological_associations_graphs", ["project_id"], name: "index_biological_associations_graphs_on_project_id", using: :btree
  add_index "biological_associations_graphs", ["updated_by_id"], name: "index_biological_associations_graphs_on_updated_by_id", using: :btree

  create_table "biological_relationship_types", force: :cascade do |t|
    t.string   "type",                       null: false
    t.integer  "biological_property_id",     null: false
    t.integer  "biological_relationship_id", null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "created_by_id",              null: false
    t.integer  "updated_by_id",              null: false
    t.integer  "project_id",                 null: false
  end

  add_index "biological_relationship_types", ["biological_property_id"], name: "index_biological_relationship_types_on_biological_property_id", using: :btree
  add_index "biological_relationship_types", ["biological_relationship_id"], name: "bio_rel_type_bio_rel", using: :btree
  add_index "biological_relationship_types", ["created_by_id"], name: "bio_rel_type_created_by", using: :btree
  add_index "biological_relationship_types", ["project_id"], name: "bio_rel_type_project", using: :btree
  add_index "biological_relationship_types", ["type"], name: "index_biological_relationship_types_on_type", using: :btree
  add_index "biological_relationship_types", ["updated_by_id"], name: "bio_rel_type_updated_by", using: :btree

  create_table "biological_relationships", force: :cascade do |t|
    t.string   "name",          null: false
    t.boolean  "is_transitive"
    t.boolean  "is_reflexive"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
  end

  add_index "biological_relationships", ["created_by_id"], name: "bio_rel_created_by", using: :btree
  add_index "biological_relationships", ["project_id"], name: "bio_rel_project", using: :btree
  add_index "biological_relationships", ["updated_by_id"], name: "bio_rel_updated_by", using: :btree

  create_table "citation_topics", force: :cascade do |t|
    t.integer  "topic_id",      null: false
    t.integer  "citation_id",   null: false
    t.string   "pages"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
  end

  add_index "citation_topics", ["citation_id"], name: "index_citation_topics_on_citation_id", using: :btree
  add_index "citation_topics", ["created_by_id"], name: "index_citation_topics_on_created_by_id", using: :btree
  add_index "citation_topics", ["project_id"], name: "index_citation_topics_on_project_id", using: :btree
  add_index "citation_topics", ["topic_id"], name: "index_citation_topics_on_topic_id", using: :btree
  add_index "citation_topics", ["updated_by_id"], name: "index_citation_topics_on_updated_by_id", using: :btree

  create_table "citations", force: :cascade do |t|
    t.string   "citation_object_type", null: false
    t.integer  "source_id",            null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "created_by_id",        null: false
    t.integer  "updated_by_id",        null: false
    t.integer  "project_id",           null: false
    t.integer  "citation_object_id",   null: false
    t.string   "pages"
    t.boolean  "is_original"
  end

  add_index "citations", ["citation_object_id"], name: "index_citations_on_citation_object_id", using: :btree
  add_index "citations", ["citation_object_type"], name: "index_citations_on_citation_object_type", using: :btree
  add_index "citations", ["created_by_id"], name: "index_citations_on_created_by_id", using: :btree
  add_index "citations", ["project_id"], name: "index_citations_on_project_id", using: :btree
  add_index "citations", ["source_id"], name: "index_citations_on_source_id", using: :btree
  add_index "citations", ["updated_by_id"], name: "index_citations_on_updated_by_id", using: :btree

  create_table "collecting_events", force: :cascade do |t|
    t.text     "verbatim_label"
    t.text     "print_label"
    t.text     "document_label"
    t.string   "verbatim_locality"
    t.string   "verbatim_longitude"
    t.string   "verbatim_latitude"
    t.string   "verbatim_geolocation_uncertainty"
    t.string   "verbatim_trip_identifier"
    t.string   "verbatim_collectors"
    t.string   "verbatim_method"
    t.integer  "geographic_area_id"
    t.decimal  "minimum_elevation"
    t.decimal  "maximum_elevation"
    t.string   "elevation_precision"
    t.text     "field_notes"
    t.string   "md5_of_verbatim_label"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.text     "cached"
    t.integer  "created_by_id",                              null: false
    t.integer  "updated_by_id",                              null: false
    t.integer  "project_id",                                 null: false
    t.integer  "start_date_year"
    t.integer  "end_date_year"
    t.integer  "start_date_day"
    t.integer  "end_date_day"
    t.string   "verbatim_elevation"
    t.text     "verbatim_habitat"
    t.string   "verbatim_datum"
    t.integer  "time_start_hour",                  limit: 2
    t.integer  "time_start_minute",                limit: 2
    t.integer  "time_start_second",                limit: 2
    t.integer  "time_end_hour",                    limit: 2
    t.integer  "time_end_minute",                  limit: 2
    t.integer  "time_end_second",                  limit: 2
    t.string   "verbatim_date"
    t.integer  "start_date_month"
    t.integer  "end_date_month"
    t.string   "cached_level0_geographic_name"
    t.string   "cached_level1_geographic_name"
    t.string   "cached_level2_geographic_name"
  end

  add_index "collecting_events", ["created_by_id"], name: "index_collecting_events_on_created_by_id", using: :btree
  add_index "collecting_events", ["geographic_area_id"], name: "index_collecting_events_on_geographic_area_id", using: :btree
  add_index "collecting_events", ["project_id"], name: "index_collecting_events_on_project_id", using: :btree
  add_index "collecting_events", ["updated_by_id"], name: "index_collecting_events_on_updated_by_id", using: :btree

  create_table "collection_object_observations", force: :cascade do |t|
    t.text     "data",          null: false
    t.integer  "project_id",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "collection_object_observations", ["created_by_id"], name: "index_collection_object_observations_on_created_by_id", using: :btree
  add_index "collection_object_observations", ["data"], name: "index_collection_object_observations_on_data", using: :btree
  add_index "collection_object_observations", ["project_id"], name: "index_collection_object_observations_on_project_id", using: :btree
  add_index "collection_object_observations", ["updated_by_id"], name: "index_collection_object_observations_on_updated_by_id", using: :btree

  create_table "collection_objects", force: :cascade do |t|
    t.integer  "total"
    t.string   "type",                      null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "preparation_type_id"
    t.integer  "repository_id"
    t.integer  "created_by_id",             null: false
    t.integer  "updated_by_id",             null: false
    t.integer  "project_id",                null: false
    t.text     "buffered_collecting_event"
    t.text     "buffered_determinations"
    t.text     "buffered_other_labels"
    t.integer  "ranged_lot_category_id"
    t.integer  "collecting_event_id"
    t.date     "accessioned_at"
    t.string   "deaccession_reason"
    t.date     "deaccessioned_at"
  end

  add_index "collection_objects", ["collecting_event_id"], name: "index_collection_objects_on_collecting_event_id", using: :btree
  add_index "collection_objects", ["created_by_id"], name: "index_collection_objects_on_created_by_id", using: :btree
  add_index "collection_objects", ["preparation_type_id"], name: "index_collection_objects_on_preparation_type_id", using: :btree
  add_index "collection_objects", ["project_id"], name: "index_collection_objects_on_project_id", using: :btree
  add_index "collection_objects", ["ranged_lot_category_id"], name: "index_collection_objects_on_ranged_lot_category_id", using: :btree
  add_index "collection_objects", ["repository_id"], name: "index_collection_objects_on_repository_id", using: :btree
  add_index "collection_objects", ["type"], name: "index_collection_objects_on_type", using: :btree
  add_index "collection_objects", ["updated_by_id"], name: "index_collection_objects_on_updated_by_id", using: :btree

  create_table "collection_profiles", force: :cascade do |t|
    t.integer  "container_id"
    t.integer  "otu_id"
    t.integer  "conservation_status"
    t.integer  "processing_state"
    t.integer  "container_condition"
    t.integer  "condition_of_labels"
    t.integer  "identification_level"
    t.integer  "arrangement_level"
    t.integer  "data_quality"
    t.integer  "computerization_level"
    t.integer  "number_of_collection_objects"
    t.integer  "number_of_containers"
    t.integer  "created_by_id",                null: false
    t.integer  "updated_by_id",                null: false
    t.integer  "project_id",                   null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "collection_type"
  end

  add_index "collection_profiles", ["collection_type"], name: "index_collection_profiles_on_collection_type", using: :btree
  add_index "collection_profiles", ["container_id"], name: "index_collection_profiles_on_container_id", using: :btree
  add_index "collection_profiles", ["created_by_id"], name: "index_collection_profiles_on_created_by_id", using: :btree
  add_index "collection_profiles", ["otu_id"], name: "index_collection_profiles_on_otu_id", using: :btree
  add_index "collection_profiles", ["project_id"], name: "index_collection_profiles_on_project_id", using: :btree
  add_index "collection_profiles", ["updated_by_id"], name: "index_collection_profiles_on_updated_by_id", using: :btree

  create_table "common_names", force: :cascade do |t|
    t.string   "name",               null: false
    t.integer  "geographic_area_id"
    t.integer  "otu_id"
    t.integer  "language_id"
    t.integer  "start_year"
    t.integer  "end_year"
    t.integer  "project_id",         null: false
    t.integer  "created_by_id",      null: false
    t.integer  "updated_by_id",      null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "common_names", ["created_by_id"], name: "index_common_names_on_created_by_id", using: :btree
  add_index "common_names", ["geographic_area_id"], name: "index_common_names_on_geographic_area_id", using: :btree
  add_index "common_names", ["language_id"], name: "index_common_names_on_language_id", using: :btree
  add_index "common_names", ["name"], name: "index_common_names_on_name", using: :btree
  add_index "common_names", ["otu_id"], name: "index_common_names_on_otu_id", using: :btree
  add_index "common_names", ["project_id"], name: "index_common_names_on_project_id", using: :btree
  add_index "common_names", ["updated_by_id"], name: "index_common_names_on_updated_by_id", using: :btree

  create_table "confidences", force: :cascade do |t|
    t.integer  "confidence_object_id",   null: false
    t.string   "confidence_object_type", null: false
    t.integer  "position",               null: false
    t.integer  "created_by_id",          null: false
    t.integer  "updated_by_id",          null: false
    t.integer  "project_id",             null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "confidence_level_id",    null: false
  end

  add_index "confidences", ["project_id"], name: "index_confidences_on_project_id", using: :btree

  create_table "container_item_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "container_item_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "container_item_anc_desc_idx", unique: true, using: :btree
  add_index "container_item_hierarchies", ["descendant_id"], name: "container_item_desc_idx", using: :btree

  create_table "container_items", force: :cascade do |t|
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "contained_object_id",   null: false
    t.string   "contained_object_type", null: false
    t.string   "disposition"
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
    t.integer  "disposition_x"
    t.integer  "disposition_y"
    t.integer  "disposition_z"
    t.integer  "parent_id"
  end

  add_index "container_items", ["contained_object_id", "contained_object_type"], name: "index_container_items_on_contained_object_id_and_type", using: :btree
  add_index "container_items", ["created_by_id"], name: "index_container_items_on_created_by_id", using: :btree
  add_index "container_items", ["project_id"], name: "index_container_items_on_project_id", using: :btree
  add_index "container_items", ["updated_by_id"], name: "index_container_items_on_updated_by_id", using: :btree

  create_table "container_labels", force: :cascade do |t|
    t.text     "label",         null: false
    t.date     "date_printed"
    t.string   "print_style"
    t.integer  "position",      null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "container_id",  null: false
  end

  add_index "container_labels", ["container_id"], name: "index_container_labels_on_container_id", using: :btree
  add_index "container_labels", ["created_by_id"], name: "index_container_labels_on_created_by_id", using: :btree
  add_index "container_labels", ["position"], name: "index_container_labels_on_position", using: :btree
  add_index "container_labels", ["project_id"], name: "index_container_labels_on_project_id", using: :btree
  add_index "container_labels", ["updated_by_id"], name: "index_container_labels_on_updated_by_id", using: :btree

  create_table "containers", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "type",          null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.string   "name"
    t.string   "disposition"
    t.integer  "size_x"
    t.integer  "size_y"
    t.integer  "size_z"
  end

  add_index "containers", ["created_by_id"], name: "index_containers_on_created_by_id", using: :btree
  add_index "containers", ["disposition"], name: "index_containers_on_disposition", using: :btree
  add_index "containers", ["project_id"], name: "index_containers_on_project_id", using: :btree
  add_index "containers", ["type"], name: "index_containers_on_type", using: :btree
  add_index "containers", ["updated_by_id"], name: "index_containers_on_updated_by_id", using: :btree

  create_table "contents", force: :cascade do |t|
    t.text     "text",          null: false
    t.integer  "otu_id",        null: false
    t.integer  "topic_id",      null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.integer  "revision_id"
  end

  add_index "contents", ["created_by_id"], name: "index_contents_on_created_by_id", using: :btree
  add_index "contents", ["otu_id"], name: "index_contents_on_otu_id", using: :btree
  add_index "contents", ["project_id"], name: "index_contents_on_project_id", using: :btree
  add_index "contents", ["revision_id"], name: "index_contents_on_revision_id", using: :btree
  add_index "contents", ["topic_id"], name: "index_contents_on_topic_id", using: :btree
  add_index "contents", ["updated_by_id"], name: "index_contents_on_updated_by_id", using: :btree

  create_table "controlled_vocabulary_terms", force: :cascade do |t|
    t.string   "type",          null: false
    t.string   "name",          null: false
    t.text     "definition",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.string   "uri"
    t.string   "uri_relation"
    t.string   "css_color"
  end

  add_index "controlled_vocabulary_terms", ["created_by_id"], name: "index_controlled_vocabulary_terms_on_created_by_id", using: :btree
  add_index "controlled_vocabulary_terms", ["project_id"], name: "index_controlled_vocabulary_terms_on_project_id", using: :btree
  add_index "controlled_vocabulary_terms", ["type"], name: "index_controlled_vocabulary_terms_on_type", using: :btree
  add_index "controlled_vocabulary_terms", ["updated_by_id"], name: "index_controlled_vocabulary_terms_on_updated_by_id", using: :btree

  create_table "data_attributes", force: :cascade do |t|
    t.string   "type",                          null: false
    t.integer  "attribute_subject_id",          null: false
    t.string   "attribute_subject_type",        null: false
    t.integer  "controlled_vocabulary_term_id"
    t.string   "import_predicate"
    t.text     "value",                         null: false
    t.integer  "created_by_id",                 null: false
    t.integer  "updated_by_id",                 null: false
    t.integer  "project_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "data_attributes", ["attribute_subject_id", "attribute_subject_type"], name: "index_data_attributes_on_attribute_subject_id_and_type", using: :btree
  add_index "data_attributes", ["attribute_subject_type"], name: "index_data_attributes_on_attribute_subject_type", using: :btree
  add_index "data_attributes", ["controlled_vocabulary_term_id"], name: "index_data_attributes_on_controlled_vocabulary_term_id", using: :btree
  add_index "data_attributes", ["created_by_id"], name: "index_data_attributes_on_created_by_id", using: :btree
  add_index "data_attributes", ["project_id"], name: "index_data_attributes_on_project_id", using: :btree
  add_index "data_attributes", ["type"], name: "index_data_attributes_on_type", using: :btree
  add_index "data_attributes", ["updated_by_id"], name: "index_data_attributes_on_updated_by_id", using: :btree

  create_table "depictions", force: :cascade do |t|
    t.string   "depiction_object_type", null: false
    t.integer  "depiction_object_id",   null: false
    t.integer  "image_id",              null: false
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "position"
  end

  add_index "depictions", ["created_by_id"], name: "index_depictions_on_created_by_id", using: :btree
  add_index "depictions", ["depiction_object_id"], name: "index_depictions_on_depiction_object_id", using: :btree
  add_index "depictions", ["depiction_object_type"], name: "index_depictions_on_depiction_object_type", using: :btree
  add_index "depictions", ["image_id"], name: "index_depictions_on_image_id", using: :btree
  add_index "depictions", ["project_id"], name: "index_depictions_on_project_id", using: :btree
  add_index "depictions", ["updated_by_id"], name: "index_depictions_on_updated_by_id", using: :btree

  create_table "derived_collection_objects", force: :cascade do |t|
    t.integer  "collection_object_observation_id", null: false
    t.integer  "collection_object_id",             null: false
    t.integer  "position"
    t.integer  "project_id",                       null: false
    t.integer  "created_by_id",                    null: false
    t.integer  "updated_by_id",                    null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "derived_collection_objects", ["collection_object_id"], name: "dco_collection_object", using: :btree
  add_index "derived_collection_objects", ["collection_object_observation_id"], name: "dco_collection_object_observation", using: :btree
  add_index "derived_collection_objects", ["project_id"], name: "index_derived_collection_objects_on_project_id", using: :btree

  create_table "descriptors", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "short_name"
    t.string   "type",          null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "descriptors", ["created_by_id"], name: "index_descriptors_on_created_by_id", using: :btree
  add_index "descriptors", ["name"], name: "index_descriptors_on_name", using: :btree
  add_index "descriptors", ["project_id"], name: "index_descriptors_on_project_id", using: :btree
  add_index "descriptors", ["short_name"], name: "index_descriptors_on_short_name", using: :btree
  add_index "descriptors", ["updated_by_id"], name: "index_descriptors_on_updated_by_id", using: :btree

  create_table "documentation", force: :cascade do |t|
    t.integer  "documentation_object_id",   null: false
    t.string   "documentation_object_type", null: false
    t.integer  "document_id",               null: false
    t.json     "page_map"
    t.integer  "project_id",                null: false
    t.integer  "created_by_id",             null: false
    t.integer  "updated_by_id",             null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "documentation", ["created_by_id"], name: "index_documentation_on_created_by_id", using: :btree
  add_index "documentation", ["document_id"], name: "index_documentation_on_document_id", using: :btree
  add_index "documentation", ["documentation_object_id", "documentation_object_type"], name: "index_doc_on_doc_object_type_and_doc_object_id", using: :btree
  add_index "documentation", ["project_id"], name: "index_documentation_on_project_id", using: :btree
  add_index "documentation", ["updated_by_id"], name: "index_documentation_on_updated_by_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "document_file_file_name",    null: false
    t.string   "document_file_content_type", null: false
    t.integer  "document_file_file_size",    null: false
    t.datetime "document_file_updated_at",   null: false
    t.integer  "project_id",                 null: false
    t.integer  "created_by_id",              null: false
    t.integer  "updated_by_id",              null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "documents", ["document_file_content_type"], name: "index_documents_on_document_file_content_type", using: :btree
  add_index "documents", ["document_file_file_name"], name: "index_documents_on_document_file_file_name", using: :btree
  add_index "documents", ["document_file_file_size"], name: "index_documents_on_document_file_file_size", using: :btree
  add_index "documents", ["document_file_updated_at"], name: "index_documents_on_document_file_updated_at", using: :btree

  create_table "geographic_area_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "geographic_area_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "geographic_area_anc_desc_idx", unique: true, using: :btree
  add_index "geographic_area_hierarchies", ["descendant_id"], name: "geographic_area_desc_idx", using: :btree

  create_table "geographic_area_types", force: :cascade do |t|
    t.string   "name",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
  end

  add_index "geographic_area_types", ["created_by_id"], name: "index_geographic_area_types_on_created_by_id", using: :btree
  add_index "geographic_area_types", ["name"], name: "index_geographic_area_types_on_name", using: :btree
  add_index "geographic_area_types", ["updated_by_id"], name: "index_geographic_area_types_on_updated_by_id", using: :btree

  create_table "geographic_areas", force: :cascade do |t|
    t.string   "name",                    null: false
    t.integer  "level0_id"
    t.integer  "level1_id"
    t.integer  "level2_id"
    t.integer  "parent_id"
    t.integer  "geographic_area_type_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "iso_3166_a2"
    t.string   "iso_3166_a3"
    t.string   "tdwgID"
    t.string   "data_origin",             null: false
    t.integer  "created_by_id",           null: false
    t.integer  "updated_by_id",           null: false
  end

  add_index "geographic_areas", ["created_by_id"], name: "index_geographic_areas_on_created_by_id", using: :btree
  add_index "geographic_areas", ["geographic_area_type_id"], name: "index_geographic_areas_on_geographic_area_type_id", using: :btree
  add_index "geographic_areas", ["level0_id"], name: "index_geographic_areas_on_level0_id", using: :btree
  add_index "geographic_areas", ["level1_id"], name: "index_geographic_areas_on_level1_id", using: :btree
  add_index "geographic_areas", ["level2_id"], name: "index_geographic_areas_on_level2_id", using: :btree
  add_index "geographic_areas", ["name"], name: "index_geographic_areas_on_name", using: :btree
  add_index "geographic_areas", ["parent_id"], name: "index_geographic_areas_on_parent_id", using: :btree
  add_index "geographic_areas", ["updated_by_id"], name: "index_geographic_areas_on_updated_by_id", using: :btree

  create_table "geographic_areas_geographic_items", force: :cascade do |t|
    t.integer  "geographic_area_id", null: false
    t.integer  "geographic_item_id"
    t.string   "data_origin"
    t.integer  "origin_gid"
    t.string   "date_valid_from"
    t.string   "date_valid_to"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "geographic_areas_geographic_items", ["geographic_area_id"], name: "index_geographic_areas_geographic_items_on_geographic_area_id", using: :btree
  add_index "geographic_areas_geographic_items", ["geographic_item_id"], name: "index_geographic_areas_geographic_items_on_geographic_item_id", using: :btree

  create_table "geographic_items", force: :cascade do |t|
    t.datetime  "created_at",                                                                                               null: false
    t.datetime  "updated_at",                                                                                               null: false
    t.geography "point",               limit: {:srid=>4326, :type=>"point", :has_z=>true, :geographic=>true}
    t.geography "line_string",         limit: {:srid=>4326, :type=>"line_string", :has_z=>true, :geographic=>true}
    t.geography "polygon",             limit: {:srid=>4326, :type=>"polygon", :has_z=>true, :geographic=>true}
    t.geography "multi_point",         limit: {:srid=>4326, :type=>"multi_point", :has_z=>true, :geographic=>true}
    t.geography "multi_line_string",   limit: {:srid=>4326, :type=>"multi_line_string", :has_z=>true, :geographic=>true}
    t.geography "multi_polygon",       limit: {:srid=>4326, :type=>"multi_polygon", :has_z=>true, :geographic=>true}
    t.geography "geometry_collection", limit: {:srid=>4326, :type=>"geometry_collection", :has_z=>true, :geographic=>true}
    t.integer   "created_by_id",                                                                                            null: false
    t.integer   "updated_by_id",                                                                                            null: false
    t.string    "type",                                                                                                     null: false
  end

  add_index "geographic_items", ["created_by_id"], name: "index_geographic_items_on_created_by_id", using: :btree
  add_index "geographic_items", ["geometry_collection"], name: "geometry_collection_gix", using: :gist
  add_index "geographic_items", ["line_string"], name: "line_string_gix", using: :gist
  add_index "geographic_items", ["multi_line_string"], name: "multi_line_string_gix", using: :gist
  add_index "geographic_items", ["multi_point"], name: "multi_point_gix", using: :gist
  add_index "geographic_items", ["multi_polygon"], name: "multi_polygon_gix", using: :gist
  add_index "geographic_items", ["point"], name: "point_gix", using: :gist
  add_index "geographic_items", ["polygon"], name: "polygon_gix", using: :gist
  add_index "geographic_items", ["type"], name: "index_geographic_items_on_type", using: :btree
  add_index "geographic_items", ["updated_by_id"], name: "index_geographic_items_on_updated_by_id", using: :btree

  create_table "georeferences", force: :cascade do |t|
    t.integer  "geographic_item_id",                       null: false
    t.integer  "collecting_event_id",                      null: false
    t.decimal  "error_radius"
    t.decimal  "error_depth"
    t.integer  "error_geographic_item_id"
    t.string   "type",                                     null: false
    t.integer  "position",                                 null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "is_public",                default: false, null: false
    t.string   "api_request"
    t.integer  "created_by_id",                            null: false
    t.integer  "updated_by_id",                            null: false
    t.integer  "project_id",                               null: false
    t.boolean  "is_undefined_z"
    t.boolean  "is_median_z"
  end

  add_index "georeferences", ["collecting_event_id"], name: "index_georeferences_on_collecting_event_id", using: :btree
  add_index "georeferences", ["created_by_id"], name: "index_georeferences_on_created_by_id", using: :btree
  add_index "georeferences", ["error_geographic_item_id"], name: "index_georeferences_on_error_geographic_item_id", using: :btree
  add_index "georeferences", ["geographic_item_id"], name: "index_georeferences_on_geographic_item_id", using: :btree
  add_index "georeferences", ["position"], name: "index_georeferences_on_position", using: :btree
  add_index "georeferences", ["project_id"], name: "index_georeferences_on_project_id", using: :btree
  add_index "georeferences", ["type"], name: "index_georeferences_on_type", using: :btree
  add_index "georeferences", ["updated_by_id"], name: "index_georeferences_on_updated_by_id", using: :btree

  create_table "identifiers", force: :cascade do |t|
    t.string   "identifier",             null: false
    t.string   "type",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "namespace_id"
    t.integer  "created_by_id",          null: false
    t.integer  "updated_by_id",          null: false
    t.integer  "project_id"
    t.text     "cached"
    t.integer  "identifier_object_id",   null: false
    t.string   "identifier_object_type", null: false
    t.string   "relation"
    t.integer  "position"
  end

  add_index "identifiers", ["created_by_id"], name: "index_identifiers_on_created_by_id", using: :btree
  add_index "identifiers", ["identifier_object_id", "identifier_object_type"], name: "index_identifiers_on_identifier_object_id_and_type", using: :btree
  add_index "identifiers", ["namespace_id"], name: "index_identifiers_on_namespace_id", using: :btree
  add_index "identifiers", ["project_id"], name: "index_identifiers_on_project_id", using: :btree
  add_index "identifiers", ["type"], name: "index_identifiers_on_type", using: :btree
  add_index "identifiers", ["updated_by_id"], name: "index_identifiers_on_updated_by_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "user_file_name"
    t.integer  "height"
    t.integer  "width"
    t.string   "image_file_fingerprint"
    t.integer  "created_by_id",           null: false
    t.integer  "project_id",              null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "image_file_file_name"
    t.string   "image_file_content_type"
    t.integer  "image_file_file_size"
    t.datetime "image_file_updated_at"
    t.integer  "updated_by_id",           null: false
    t.text     "image_file_meta"
  end

  add_index "images", ["created_by_id"], name: "index_images_on_created_by_id", using: :btree
  add_index "images", ["image_file_content_type"], name: "index_images_on_image_file_content_type", using: :btree
  add_index "images", ["project_id"], name: "index_images_on_project_id", using: :btree
  add_index "images", ["updated_by_id"], name: "index_images_on_updated_by_id", using: :btree

  create_table "imports", force: :cascade do |t|
    t.string   "name"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "metadata_json"
  end

  create_table "languages", force: :cascade do |t|
    t.string   "alpha_3_bibliographic"
    t.string   "alpha_3_terminologic"
    t.string   "alpha_2"
    t.string   "english_name"
    t.string   "french_name"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
  end

  add_index "languages", ["created_by_id"], name: "index_languages_on_created_by_id", using: :btree
  add_index "languages", ["updated_by_id"], name: "index_languages_on_updated_by_id", using: :btree

  create_table "loan_items", force: :cascade do |t|
    t.integer  "loan_id",               null: false
    t.date     "date_returned"
    t.integer  "position",              null: false
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "loan_item_object_id"
    t.string   "loan_item_object_type"
    t.integer  "total"
    t.string   "disposition"
  end

  add_index "loan_items", ["created_by_id"], name: "index_loan_items_on_created_by_id", using: :btree
  add_index "loan_items", ["loan_id"], name: "index_loan_items_on_loan_id", using: :btree
  add_index "loan_items", ["position"], name: "index_loan_items_on_position", using: :btree
  add_index "loan_items", ["project_id"], name: "index_loan_items_on_project_id", using: :btree
  add_index "loan_items", ["updated_by_id"], name: "index_loan_items_on_updated_by_id", using: :btree

  create_table "loans", force: :cascade do |t|
    t.date     "date_requested"
    t.string   "request_method"
    t.date     "date_sent"
    t.date     "date_received"
    t.date     "date_return_expected"
    t.string   "recipient_address"
    t.string   "recipient_email"
    t.string   "recipient_phone"
    t.string   "supervisor_email"
    t.string   "supervisor_phone"
    t.date     "date_closed"
    t.integer  "created_by_id",                                                   null: false
    t.integer  "updated_by_id",                                                   null: false
    t.integer  "project_id",                                                      null: false
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "recipient_honorarium"
    t.string   "recipient_country"
    t.text     "lender_address",       default: "Lender's address not provided.", null: false
  end

  add_index "loans", ["created_by_id"], name: "index_loans_on_created_by_id", using: :btree
  add_index "loans", ["project_id"], name: "index_loans_on_project_id", using: :btree
  add_index "loans", ["updated_by_id"], name: "index_loans_on_updated_by_id", using: :btree

  create_table "namespaces", force: :cascade do |t|
    t.string   "institution"
    t.string   "name",                null: false
    t.string   "short_name",          null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "created_by_id",       null: false
    t.integer  "updated_by_id",       null: false
    t.string   "verbatim_short_name"
  end

  add_index "namespaces", ["created_by_id"], name: "index_namespaces_on_created_by_id", using: :btree
  add_index "namespaces", ["updated_by_id"], name: "index_namespaces_on_updated_by_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.text     "text",                  null: false
    t.integer  "note_object_id",        null: false
    t.string   "note_object_type",      null: false
    t.string   "note_object_attribute"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
  end

  add_index "notes", ["created_by_id"], name: "index_notes_on_created_by_id", using: :btree
  add_index "notes", ["note_object_id", "note_object_type"], name: "index_notes_on_note_object_id_and_type", using: :btree
  add_index "notes", ["project_id"], name: "index_notes_on_project_id", using: :btree
  add_index "notes", ["updated_by_id"], name: "index_notes_on_updated_by_id", using: :btree

  create_table "origin_relationships", force: :cascade do |t|
    t.integer  "old_object_id",   null: false
    t.string   "old_object_type", null: false
    t.integer  "new_object_id",   null: false
    t.string   "new_object_type", null: false
    t.integer  "position"
    t.integer  "created_by_id",   null: false
    t.integer  "updated_by_id",   null: false
    t.integer  "project_id",      null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "origin_relationships", ["created_by_id"], name: "index_origin_relationships_on_created_by_id", using: :btree
  add_index "origin_relationships", ["new_object_type", "new_object_id"], name: "index_origin_relationships_on_new_object_type_and_new_object_id", using: :btree
  add_index "origin_relationships", ["old_object_type", "old_object_id"], name: "index_origin_relationships_on_old_object_type_and_old_object_id", using: :btree
  add_index "origin_relationships", ["project_id"], name: "index_origin_relationships_on_project_id", using: :btree
  add_index "origin_relationships", ["updated_by_id"], name: "index_origin_relationships_on_updated_by_id", using: :btree

  create_table "otu_page_layout_sections", force: :cascade do |t|
    t.integer  "otu_page_layout_id",    null: false
    t.string   "type",                  null: false
    t.integer  "position",              null: false
    t.integer  "topic_id"
    t.string   "dynamic_content_class"
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "otu_page_layout_sections", ["created_by_id"], name: "index_otu_page_layout_sections_on_created_by_id", using: :btree
  add_index "otu_page_layout_sections", ["otu_page_layout_id"], name: "index_otu_page_layout_sections_on_otu_page_layout_id", using: :btree
  add_index "otu_page_layout_sections", ["position"], name: "index_otu_page_layout_sections_on_position", using: :btree
  add_index "otu_page_layout_sections", ["project_id"], name: "index_otu_page_layout_sections_on_project_id", using: :btree
  add_index "otu_page_layout_sections", ["topic_id"], name: "index_otu_page_layout_sections_on_topic_id", using: :btree
  add_index "otu_page_layout_sections", ["type"], name: "index_otu_page_layout_sections_on_type", using: :btree
  add_index "otu_page_layout_sections", ["updated_by_id"], name: "index_otu_page_layout_sections_on_updated_by_id", using: :btree

  create_table "otu_page_layouts", force: :cascade do |t|
    t.string   "name",          null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "otu_page_layouts", ["created_by_id"], name: "index_otu_page_layouts_on_created_by_id", using: :btree
  add_index "otu_page_layouts", ["project_id"], name: "index_otu_page_layouts_on_project_id", using: :btree
  add_index "otu_page_layouts", ["updated_by_id"], name: "index_otu_page_layouts_on_updated_by_id", using: :btree

  create_table "otus", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.integer  "taxon_name_id"
  end

  add_index "otus", ["created_by_id"], name: "index_otus_on_created_by_id", using: :btree
  add_index "otus", ["project_id"], name: "index_otus_on_project_id", using: :btree
  add_index "otus", ["taxon_name_id"], name: "index_otus_on_taxon_name_id", using: :btree
  add_index "otus", ["updated_by_id"], name: "index_otus_on_updated_by_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "type",          null: false
    t.string   "last_name",     null: false
    t.string   "first_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "suffix"
    t.string   "prefix"
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.text     "cached"
  end

  add_index "people", ["created_by_id"], name: "index_people_on_created_by_id", using: :btree
  add_index "people", ["type"], name: "index_people_on_type", using: :btree
  add_index "people", ["updated_by_id"], name: "index_people_on_updated_by_id", using: :btree

  create_table "pinboard_items", force: :cascade do |t|
    t.integer  "pinned_object_id",   null: false
    t.string   "pinned_object_type", null: false
    t.integer  "user_id",            null: false
    t.integer  "project_id",         null: false
    t.integer  "position",           null: false
    t.boolean  "is_inserted"
    t.boolean  "is_cross_project"
    t.integer  "inserted_count"
    t.integer  "created_by_id",      null: false
    t.integer  "updated_by_id",      null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "pinboard_items", ["created_by_id"], name: "index_pinboard_items_on_created_by_id", using: :btree
  add_index "pinboard_items", ["pinned_object_type", "pinned_object_id"], name: "index_pinboard_items_on_pinned_object_type_and_pinned_object_id", using: :btree
  add_index "pinboard_items", ["position"], name: "index_pinboard_items_on_position", using: :btree
  add_index "pinboard_items", ["project_id"], name: "index_pinboard_items_on_project_id", using: :btree
  add_index "pinboard_items", ["updated_by_id"], name: "index_pinboard_items_on_updated_by_id", using: :btree
  add_index "pinboard_items", ["user_id"], name: "index_pinboard_items_on_user_id", using: :btree

  create_table "preparation_types", force: :cascade do |t|
    t.string   "name",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.text     "definition",    null: false
  end

  add_index "preparation_types", ["created_by_id"], name: "index_preparation_types_on_created_by_id", using: :btree
  add_index "preparation_types", ["updated_by_id"], name: "index_preparation_types_on_updated_by_id", using: :btree

  create_table "project_members", force: :cascade do |t|
    t.integer  "project_id",               null: false
    t.integer  "user_id",                  null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "created_by_id",            null: false
    t.integer  "updated_by_id",            null: false
    t.boolean  "is_project_administrator"
  end

  add_index "project_members", ["created_by_id"], name: "index_project_members_on_created_by_id", using: :btree
  add_index "project_members", ["project_id"], name: "index_project_members_on_project_id", using: :btree
  add_index "project_members", ["updated_by_id"], name: "index_project_members_on_updated_by_id", using: :btree
  add_index "project_members", ["user_id"], name: "index_project_members_on_user_id", using: :btree

  create_table "project_sources", force: :cascade do |t|
    t.integer  "project_id",    null: false
    t.integer  "source_id",     null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "project_sources", ["created_by_id"], name: "index_project_sources_on_created_by_id", using: :btree
  add_index "project_sources", ["project_id"], name: "index_project_sources_on_project_id", using: :btree
  add_index "project_sources", ["source_id"], name: "index_project_sources_on_source_id", using: :btree
  add_index "project_sources", ["updated_by_id"], name: "index_project_sources_on_updated_by_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",               null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "created_by_id",      null: false
    t.integer  "updated_by_id",      null: false
    t.hstore   "workbench_settings", null: false
  end

  add_index "projects", ["created_by_id"], name: "index_projects_on_created_by_id", using: :btree
  add_index "projects", ["updated_by_id"], name: "index_projects_on_updated_by_id", using: :btree

  create_table "protocol_relationships", force: :cascade do |t|
    t.integer  "protocol_id",                       null: false
    t.integer  "protocol_relationship_object_id",   null: false
    t.string   "protocol_relationship_object_type", null: false
    t.integer  "position",                          null: false
    t.integer  "created_by_id",                     null: false
    t.integer  "updated_by_id",                     null: false
    t.integer  "project_id",                        null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "protocol_relationships", ["project_id"], name: "index_protocol_relationships_on_project_id", using: :btree
  add_index "protocol_relationships", ["protocol_id"], name: "index_protocol_relationships_on_protocol_id", using: :btree

  create_table "protocols", force: :cascade do |t|
    t.string   "name",          null: false
    t.text     "short_name",    null: false
    t.text     "description",   null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "protocols", ["project_id"], name: "index_protocols_on_project_id", using: :btree

  create_table "public_contents", force: :cascade do |t|
    t.integer  "otu_id",        null: false
    t.integer  "topic_id",      null: false
    t.text     "text",          null: false
    t.integer  "project_id",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "content_id",    null: false
  end

  add_index "public_contents", ["content_id"], name: "index_public_contents_on_content_id", using: :btree
  add_index "public_contents", ["created_by_id"], name: "index_public_contents_on_created_by_id", using: :btree
  add_index "public_contents", ["otu_id"], name: "index_public_contents_on_otu_id", using: :btree
  add_index "public_contents", ["project_id"], name: "index_public_contents_on_project_id", using: :btree
  add_index "public_contents", ["topic_id"], name: "index_public_contents_on_topic_id", using: :btree
  add_index "public_contents", ["updated_by_id"], name: "index_public_contents_on_updated_by_id", using: :btree

  create_table "ranged_lot_categories", force: :cascade do |t|
    t.string   "name",          null: false
    t.integer  "minimum_value", null: false
    t.integer  "maximum_value"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
  end

  add_index "ranged_lot_categories", ["created_by_id"], name: "index_ranged_lot_categories_on_created_by_id", using: :btree
  add_index "ranged_lot_categories", ["project_id"], name: "index_ranged_lot_categories_on_project_id", using: :btree
  add_index "ranged_lot_categories", ["updated_by_id"], name: "index_ranged_lot_categories_on_updated_by_id", using: :btree

  create_table "repositories", force: :cascade do |t|
    t.string   "name",                 null: false
    t.string   "url"
    t.string   "acronym"
    t.string   "status"
    t.string   "institutional_LSID"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "created_by_id",        null: false
    t.integer  "updated_by_id",        null: false
    t.boolean  "is_index_herbariorum"
  end

  add_index "repositories", ["created_by_id"], name: "index_repositories_on_created_by_id", using: :btree
  add_index "repositories", ["updated_by_id"], name: "index_repositories_on_updated_by_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.integer  "person_id",        null: false
    t.string   "type",             null: false
    t.integer  "role_object_id",   null: false
    t.string   "role_object_type", null: false
    t.integer  "position",         null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "created_by_id",    null: false
    t.integer  "updated_by_id",    null: false
    t.integer  "project_id"
  end

  add_index "roles", ["created_by_id"], name: "index_roles_on_created_by_id", using: :btree
  add_index "roles", ["person_id"], name: "index_roles_on_person_id", using: :btree
  add_index "roles", ["position"], name: "index_roles_on_position", using: :btree
  add_index "roles", ["project_id"], name: "index_roles_on_project_id", using: :btree
  add_index "roles", ["role_object_id", "role_object_type"], name: "index_roles_on_role_object_id_and_type", using: :btree
  add_index "roles", ["type"], name: "index_roles_on_type", using: :btree
  add_index "roles", ["updated_by_id"], name: "index_roles_on_updated_by_id", using: :btree

  create_table "serial_chronologies", force: :cascade do |t|
    t.integer  "preceding_serial_id",  null: false
    t.integer  "succeeding_serial_id", null: false
    t.integer  "created_by_id",        null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "updated_by_id",        null: false
    t.string   "type",                 null: false
  end

  add_index "serial_chronologies", ["created_by_id"], name: "index_serial_chronologies_on_created_by_id", using: :btree
  add_index "serial_chronologies", ["preceding_serial_id"], name: "index_serial_chronologies_on_preceding_serial_id", using: :btree
  add_index "serial_chronologies", ["succeeding_serial_id"], name: "index_serial_chronologies_on_succeeding_serial_id", using: :btree
  add_index "serial_chronologies", ["type"], name: "index_serial_chronologies_on_type", using: :btree
  add_index "serial_chronologies", ["updated_by_id"], name: "index_serial_chronologies_on_updated_by_id", using: :btree

  create_table "serials", force: :cascade do |t|
    t.integer  "created_by_id",                       null: false
    t.integer  "updated_by_id",                       null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "place_published"
    t.integer  "primary_language_id"
    t.integer  "first_year_of_issue",       limit: 2
    t.integer  "last_year_of_issue",        limit: 2
    t.integer  "translated_from_serial_id"
    t.text     "publisher"
    t.text     "name",                                null: false
  end

  add_index "serials", ["created_by_id"], name: "index_serials_on_created_by_id", using: :btree
  add_index "serials", ["primary_language_id"], name: "index_serials_on_primary_language_id", using: :btree
  add_index "serials", ["translated_from_serial_id"], name: "index_serials_on_translated_from_serial_id", using: :btree
  add_index "serials", ["updated_by_id"], name: "index_serials_on_updated_by_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.integer  "serial_id"
    t.string   "address"
    t.string   "annote"
    t.string   "booktitle"
    t.string   "chapter"
    t.string   "crossref"
    t.string   "edition"
    t.string   "editor"
    t.string   "howpublished"
    t.string   "institution"
    t.string   "journal"
    t.string   "key"
    t.string   "month"
    t.string   "note"
    t.string   "number"
    t.string   "organization"
    t.string   "pages"
    t.string   "publisher"
    t.string   "school"
    t.string   "series"
    t.text     "title"
    t.string   "type",                               null: false
    t.string   "volume"
    t.string   "doi"
    t.text     "abstract"
    t.text     "copyright"
    t.string   "language"
    t.string   "stated_year"
    t.string   "verbatim"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "bibtex_type"
    t.integer  "created_by_id",                      null: false
    t.integer  "updated_by_id",                      null: false
    t.integer  "day",                      limit: 2
    t.integer  "year",                     limit: 2
    t.string   "isbn"
    t.string   "issn"
    t.text     "verbatim_contents"
    t.text     "verbatim_keywords"
    t.integer  "language_id"
    t.string   "translator"
    t.string   "year_suffix"
    t.string   "url"
    t.text     "author"
    t.text     "cached"
    t.text     "cached_author_string"
    t.date     "cached_nomenclature_date"
  end

  add_index "sources", ["bibtex_type"], name: "index_sources_on_bibtex_type", using: :btree
  add_index "sources", ["created_by_id"], name: "index_sources_on_created_by_id", using: :btree
  add_index "sources", ["language_id"], name: "index_sources_on_language_id", using: :btree
  add_index "sources", ["serial_id"], name: "index_sources_on_serial_id", using: :btree
  add_index "sources", ["type"], name: "index_sources_on_type", using: :btree
  add_index "sources", ["updated_by_id"], name: "index_sources_on_updated_by_id", using: :btree

  create_table "sqed_depictions", force: :cascade do |t|
    t.integer  "depiction_id",                null: false
    t.string   "boundary_color",              null: false
    t.string   "boundary_finder",             null: false
    t.boolean  "has_border",                  null: false
    t.string   "layout",                      null: false
    t.hstore   "metadata_map",                null: false
    t.hstore   "specimen_coordinates"
    t.integer  "project_id",                  null: false
    t.integer  "created_by_id",               null: false
    t.integer  "updated_by_id",               null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.json     "result_boundary_coordinates"
    t.json     "result_ocr"
  end

  add_index "sqed_depictions", ["depiction_id"], name: "index_sqed_depictions_on_depiction_id", using: :btree
  add_index "sqed_depictions", ["project_id"], name: "index_sqed_depictions_on_project_id", using: :btree

  create_table "tagged_section_keywords", force: :cascade do |t|
    t.integer  "otu_page_layout_section_id", null: false
    t.integer  "position",                   null: false
    t.integer  "created_by_id",              null: false
    t.integer  "updated_by_id",              null: false
    t.integer  "project_id",                 null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "keyword_id",                 null: false
  end

  add_index "tagged_section_keywords", ["created_by_id"], name: "index_tagged_section_keywords_on_created_by_id", using: :btree
  add_index "tagged_section_keywords", ["keyword_id"], name: "index_tagged_section_keywords_on_keyword_id", using: :btree
  add_index "tagged_section_keywords", ["otu_page_layout_section_id"], name: "index_tagged_section_keywords_on_otu_page_layout_section_id", using: :btree
  add_index "tagged_section_keywords", ["position"], name: "index_tagged_section_keywords_on_position", using: :btree
  add_index "tagged_section_keywords", ["project_id"], name: "index_tagged_section_keywords_on_project_id", using: :btree
  add_index "tagged_section_keywords", ["updated_by_id"], name: "index_tagged_section_keywords_on_updated_by_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "keyword_id",           null: false
    t.integer  "tag_object_id",        null: false
    t.string   "tag_object_type",      null: false
    t.string   "tag_object_attribute"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "created_by_id",        null: false
    t.integer  "updated_by_id",        null: false
    t.integer  "project_id",           null: false
    t.integer  "position",             null: false
  end

  add_index "tags", ["created_by_id"], name: "index_tags_on_created_by_id", using: :btree
  add_index "tags", ["keyword_id"], name: "index_tags_on_keyword_id", using: :btree
  add_index "tags", ["position"], name: "index_tags_on_position", using: :btree
  add_index "tags", ["project_id"], name: "index_tags_on_project_id", using: :btree
  add_index "tags", ["tag_object_id", "tag_object_type"], name: "index_tags_on_tag_object_id_and_type", using: :btree
  add_index "tags", ["updated_by_id"], name: "index_tags_on_updated_by_id", using: :btree

  create_table "taxon_determinations", force: :cascade do |t|
    t.integer  "biological_collection_object_id", null: false
    t.integer  "otu_id",                          null: false
    t.integer  "position",                        null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "created_by_id",                   null: false
    t.integer  "updated_by_id",                   null: false
    t.integer  "project_id",                      null: false
    t.integer  "year_made"
    t.integer  "month_made"
    t.integer  "day_made"
  end

  add_index "taxon_determinations", ["biological_collection_object_id"], name: "index_taxon_determinations_on_biological_collection_object_id", using: :btree
  add_index "taxon_determinations", ["created_by_id"], name: "index_taxon_determinations_on_created_by_id", using: :btree
  add_index "taxon_determinations", ["otu_id"], name: "index_taxon_determinations_on_otu_id", using: :btree
  add_index "taxon_determinations", ["position"], name: "index_taxon_determinations_on_position", using: :btree
  add_index "taxon_determinations", ["project_id"], name: "index_taxon_determinations_on_project_id", using: :btree
  add_index "taxon_determinations", ["updated_by_id"], name: "index_taxon_determinations_on_updated_by_id", using: :btree

  create_table "taxon_name_classifications", force: :cascade do |t|
    t.integer  "taxon_name_id", null: false
    t.string   "type",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
  end

  add_index "taxon_name_classifications", ["created_by_id"], name: "index_taxon_name_classifications_on_created_by_id", using: :btree
  add_index "taxon_name_classifications", ["project_id"], name: "index_taxon_name_classifications_on_project_id", using: :btree
  add_index "taxon_name_classifications", ["taxon_name_id"], name: "index_taxon_name_classifications_on_taxon_name_id", using: :btree
  add_index "taxon_name_classifications", ["type"], name: "index_taxon_name_classifications_on_type", using: :btree
  add_index "taxon_name_classifications", ["updated_by_id"], name: "index_taxon_name_classifications_on_updated_by_id", using: :btree

  create_table "taxon_name_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "taxon_name_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "taxon_name_anc_desc_idx", unique: true, using: :btree
  add_index "taxon_name_hierarchies", ["descendant_id"], name: "taxon_name_desc_idx", using: :btree

  create_table "taxon_name_relationships", force: :cascade do |t|
    t.integer  "subject_taxon_name_id", null: false
    t.integer  "object_taxon_name_id",  null: false
    t.string   "type",                  null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
  end

  add_index "taxon_name_relationships", ["created_by_id"], name: "index_taxon_name_relationships_on_created_by_id", using: :btree
  add_index "taxon_name_relationships", ["object_taxon_name_id"], name: "index_taxon_name_relationships_on_object_taxon_name_id", using: :btree
  add_index "taxon_name_relationships", ["project_id"], name: "index_taxon_name_relationships_on_project_id", using: :btree
  add_index "taxon_name_relationships", ["subject_taxon_name_id"], name: "index_taxon_name_relationships_on_subject_taxon_name_id", using: :btree
  add_index "taxon_name_relationships", ["type"], name: "index_taxon_name_relationships_on_type", using: :btree
  add_index "taxon_name_relationships", ["updated_by_id"], name: "index_taxon_name_relationships_on_updated_by_id", using: :btree

  create_table "taxon_names", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "cached_html",                                   null: false
    t.string   "cached_author_year"
    t.string   "cached_higher_classification"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "year_of_publication"
    t.string   "verbatim_author"
    t.string   "rank_class"
    t.string   "type",                                          null: false
    t.integer  "created_by_id",                                 null: false
    t.integer  "updated_by_id",                                 null: false
    t.integer  "project_id",                                    null: false
    t.string   "cached_original_combination"
    t.string   "cached_secondary_homonym"
    t.string   "cached_primary_homonym"
    t.string   "cached_secondary_homonym_alternative_spelling"
    t.string   "cached_primary_homonym_alternative_spelling"
    t.boolean  "cached_misspelling"
    t.string   "masculine_name"
    t.string   "feminine_name"
    t.string   "neuter_name"
    t.string   "cached_classified_as"
    t.string   "cached"
    t.string   "verbatim_name"
    t.integer  "cached_valid_taxon_name_id"
  end

  add_index "taxon_names", ["created_by_id"], name: "index_taxon_names_on_created_by_id", using: :btree
  add_index "taxon_names", ["name"], name: "index_taxon_names_on_name", using: :btree
  add_index "taxon_names", ["parent_id"], name: "index_taxon_names_on_parent_id", using: :btree
  add_index "taxon_names", ["project_id"], name: "index_taxon_names_on_project_id", using: :btree
  add_index "taxon_names", ["type"], name: "index_taxon_names_on_type", using: :btree
  add_index "taxon_names", ["updated_by_id"], name: "index_taxon_names_on_updated_by_id", using: :btree

  create_table "test_classes", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "string"
    t.boolean  "boolean"
    t.text     "text"
    t.integer  "integer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "sti_id"
    t.string   "sti_type"
  end

  add_index "test_classes", ["created_by_id"], name: "index_test_classes_on_created_by_id", using: :btree
  add_index "test_classes", ["project_id"], name: "index_test_classes_on_project_id", using: :btree
  add_index "test_classes", ["updated_by_id"], name: "index_test_classes_on_updated_by_id", using: :btree

  create_table "type_materials", force: :cascade do |t|
    t.integer  "protonym_id",          null: false
    t.integer  "biological_object_id", null: false
    t.string   "type_type",            null: false
    t.integer  "created_by_id",        null: false
    t.integer  "updated_by_id",        null: false
    t.integer  "project_id",           null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "type_materials", ["biological_object_id"], name: "index_type_materials_on_biological_object_id", using: :btree
  add_index "type_materials", ["created_by_id"], name: "index_type_materials_on_created_by_id", using: :btree
  add_index "type_materials", ["project_id"], name: "index_type_materials_on_project_id", using: :btree
  add_index "type_materials", ["protonym_id"], name: "index_type_materials_on_protonym_id", using: :btree
  add_index "type_materials", ["type_type"], name: "index_type_materials_on_type_type", using: :btree
  add_index "type_materials", ["updated_by_id"], name: "index_type_materials_on_updated_by_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                                         null: false
    t.string   "password_digest",                               null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "remember_token"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.boolean  "is_administrator"
    t.string   "password_reset_token"
    t.datetime "password_reset_token_date"
    t.string   "name",                                          null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.text     "hub_tab_order",                 default: [],                 array: true
    t.string   "api_access_token"
    t.boolean  "is_flagged_for_password_reset", default: false
    t.json     "footprints",                    default: {}
    t.integer  "sign_in_count",                 default: 0
    t.json     "hub_favorites"
  end

  add_index "users", ["created_by_id"], name: "index_users_on_created_by_id", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["updated_by_id"], name: "index_users_on_updated_by_id", using: :btree

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at",     null: false
    t.integer  "transaction_id"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree

  add_foreign_key "alternate_values", "languages", name: "alternate_values_language_id_fkey"
  add_foreign_key "alternate_values", "projects", name: "alternate_values_project_id_fkey"
  add_foreign_key "alternate_values", "users", column: "created_by_id", name: "alternate_values_created_by_id_fkey"
  add_foreign_key "alternate_values", "users", column: "updated_by_id", name: "alternate_values_updated_by_id_fkey"
  add_foreign_key "asserted_distributions", "geographic_areas", name: "asserted_distributions_geographic_area_id_fkey"
  add_foreign_key "asserted_distributions", "otus", name: "asserted_distributions_otu_id_fkey"
  add_foreign_key "asserted_distributions", "projects", name: "asserted_distributions_project_id_fkey"
  add_foreign_key "asserted_distributions", "users", column: "created_by_id", name: "asserted_distributions_created_by_id_fkey"
  add_foreign_key "asserted_distributions", "users", column: "updated_by_id", name: "asserted_distributions_updated_by_id_fkey"
  add_foreign_key "biocuration_classifications", "collection_objects", column: "biological_collection_object_id", name: "biocuration_classifications_biological_collection_object_i_fkey"
  add_foreign_key "biocuration_classifications", "controlled_vocabulary_terms", column: "biocuration_class_id", name: "biocuration_classifications_biocuration_class_id_fkey"
  add_foreign_key "biocuration_classifications", "projects", name: "biocuration_classifications_project_id_fkey"
  add_foreign_key "biocuration_classifications", "users", column: "created_by_id", name: "biocuration_classifications_created_by_id_fkey"
  add_foreign_key "biocuration_classifications", "users", column: "updated_by_id", name: "biocuration_classifications_updated_by_id_fkey"
  add_foreign_key "biological_associations", "biological_relationships", name: "biological_associations_biological_relationship_id_fkey"
  add_foreign_key "biological_associations", "projects", name: "biological_associations_project_id_fkey"
  add_foreign_key "biological_associations", "users", column: "created_by_id", name: "biological_associations_created_by_id_fkey"
  add_foreign_key "biological_associations", "users", column: "updated_by_id", name: "biological_associations_updated_by_id_fkey"
  add_foreign_key "biological_associations_biological_associations_graphs", "biological_associations", name: "biological_associations_biologic_biological_association_id_fkey"
  add_foreign_key "biological_associations_biological_associations_graphs", "biological_associations_graphs", name: "biological_associations_biolo_biological_associations_grap_fkey"
  add_foreign_key "biological_associations_biological_associations_graphs", "projects", name: "biological_associations_biological_associations_project_id_fkey"
  add_foreign_key "biological_associations_biological_associations_graphs", "users", column: "created_by_id", name: "biological_associations_biological_associati_created_by_id_fkey"
  add_foreign_key "biological_associations_biological_associations_graphs", "users", column: "updated_by_id", name: "biological_associations_biological_associati_updated_by_id_fkey"
  add_foreign_key "biological_associations_graphs", "projects", name: "biological_associations_graphs_project_id_fkey"
  add_foreign_key "biological_associations_graphs", "users", column: "created_by_id", name: "biological_associations_graphs_created_by_id_fkey"
  add_foreign_key "biological_associations_graphs", "users", column: "updated_by_id", name: "biological_associations_graphs_updated_by_id_fkey"
  add_foreign_key "biological_relationship_types", "biological_relationships", name: "biological_relationship_types_biological_relationship_id_fkey"
  add_foreign_key "biological_relationship_types", "controlled_vocabulary_terms", column: "biological_property_id", name: "biological_relationship_types_biological_property_id_fkey"
  add_foreign_key "biological_relationship_types", "projects", name: "biological_relationship_types_project_id_fkey"
  add_foreign_key "biological_relationship_types", "users", column: "created_by_id", name: "biological_relationship_types_created_by_id_fkey"
  add_foreign_key "biological_relationship_types", "users", column: "updated_by_id", name: "biological_relationship_types_updated_by_id_fkey"
  add_foreign_key "biological_relationships", "projects", name: "biological_relationships_project_id_fkey"
  add_foreign_key "biological_relationships", "users", column: "created_by_id", name: "biological_relationships_created_by_id_fkey"
  add_foreign_key "biological_relationships", "users", column: "updated_by_id", name: "biological_relationships_updated_by_id_fkey"
  add_foreign_key "citation_topics", "citations", name: "citation_topics_citation_id_fkey"
  add_foreign_key "citation_topics", "controlled_vocabulary_terms", column: "topic_id", name: "citation_topics_topic_id_fkey"
  add_foreign_key "citation_topics", "projects", name: "citation_topics_project_id_fkey"
  add_foreign_key "citation_topics", "users", column: "created_by_id", name: "citation_topics_created_by_id_fkey"
  add_foreign_key "citation_topics", "users", column: "updated_by_id", name: "citation_topics_updated_by_id_fkey"
  add_foreign_key "citations", "projects", name: "citations_project_id_fkey"
  add_foreign_key "citations", "sources", name: "citations_source_id_fkey"
  add_foreign_key "citations", "users", column: "created_by_id", name: "citations_created_by_id_fkey"
  add_foreign_key "citations", "users", column: "updated_by_id", name: "citations_updated_by_id_fkey"
  add_foreign_key "collecting_events", "geographic_areas", name: "collecting_events_geographic_area_id_fkey"
  add_foreign_key "collecting_events", "projects", name: "collecting_events_project_id_fkey"
  add_foreign_key "collecting_events", "users", column: "created_by_id", name: "collecting_events_created_by_id_fkey"
  add_foreign_key "collecting_events", "users", column: "updated_by_id", name: "collecting_events_updated_by_id_fkey"
  add_foreign_key "collection_objects", "collecting_events", name: "collection_objects_collecting_event_id_fkey"
  add_foreign_key "collection_objects", "preparation_types", name: "collection_objects_preparation_type_id_fkey"
  add_foreign_key "collection_objects", "projects", name: "collection_objects_project_id_fkey"
  add_foreign_key "collection_objects", "ranged_lot_categories", name: "collection_objects_ranged_lot_category_id_fkey"
  add_foreign_key "collection_objects", "repositories", name: "collection_objects_repository_id_fkey"
  add_foreign_key "collection_objects", "users", column: "created_by_id", name: "collection_objects_created_by_id_fkey"
  add_foreign_key "collection_objects", "users", column: "updated_by_id", name: "collection_objects_updated_by_id_fkey"
  add_foreign_key "collection_profiles", "containers", name: "collection_profiles_container_id_fkey"
  add_foreign_key "collection_profiles", "otus", name: "collection_profiles_otu_id_fkey"
  add_foreign_key "collection_profiles", "projects", name: "collection_profiles_project_id_fkey"
  add_foreign_key "collection_profiles", "users", column: "created_by_id", name: "collection_profiles_created_by_id_fkey"
  add_foreign_key "collection_profiles", "users", column: "updated_by_id", name: "collection_profiles_updated_by_id_fkey"
  add_foreign_key "common_names", "geographic_areas"
  add_foreign_key "common_names", "languages"
  add_foreign_key "common_names", "otus"
  add_foreign_key "common_names", "projects"
  add_foreign_key "common_names", "users", column: "created_by_id"
  add_foreign_key "common_names", "users", column: "updated_by_id"
  add_foreign_key "confidences", "controlled_vocabulary_terms", column: "confidence_level_id"
  add_foreign_key "confidences", "projects"
  add_foreign_key "confidences", "users", column: "created_by_id"
  add_foreign_key "confidences", "users", column: "updated_by_id"
  add_foreign_key "container_items", "projects", name: "container_items_project_id_fkey"
  add_foreign_key "container_items", "users", column: "created_by_id", name: "container_items_created_by_id_fkey"
  add_foreign_key "container_items", "users", column: "updated_by_id", name: "container_items_updated_by_id_fkey"
  add_foreign_key "container_labels", "containers", name: "container_labels_container_id_fkey"
  add_foreign_key "container_labels", "projects", name: "container_labels_project_id_fkey"
  add_foreign_key "container_labels", "users", column: "created_by_id", name: "container_labels_created_by_id_fkey"
  add_foreign_key "container_labels", "users", column: "updated_by_id", name: "container_labels_updated_by_id_fkey"
  add_foreign_key "containers", "projects", name: "containers_project_id_fkey"
  add_foreign_key "containers", "users", column: "created_by_id", name: "containers_created_by_id_fkey"
  add_foreign_key "containers", "users", column: "updated_by_id", name: "containers_updated_by_id_fkey"
  add_foreign_key "contents", "controlled_vocabulary_terms", column: "topic_id", name: "contents_topic_id_fkey"
  add_foreign_key "contents", "otus", name: "contents_otu_id_fkey"
  add_foreign_key "contents", "projects", name: "contents_project_id_fkey"
  add_foreign_key "contents", "users", column: "created_by_id", name: "contents_created_by_id_fkey"
  add_foreign_key "contents", "users", column: "updated_by_id", name: "contents_updated_by_id_fkey"
  add_foreign_key "controlled_vocabulary_terms", "projects", name: "controlled_vocabulary_terms_project_id_fkey"
  add_foreign_key "controlled_vocabulary_terms", "users", column: "created_by_id", name: "controlled_vocabulary_terms_created_by_id_fkey"
  add_foreign_key "controlled_vocabulary_terms", "users", column: "updated_by_id", name: "controlled_vocabulary_terms_updated_by_id_fkey"
  add_foreign_key "data_attributes", "controlled_vocabulary_terms", name: "data_attributes_controlled_vocabulary_term_id_fkey"
  add_foreign_key "data_attributes", "projects", name: "data_attributes_project_id_fkey"
  add_foreign_key "data_attributes", "users", column: "created_by_id", name: "data_attributes_created_by_id_fkey"
  add_foreign_key "data_attributes", "users", column: "updated_by_id", name: "data_attributes_updated_by_id_fkey"
  add_foreign_key "descriptors", "projects"
  add_foreign_key "descriptors", "users", column: "created_by_id"
  add_foreign_key "descriptors", "users", column: "updated_by_id"
  add_foreign_key "documentation", "documents"
  add_foreign_key "documentation", "projects"
  add_foreign_key "documentation", "users", column: "created_by_id"
  add_foreign_key "documentation", "users", column: "updated_by_id"
  add_foreign_key "documents", "users", column: "created_by_id"
  add_foreign_key "documents", "users", column: "updated_by_id"
  add_foreign_key "geographic_area_types", "users", column: "created_by_id", name: "geographic_area_types_created_by_id_fkey"
  add_foreign_key "geographic_area_types", "users", column: "updated_by_id", name: "geographic_area_types_updated_by_id_fkey"
  add_foreign_key "geographic_areas", "geographic_area_types", name: "geographic_areas_geographic_area_type_id_fkey"
  add_foreign_key "geographic_areas", "geographic_areas", column: "level0_id", name: "geographic_areas_level0_id_fkey"
  add_foreign_key "geographic_areas", "geographic_areas", column: "level1_id", name: "geographic_areas_level1_id_fkey"
  add_foreign_key "geographic_areas", "geographic_areas", column: "level2_id", name: "geographic_areas_level2_id_fkey"
  add_foreign_key "geographic_areas", "geographic_areas", column: "parent_id", name: "geographic_areas_parent_id_fkey"
  add_foreign_key "geographic_areas", "users", column: "created_by_id", name: "geographic_areas_created_by_id_fkey"
  add_foreign_key "geographic_areas", "users", column: "updated_by_id", name: "geographic_areas_updated_by_id_fkey"
  add_foreign_key "geographic_areas_geographic_items", "geographic_areas", name: "geographic_areas_geographic_items_geographic_area_id_fkey"
  add_foreign_key "geographic_areas_geographic_items", "geographic_items", name: "geographic_areas_geographic_items_geographic_item_id_fkey"
  add_foreign_key "geographic_items", "users", column: "created_by_id", name: "geographic_items_created_by_id_fkey"
  add_foreign_key "geographic_items", "users", column: "updated_by_id", name: "geographic_items_updated_by_id_fkey"
  add_foreign_key "georeferences", "collecting_events", name: "georeferences_collecting_event_id_fkey"
  add_foreign_key "georeferences", "geographic_items", column: "error_geographic_item_id", name: "georeferences_error_geographic_item_id_fkey"
  add_foreign_key "georeferences", "geographic_items", name: "georeferences_geographic_item_id_fkey"
  add_foreign_key "georeferences", "projects", name: "georeferences_project_id_fkey"
  add_foreign_key "georeferences", "users", column: "created_by_id", name: "georeferences_created_by_id_fkey"
  add_foreign_key "georeferences", "users", column: "updated_by_id", name: "georeferences_updated_by_id_fkey"
  add_foreign_key "identifiers", "namespaces", name: "identifiers_namespace_id_fkey"
  add_foreign_key "identifiers", "projects", name: "identifiers_project_id_fkey"
  add_foreign_key "identifiers", "users", column: "created_by_id", name: "identifiers_created_by_id_fkey"
  add_foreign_key "identifiers", "users", column: "updated_by_id", name: "identifiers_updated_by_id_fkey"
  add_foreign_key "images", "projects", name: "images_project_id_fkey"
  add_foreign_key "images", "users", column: "created_by_id", name: "images_created_by_id_fkey"
  add_foreign_key "images", "users", column: "updated_by_id", name: "images_updated_by_id_fkey"
  add_foreign_key "languages", "users", column: "created_by_id", name: "languages_created_by_id_fkey"
  add_foreign_key "languages", "users", column: "updated_by_id", name: "languages_updated_by_id_fkey"
  add_foreign_key "loan_items", "loans", name: "loan_items_loan_id_fkey"
  add_foreign_key "loan_items", "projects", name: "loan_items_project_id_fkey"
  add_foreign_key "loan_items", "users", column: "created_by_id", name: "loan_items_created_by_id_fkey"
  add_foreign_key "loan_items", "users", column: "updated_by_id", name: "loan_items_updated_by_id_fkey"
  add_foreign_key "loans", "projects", name: "loans_project_id_fkey"
  add_foreign_key "loans", "users", column: "created_by_id", name: "loans_created_by_id_fkey"
  add_foreign_key "loans", "users", column: "updated_by_id", name: "loans_updated_by_id_fkey"
  add_foreign_key "namespaces", "users", column: "created_by_id", name: "namespaces_created_by_id_fkey"
  add_foreign_key "namespaces", "users", column: "updated_by_id", name: "namespaces_updated_by_id_fkey"
  add_foreign_key "notes", "projects", name: "notes_project_id_fkey"
  add_foreign_key "notes", "users", column: "created_by_id", name: "notes_created_by_id_fkey"
  add_foreign_key "notes", "users", column: "updated_by_id", name: "notes_updated_by_id_fkey"
  add_foreign_key "origin_relationships", "projects"
  add_foreign_key "origin_relationships", "users", column: "created_by_id"
  add_foreign_key "origin_relationships", "users", column: "updated_by_id"
  add_foreign_key "otu_page_layout_sections", "controlled_vocabulary_terms", column: "topic_id", name: "otu_page_layout_sections_topic_id_fkey"
  add_foreign_key "otu_page_layout_sections", "otu_page_layouts", name: "otu_page_layout_sections_otu_page_layout_id_fkey"
  add_foreign_key "otu_page_layout_sections", "projects", name: "otu_page_layout_sections_project_id_fkey"
  add_foreign_key "otu_page_layout_sections", "users", column: "created_by_id", name: "otu_page_layout_sections_created_by_id_fkey"
  add_foreign_key "otu_page_layout_sections", "users", column: "updated_by_id", name: "otu_page_layout_sections_updated_by_id_fkey"
  add_foreign_key "otu_page_layouts", "projects", name: "otu_page_layouts_project_id_fkey"
  add_foreign_key "otu_page_layouts", "users", column: "created_by_id", name: "otu_page_layouts_created_by_id_fkey"
  add_foreign_key "otu_page_layouts", "users", column: "updated_by_id", name: "otu_page_layouts_updated_by_id_fkey"
  add_foreign_key "otus", "projects", name: "otus_project_id_fkey"
  add_foreign_key "otus", "taxon_names", name: "otus_taxon_name_id_fkey"
  add_foreign_key "otus", "users", column: "created_by_id", name: "otus_created_by_id_fkey"
  add_foreign_key "otus", "users", column: "updated_by_id", name: "otus_updated_by_id_fkey"
  add_foreign_key "people", "users", column: "created_by_id", name: "people_created_by_id_fkey"
  add_foreign_key "people", "users", column: "updated_by_id", name: "people_updated_by_id_fkey"
  add_foreign_key "pinboard_items", "projects", name: "pinboard_items_project_id_fkey"
  add_foreign_key "pinboard_items", "users", column: "created_by_id", name: "pinboard_items_created_by_id_fkey"
  add_foreign_key "pinboard_items", "users", column: "updated_by_id", name: "pinboard_items_updated_by_id_fkey"
  add_foreign_key "pinboard_items", "users", name: "pinboard_items_user_id_fkey"
  add_foreign_key "preparation_types", "users", column: "created_by_id", name: "preparation_types_created_by_id_fkey"
  add_foreign_key "preparation_types", "users", column: "updated_by_id", name: "preparation_types_updated_by_id_fkey"
  add_foreign_key "project_members", "projects", name: "project_members_project_id_fkey"
  add_foreign_key "project_members", "users", column: "created_by_id", name: "project_members_created_by_id_fkey"
  add_foreign_key "project_members", "users", column: "updated_by_id", name: "project_members_updated_by_id_fkey"
  add_foreign_key "project_members", "users", name: "project_members_user_id_fkey"
  add_foreign_key "project_sources", "projects", name: "project_sources_project_id_fkey"
  add_foreign_key "project_sources", "sources", name: "project_sources_source_id_fkey"
  add_foreign_key "project_sources", "users", column: "created_by_id", name: "project_sources_created_by_id_fkey"
  add_foreign_key "project_sources", "users", column: "updated_by_id", name: "project_sources_updated_by_id_fkey"
  add_foreign_key "projects", "users", column: "created_by_id", name: "projects_created_by_id_fkey"
  add_foreign_key "projects", "users", column: "updated_by_id", name: "projects_updated_by_id_fkey"
  add_foreign_key "protocol_relationships", "projects"
  add_foreign_key "protocol_relationships", "protocols"
  add_foreign_key "protocol_relationships", "users", column: "created_by_id"
  add_foreign_key "protocol_relationships", "users", column: "updated_by_id"
  add_foreign_key "protocols", "projects"
  add_foreign_key "protocols", "users", column: "created_by_id"
  add_foreign_key "protocols", "users", column: "updated_by_id"
  add_foreign_key "public_contents", "contents", name: "public_contents_content_id_fkey"
  add_foreign_key "public_contents", "controlled_vocabulary_terms", column: "topic_id", name: "public_contents_topic_id_fkey"
  add_foreign_key "public_contents", "otus", name: "public_contents_otu_id_fkey"
  add_foreign_key "public_contents", "projects", name: "public_contents_project_id_fkey"
  add_foreign_key "public_contents", "users", column: "created_by_id", name: "public_contents_created_by_id_fkey"
  add_foreign_key "public_contents", "users", column: "updated_by_id", name: "public_contents_updated_by_id_fkey"
  add_foreign_key "ranged_lot_categories", "projects", name: "ranged_lot_categories_project_id_fkey"
  add_foreign_key "ranged_lot_categories", "users", column: "created_by_id", name: "ranged_lot_categories_created_by_id_fkey"
  add_foreign_key "ranged_lot_categories", "users", column: "updated_by_id", name: "ranged_lot_categories_updated_by_id_fkey"
  add_foreign_key "repositories", "users", column: "created_by_id", name: "repositories_created_by_id_fkey"
  add_foreign_key "repositories", "users", column: "updated_by_id", name: "repositories_updated_by_id_fkey"
  add_foreign_key "roles", "people", name: "roles_person_id_fkey"
  add_foreign_key "roles", "projects", name: "roles_project_id_fkey"
  add_foreign_key "roles", "users", column: "created_by_id", name: "roles_created_by_id_fkey"
  add_foreign_key "roles", "users", column: "updated_by_id", name: "roles_updated_by_id_fkey"
  add_foreign_key "serial_chronologies", "serials", column: "preceding_serial_id", name: "serial_chronologies_preceding_serial_id_fkey"
  add_foreign_key "serial_chronologies", "serials", column: "succeeding_serial_id", name: "serial_chronologies_succeeding_serial_id_fkey"
  add_foreign_key "serial_chronologies", "users", column: "created_by_id", name: "serial_chronologies_created_by_id_fkey"
  add_foreign_key "serial_chronologies", "users", column: "updated_by_id", name: "serial_chronologies_updated_by_id_fkey"
  add_foreign_key "serials", "languages", column: "primary_language_id", name: "serials_primary_language_id_fkey"
  add_foreign_key "serials", "serials", column: "translated_from_serial_id", name: "serials_translated_from_serial_id_fkey"
  add_foreign_key "serials", "users", column: "created_by_id", name: "serials_created_by_id_fkey"
  add_foreign_key "serials", "users", column: "updated_by_id", name: "serials_updated_by_id_fkey"
  add_foreign_key "sources", "languages", name: "sources_language_id_fkey"
  add_foreign_key "sources", "serials", name: "sources_serial_id_fkey"
  add_foreign_key "sources", "users", column: "created_by_id", name: "sources_created_by_id_fkey"
  add_foreign_key "sources", "users", column: "updated_by_id", name: "sources_updated_by_id_fkey"
  add_foreign_key "sqed_depictions", "depictions"
  add_foreign_key "sqed_depictions", "projects"
  add_foreign_key "sqed_depictions", "users", column: "created_by_id"
  add_foreign_key "sqed_depictions", "users", column: "updated_by_id"
  add_foreign_key "tagged_section_keywords", "controlled_vocabulary_terms", column: "keyword_id", name: "tagged_section_keywords_keyword_id_fkey"
  add_foreign_key "tagged_section_keywords", "otu_page_layout_sections", name: "tagged_section_keywords_otu_page_layout_section_id_fkey"
  add_foreign_key "tagged_section_keywords", "projects", name: "tagged_section_keywords_project_id_fkey"
  add_foreign_key "tagged_section_keywords", "users", column: "created_by_id", name: "tagged_section_keywords_created_by_id_fkey"
  add_foreign_key "tagged_section_keywords", "users", column: "updated_by_id", name: "tagged_section_keywords_updated_by_id_fkey"
  add_foreign_key "tags", "controlled_vocabulary_terms", column: "keyword_id", name: "tags_keyword_id_fkey"
  add_foreign_key "tags", "projects", name: "tags_project_id_fkey"
  add_foreign_key "tags", "users", column: "created_by_id", name: "tags_created_by_id_fkey"
  add_foreign_key "tags", "users", column: "updated_by_id", name: "tags_updated_by_id_fkey"
  add_foreign_key "taxon_determinations", "collection_objects", column: "biological_collection_object_id", name: "taxon_determinations_biological_collection_object_id_fkey"
  add_foreign_key "taxon_determinations", "otus", name: "taxon_determinations_otu_id_fkey"
  add_foreign_key "taxon_determinations", "projects", name: "taxon_determinations_project_id_fkey"
  add_foreign_key "taxon_determinations", "users", column: "created_by_id", name: "taxon_determinations_created_by_id_fkey"
  add_foreign_key "taxon_determinations", "users", column: "updated_by_id", name: "taxon_determinations_updated_by_id_fkey"
  add_foreign_key "taxon_name_classifications", "projects", name: "taxon_name_classifications_project_id_fkey"
  add_foreign_key "taxon_name_classifications", "taxon_names", name: "taxon_name_classifications_taxon_name_id_fkey"
  add_foreign_key "taxon_name_classifications", "users", column: "created_by_id", name: "taxon_name_classifications_created_by_id_fkey"
  add_foreign_key "taxon_name_classifications", "users", column: "updated_by_id", name: "taxon_name_classifications_updated_by_id_fkey"
  add_foreign_key "taxon_name_relationships", "projects", name: "taxon_name_relationships_project_id_fkey"
  add_foreign_key "taxon_name_relationships", "taxon_names", column: "object_taxon_name_id", name: "taxon_name_relationships_object_taxon_name_id_fkey"
  add_foreign_key "taxon_name_relationships", "taxon_names", column: "subject_taxon_name_id", name: "taxon_name_relationships_subject_taxon_name_id_fkey"
  add_foreign_key "taxon_name_relationships", "users", column: "created_by_id", name: "taxon_name_relationships_created_by_id_fkey"
  add_foreign_key "taxon_name_relationships", "users", column: "updated_by_id", name: "taxon_name_relationships_updated_by_id_fkey"
  add_foreign_key "taxon_names", "projects", name: "taxon_names_project_id_fkey"
  add_foreign_key "taxon_names", "taxon_names", column: "parent_id", name: "taxon_names_parent_id_fkey"
  add_foreign_key "taxon_names", "users", column: "created_by_id", name: "taxon_names_created_by_id_fkey"
  add_foreign_key "taxon_names", "users", column: "updated_by_id", name: "taxon_names_updated_by_id_fkey"
  add_foreign_key "type_materials", "collection_objects", column: "biological_object_id", name: "type_materials_biological_object_id_fkey"
  add_foreign_key "type_materials", "projects", name: "type_materials_project_id_fkey"
  add_foreign_key "type_materials", "taxon_names", column: "protonym_id", name: "type_materials_protonym_id_fkey"
  add_foreign_key "type_materials", "users", column: "created_by_id", name: "type_materials_created_by_id_fkey"
  add_foreign_key "type_materials", "users", column: "updated_by_id", name: "type_materials_updated_by_id_fkey"
  add_foreign_key "users", "users", column: "created_by_id", name: "users_created_by_id_fkey"
  add_foreign_key "users", "users", column: "updated_by_id", name: "users_updated_by_id_fkey"
end
