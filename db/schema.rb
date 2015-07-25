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

ActiveRecord::Schema.define(version: 20150714214338) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "hstore"
  enable_extension "fuzzystrmatch"

  create_table "alternate_values", force: true do |t|
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

  add_index "alternate_values", ["alternate_value_object_id", "alternate_value_object_type"], :name => "index_alternate_values_on_alternate_value_object_id_and_type"
  add_index "alternate_values", ["created_by_id"], :name => "index_alternate_values_on_created_by_id"
  add_index "alternate_values", ["language_id"], :name => "index_alternate_values_on_language_id"
  add_index "alternate_values", ["project_id"], :name => "index_alternate_values_on_project_id"
  add_index "alternate_values", ["type"], :name => "index_alternate_values_on_type"
  add_index "alternate_values", ["updated_by_id"], :name => "index_alternate_values_on_updated_by_id"

  create_table "asserted_distributions", force: true do |t|
    t.integer  "otu_id",             null: false
    t.integer  "geographic_area_id", null: false
    t.integer  "source_id",          null: false
    t.integer  "project_id",         null: false
    t.integer  "created_by_id",      null: false
    t.integer  "updated_by_id",      null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.boolean  "is_absent"
  end

  add_index "asserted_distributions", ["created_by_id"], :name => "index_asserted_distributions_on_created_by_id"
  add_index "asserted_distributions", ["geographic_area_id"], :name => "index_asserted_distributions_on_geographic_area_id"
  add_index "asserted_distributions", ["otu_id"], :name => "index_asserted_distributions_on_otu_id"
  add_index "asserted_distributions", ["project_id"], :name => "index_asserted_distributions_on_project_id"
  add_index "asserted_distributions", ["source_id"], :name => "index_asserted_distributions_on_source_id"
  add_index "asserted_distributions", ["updated_by_id"], :name => "index_asserted_distributions_on_updated_by_id"

  create_table "biocuration_classifications", force: true do |t|
    t.integer  "biocuration_class_id",            null: false
    t.integer  "biological_collection_object_id", null: false
    t.integer  "position",                        null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "created_by_id",                   null: false
    t.integer  "updated_by_id",                   null: false
    t.integer  "project_id",                      null: false
  end

  add_index "biocuration_classifications", ["biocuration_class_id"], :name => "index_biocuration_classifications_on_biocuration_class_id"
  add_index "biocuration_classifications", ["biological_collection_object_id"], :name => "bio_c_bio_collection_object"
  add_index "biocuration_classifications", ["created_by_id"], :name => "index_biocuration_classifications_on_created_by_id"
  add_index "biocuration_classifications", ["position"], :name => "index_biocuration_classifications_on_position"
  add_index "biocuration_classifications", ["project_id"], :name => "index_biocuration_classifications_on_project_id"
  add_index "biocuration_classifications", ["updated_by_id"], :name => "index_biocuration_classifications_on_updated_by_id"

  create_table "biological_associations", force: true do |t|
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

  add_index "biological_associations", ["biological_association_object_id", "biological_association_object_type"], :name => "index_biological_associations_on_object_id_and_type"
  add_index "biological_associations", ["biological_association_subject_id", "biological_association_subject_type"], :name => "index_biological_associations_on_subject_id_and_type"
  add_index "biological_associations", ["biological_relationship_id"], :name => "index_biological_associations_on_biological_relationship_id"
  add_index "biological_associations", ["created_by_id"], :name => "index_biological_associations_on_created_by_id"
  add_index "biological_associations", ["project_id"], :name => "index_biological_associations_on_project_id"
  add_index "biological_associations", ["updated_by_id"], :name => "index_biological_associations_on_updated_by_id"

  create_table "biological_associations_biological_associations_graphs", force: true do |t|
    t.integer  "biological_associations_graph_id", null: false
    t.integer  "biological_association_id",        null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "created_by_id",                    null: false
    t.integer  "updated_by_id",                    null: false
    t.integer  "project_id",                       null: false
  end

  add_index "biological_associations_biological_associations_graphs", ["biological_association_id"], :name => "bio_asc_bio_asc_graph_bio_asc"
  add_index "biological_associations_biological_associations_graphs", ["biological_associations_graph_id"], :name => "bio_asc_bio_asc_graph_bio_asc_graph"
  add_index "biological_associations_biological_associations_graphs", ["created_by_id"], :name => "bio_asc_bio_asc_graph_created_by"
  add_index "biological_associations_biological_associations_graphs", ["project_id"], :name => "bio_asc_bio_asc_graph_project"
  add_index "biological_associations_biological_associations_graphs", ["updated_by_id"], :name => "bio_asc_bio_asc_graph_updated_by"

  create_table "biological_associations_graphs", force: true do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.string   "name"
    t.integer  "source_id"
  end

  add_index "biological_associations_graphs", ["created_by_id"], :name => "index_biological_associations_graphs_on_created_by_id"
  add_index "biological_associations_graphs", ["project_id"], :name => "index_biological_associations_graphs_on_project_id"
  add_index "biological_associations_graphs", ["source_id"], :name => "index_biological_associations_graphs_on_source_id"
  add_index "biological_associations_graphs", ["updated_by_id"], :name => "index_biological_associations_graphs_on_updated_by_id"

  create_table "biological_relationship_types", force: true do |t|
    t.string   "type",                       null: false
    t.integer  "biological_property_id",     null: false
    t.integer  "biological_relationship_id", null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "created_by_id",              null: false
    t.integer  "updated_by_id",              null: false
    t.integer  "project_id",                 null: false
  end

  add_index "biological_relationship_types", ["biological_property_id"], :name => "index_biological_relationship_types_on_biological_property_id"
  add_index "biological_relationship_types", ["biological_relationship_id"], :name => "bio_rel_type_bio_rel"
  add_index "biological_relationship_types", ["created_by_id"], :name => "bio_rel_type_created_by"
  add_index "biological_relationship_types", ["project_id"], :name => "bio_rel_type_project"
  add_index "biological_relationship_types", ["type"], :name => "index_biological_relationship_types_on_type"
  add_index "biological_relationship_types", ["updated_by_id"], :name => "bio_rel_type_updated_by"

  create_table "biological_relationships", force: true do |t|
    t.string   "name",          null: false
    t.boolean  "is_transitive"
    t.boolean  "is_reflexive"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
  end

  add_index "biological_relationships", ["created_by_id"], :name => "bio_rel_created_by"
  add_index "biological_relationships", ["project_id"], :name => "bio_rel_project"
  add_index "biological_relationships", ["updated_by_id"], :name => "bio_rel_updated_by"

  create_table "citation_topics", force: true do |t|
    t.integer  "topic_id",      null: false
    t.integer  "citation_id",   null: false
    t.string   "pages"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
  end

  add_index "citation_topics", ["citation_id"], :name => "index_citation_topics_on_citation_id"
  add_index "citation_topics", ["created_by_id"], :name => "index_citation_topics_on_created_by_id"
  add_index "citation_topics", ["project_id"], :name => "index_citation_topics_on_project_id"
  add_index "citation_topics", ["topic_id"], :name => "index_citation_topics_on_topic_id"
  add_index "citation_topics", ["updated_by_id"], :name => "index_citation_topics_on_updated_by_id"

  create_table "citations", force: true do |t|
    t.string   "citation_object_type", null: false
    t.integer  "source_id",            null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "created_by_id",        null: false
    t.integer  "updated_by_id",        null: false
    t.integer  "project_id",           null: false
    t.integer  "citation_object_id",   null: false
    t.string   "pages"
  end

  add_index "citations", ["citation_object_id"], :name => "index_citations_on_citation_object_id"
  add_index "citations", ["citation_object_type"], :name => "index_citations_on_citation_object_type"
  add_index "citations", ["created_by_id"], :name => "index_citations_on_created_by_id"
  add_index "citations", ["project_id"], :name => "index_citations_on_project_id"
  add_index "citations", ["source_id"], :name => "index_citations_on_source_id"
  add_index "citations", ["updated_by_id"], :name => "index_citations_on_updated_by_id"

  create_table "collecting_events", force: true do |t|
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
  end

  add_index "collecting_events", ["created_by_id"], :name => "index_collecting_events_on_created_by_id"
  add_index "collecting_events", ["geographic_area_id"], :name => "index_collecting_events_on_geographic_area_id"
  add_index "collecting_events", ["project_id"], :name => "index_collecting_events_on_project_id"
  add_index "collecting_events", ["updated_by_id"], :name => "index_collecting_events_on_updated_by_id"

  create_table "collection_object_observations", force: true do |t|
    t.text     "data",          null: false
    t.integer  "project_id",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "collection_object_observations", ["project_id"], :name => "index_collection_object_observations_on_project_id"

  create_table "collection_objects", force: true do |t|
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

  add_index "collection_objects", ["collecting_event_id"], :name => "index_collection_objects_on_collecting_event_id"
  add_index "collection_objects", ["created_by_id"], :name => "index_collection_objects_on_created_by_id"
  add_index "collection_objects", ["preparation_type_id"], :name => "index_collection_objects_on_preparation_type_id"
  add_index "collection_objects", ["project_id"], :name => "index_collection_objects_on_project_id"
  add_index "collection_objects", ["ranged_lot_category_id"], :name => "index_collection_objects_on_ranged_lot_category_id"
  add_index "collection_objects", ["repository_id"], :name => "index_collection_objects_on_repository_id"
  add_index "collection_objects", ["type"], :name => "index_collection_objects_on_type"
  add_index "collection_objects", ["updated_by_id"], :name => "index_collection_objects_on_updated_by_id"

  create_table "collection_profiles", force: true do |t|
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

  add_index "collection_profiles", ["collection_type"], :name => "index_collection_profiles_on_collection_type"
  add_index "collection_profiles", ["container_id"], :name => "index_collection_profiles_on_container_id"
  add_index "collection_profiles", ["created_by_id"], :name => "index_collection_profiles_on_created_by_id"
  add_index "collection_profiles", ["otu_id"], :name => "index_collection_profiles_on_otu_id"
  add_index "collection_profiles", ["project_id"], :name => "index_collection_profiles_on_project_id"
  add_index "collection_profiles", ["updated_by_id"], :name => "index_collection_profiles_on_updated_by_id"

  create_table "container_items", force: true do |t|
    t.integer  "container_id",          null: false
    t.integer  "position",              null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "contained_object_id",   null: false
    t.string   "contained_object_type", null: false
    t.string   "localization"
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
  end

  add_index "container_items", ["contained_object_id", "contained_object_type"], :name => "index_container_items_on_contained_object_id_and_type"
  add_index "container_items", ["container_id"], :name => "index_container_items_on_container_id"
  add_index "container_items", ["created_by_id"], :name => "index_container_items_on_created_by_id"
  add_index "container_items", ["position"], :name => "index_container_items_on_position"
  add_index "container_items", ["project_id"], :name => "index_container_items_on_project_id"
  add_index "container_items", ["updated_by_id"], :name => "index_container_items_on_updated_by_id"

  create_table "container_labels", force: true do |t|
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

  add_index "container_labels", ["container_id"], :name => "index_container_labels_on_container_id"
  add_index "container_labels", ["created_by_id"], :name => "index_container_labels_on_created_by_id"
  add_index "container_labels", ["position"], :name => "index_container_labels_on_position"
  add_index "container_labels", ["project_id"], :name => "index_container_labels_on_project_id"
  add_index "container_labels", ["updated_by_id"], :name => "index_container_labels_on_updated_by_id"

  create_table "containers", force: true do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "lft",           null: false
    t.integer  "rgt",           null: false
    t.integer  "parent_id"
    t.integer  "depth"
    t.string   "type",          null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.integer  "otu_id"
    t.string   "name"
    t.string   "disposition"
  end

  add_index "containers", ["created_by_id"], :name => "index_containers_on_created_by_id"
  add_index "containers", ["disposition"], :name => "index_containers_on_disposition"
  add_index "containers", ["lft"], :name => "index_containers_on_lft"
  add_index "containers", ["otu_id"], :name => "index_containers_on_otu_id"
  add_index "containers", ["parent_id"], :name => "index_containers_on_parent_id"
  add_index "containers", ["project_id"], :name => "index_containers_on_project_id"
  add_index "containers", ["rgt"], :name => "index_containers_on_rgt"
  add_index "containers", ["type"], :name => "index_containers_on_type"
  add_index "containers", ["updated_by_id"], :name => "index_containers_on_updated_by_id"

  create_table "contents", force: true do |t|
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

  add_index "contents", ["created_by_id"], :name => "index_contents_on_created_by_id"
  add_index "contents", ["otu_id"], :name => "index_contents_on_otu_id"
  add_index "contents", ["project_id"], :name => "index_contents_on_project_id"
  add_index "contents", ["revision_id"], :name => "index_contents_on_revision_id"
  add_index "contents", ["topic_id"], :name => "index_contents_on_topic_id"
  add_index "contents", ["updated_by_id"], :name => "index_contents_on_updated_by_id"

  create_table "controlled_vocabulary_terms", force: true do |t|
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
  end

  add_index "controlled_vocabulary_terms", ["created_by_id"], :name => "index_controlled_vocabulary_terms_on_created_by_id"
  add_index "controlled_vocabulary_terms", ["project_id"], :name => "index_controlled_vocabulary_terms_on_project_id"
  add_index "controlled_vocabulary_terms", ["type"], :name => "index_controlled_vocabulary_terms_on_type"
  add_index "controlled_vocabulary_terms", ["updated_by_id"], :name => "index_controlled_vocabulary_terms_on_updated_by_id"

  create_table "data_attributes", force: true do |t|
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

  add_index "data_attributes", ["attribute_subject_id", "attribute_subject_type"], :name => "index_data_attributes_on_attribute_subject_id_and_type"
  add_index "data_attributes", ["controlled_vocabulary_term_id"], :name => "index_data_attributes_on_controlled_vocabulary_term_id"
  add_index "data_attributes", ["created_by_id"], :name => "index_data_attributes_on_created_by_id"
  add_index "data_attributes", ["project_id"], :name => "index_data_attributes_on_project_id"
  add_index "data_attributes", ["type"], :name => "index_data_attributes_on_type"
  add_index "data_attributes", ["updated_by_id"], :name => "index_data_attributes_on_updated_by_id"

  create_table "depictions", force: true do |t|
    t.string   "depiction_object_type", null: false
    t.integer  "depiction_object_id",   null: false
    t.integer  "image_id",              null: false
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "depictions", ["image_id"], :name => "index_depictions_on_image_id"
  add_index "depictions", ["project_id"], :name => "index_depictions_on_project_id"

  create_table "derived_collection_objects", force: true do |t|
    t.integer  "collection_object_observation_id", null: false
    t.integer  "collection_object_id",             null: false
    t.integer  "position"
    t.integer  "project_id",                       null: false
    t.integer  "created_by_id",                    null: false
    t.integer  "updated_by_id",                    null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "derived_collection_objects", ["collection_object_id"], :name => "dco_collection_object"
  add_index "derived_collection_objects", ["collection_object_observation_id"], :name => "dco_collection_object_observation"
  add_index "derived_collection_objects", ["project_id"], :name => "index_derived_collection_objects_on_project_id"

  create_table "geographic_area_types", force: true do |t|
    t.string   "name",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
  end

  add_index "geographic_area_types", ["created_by_id"], :name => "index_geographic_area_types_on_created_by_id"
  add_index "geographic_area_types", ["name"], :name => "index_geographic_area_types_on_name"
  add_index "geographic_area_types", ["updated_by_id"], :name => "index_geographic_area_types_on_updated_by_id"

  create_table "geographic_areas", force: true do |t|
    t.string   "name",                    null: false
    t.integer  "level0_id"
    t.integer  "level1_id"
    t.integer  "level2_id"
    t.integer  "parent_id"
    t.integer  "geographic_area_type_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "iso_3166_a2"
    t.integer  "rgt",                     null: false
    t.integer  "lft",                     null: false
    t.string   "iso_3166_a3"
    t.string   "tdwgID"
    t.string   "data_origin",             null: false
    t.integer  "created_by_id",           null: false
    t.integer  "updated_by_id",           null: false
  end

  add_index "geographic_areas", ["created_by_id"], :name => "index_geographic_areas_on_created_by_id"
  add_index "geographic_areas", ["geographic_area_type_id"], :name => "index_geographic_areas_on_geographic_area_type_id"
  add_index "geographic_areas", ["level0_id"], :name => "index_geographic_areas_on_level0_id"
  add_index "geographic_areas", ["level1_id"], :name => "index_geographic_areas_on_level1_id"
  add_index "geographic_areas", ["level2_id"], :name => "index_geographic_areas_on_level2_id"
  add_index "geographic_areas", ["lft"], :name => "index_geographic_areas_on_lft"
  add_index "geographic_areas", ["name"], :name => "index_geographic_areas_on_name"
  add_index "geographic_areas", ["parent_id"], :name => "index_geographic_areas_on_parent_id"
  add_index "geographic_areas", ["rgt"], :name => "index_geographic_areas_on_rgt"
  add_index "geographic_areas", ["updated_by_id"], :name => "index_geographic_areas_on_updated_by_id"

  create_table "geographic_areas_geographic_items", force: true do |t|
    t.integer  "geographic_area_id", null: false
    t.integer  "geographic_item_id"
    t.string   "data_origin"
    t.integer  "origin_gid"
    t.string   "date_valid_from"
    t.string   "date_valid_to"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "geographic_areas_geographic_items", ["geographic_area_id"], :name => "index_geographic_areas_geographic_items_on_geographic_area_id"
  add_index "geographic_areas_geographic_items", ["geographic_item_id"], :name => "index_geographic_areas_geographic_items_on_geographic_item_id"

  create_table "geographic_items", force: true do |t|
    t.datetime "created_at",                                                                                             null: false
    t.datetime "updated_at",                                                                                             null: false
    t.st_point  "point", geographic: true, has_z: true
    t.line_string  "line_string", geographic: true, has_z: true
    t.st_polygon  "polygon", geographic: true, has_z: true
    t.multi_point  "multi_point", geographic: true, has_z: true
    t.multi_line_string  "multi_line_string", geographic: true, has_z: true
    t.multi_polygon  "multi_polygon", geographic: true, has_z: true
    t.geometry  "geometry_collection", geographic: true, has_z: true
    t.integer  "created_by_id",                                                                                          null: false
    t.integer  "updated_by_id",                                                                                          null: false
    t.string   "type",                                                                                                   null: false
  end

  add_index "geographic_items", ["created_by_id"], :name => "index_geographic_items_on_created_by_id"
  add_index "geographic_items", ["geometry_collection"], :name => "geometry_collection_gix", :using => :gist
  add_index "geographic_items", ["line_string"], :name => "line_string_gix", :using => :gist
  add_index "geographic_items", ["multi_line_string"], :name => "multi_line_string_gix", :using => :gist
  add_index "geographic_items", ["multi_point"], :name => "multi_point_gix", :using => :gist
  add_index "geographic_items", ["multi_polygon"], :name => "multi_polygon_gix", :using => :gist
  add_index "geographic_items", ["point"], :name => "point_gix", :using => :gist
  add_index "geographic_items", ["polygon"], :name => "polygon_gix", :using => :gist
  add_index "geographic_items", ["type"], :name => "index_geographic_items_on_type"
  add_index "geographic_items", ["updated_by_id"], :name => "index_geographic_items_on_updated_by_id"

  create_table "georeferences", force: true do |t|
    t.integer  "geographic_item_id",                       null: false
    t.integer  "collecting_event_id",                      null: false
    t.decimal  "error_radius"
    t.decimal  "error_depth"
    t.integer  "error_geographic_item_id"
    t.string   "type",                                     null: false
    t.integer  "source_id"
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

  add_index "georeferences", ["collecting_event_id"], :name => "index_georeferences_on_collecting_event_id"
  add_index "georeferences", ["created_by_id"], :name => "index_georeferences_on_created_by_id"
  add_index "georeferences", ["error_geographic_item_id"], :name => "index_georeferences_on_error_geographic_item_id"
  add_index "georeferences", ["geographic_item_id"], :name => "index_georeferences_on_geographic_item_id"
  add_index "georeferences", ["position"], :name => "index_georeferences_on_position"
  add_index "georeferences", ["project_id"], :name => "index_georeferences_on_project_id"
  add_index "georeferences", ["source_id"], :name => "index_georeferences_on_source_id"
  add_index "georeferences", ["type"], :name => "index_georeferences_on_type"
  add_index "georeferences", ["updated_by_id"], :name => "index_georeferences_on_updated_by_id"

  create_table "identifiers", force: true do |t|
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
  end

  add_index "identifiers", ["created_by_id"], :name => "index_identifiers_on_created_by_id"
  add_index "identifiers", ["identifier_object_id", "identifier_object_type"], :name => "index_identifiers_on_identifier_object_id_and_type"
  add_index "identifiers", ["namespace_id"], :name => "index_identifiers_on_namespace_id"
  add_index "identifiers", ["project_id"], :name => "index_identifiers_on_project_id"
  add_index "identifiers", ["type"], :name => "index_identifiers_on_type"
  add_index "identifiers", ["updated_by_id"], :name => "index_identifiers_on_updated_by_id"

  create_table "images", force: true do |t|
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

  add_index "images", ["created_by_id"], :name => "index_images_on_created_by_id"
  add_index "images", ["image_file_content_type"], :name => "index_images_on_image_file_content_type"
  add_index "images", ["project_id"], :name => "index_images_on_project_id"
  add_index "images", ["updated_by_id"], :name => "index_images_on_updated_by_id"

  create_table "imports", force: true do |t|
    t.string   "name"
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: true do |t|
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

  add_index "languages", ["created_by_id"], :name => "index_languages_on_created_by_id"
  add_index "languages", ["updated_by_id"], :name => "index_languages_on_updated_by_id"

  create_table "loan_items", force: true do |t|
    t.integer  "loan_id",                  null: false
    t.integer  "collection_object_id"
    t.date     "date_returned"
    t.string   "collection_object_status"
    t.integer  "position",                 null: false
    t.integer  "created_by_id",            null: false
    t.integer  "updated_by_id",            null: false
    t.integer  "project_id",               null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "container_id"
  end

  add_index "loan_items", ["collection_object_id"], :name => "index_loan_items_on_collection_object_id"
  add_index "loan_items", ["container_id"], :name => "index_loan_items_on_container_id"
  add_index "loan_items", ["created_by_id"], :name => "index_loan_items_on_created_by_id"
  add_index "loan_items", ["loan_id"], :name => "index_loan_items_on_loan_id"
  add_index "loan_items", ["position"], :name => "index_loan_items_on_position"
  add_index "loan_items", ["project_id"], :name => "index_loan_items_on_project_id"
  add_index "loan_items", ["updated_by_id"], :name => "index_loan_items_on_updated_by_id"

  create_table "loans", force: true do |t|
    t.date     "date_requested"
    t.string   "request_method"
    t.date     "date_sent"
    t.date     "date_received"
    t.date     "date_return_expected"
    t.integer  "recipient_person_id"
    t.string   "recipient_address"
    t.string   "recipient_email"
    t.string   "recipient_phone"
    t.integer  "recipient_country"
    t.string   "supervisor_email"
    t.string   "supervisor_phone"
    t.date     "date_closed"
    t.integer  "created_by_id",        null: false
    t.integer  "updated_by_id",        null: false
    t.integer  "project_id",           null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "recipient_honorarium"
    t.integer  "supervisor_person_id"
  end

  add_index "loans", ["created_by_id"], :name => "index_loans_on_created_by_id"
  add_index "loans", ["project_id"], :name => "index_loans_on_project_id"
  add_index "loans", ["recipient_person_id"], :name => "index_loans_on_recipient_person_id"
  add_index "loans", ["updated_by_id"], :name => "index_loans_on_updated_by_id"

  create_table "namespaces", force: true do |t|
    t.string   "institution"
    t.string   "name",                null: false
    t.string   "short_name",          null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "created_by_id",       null: false
    t.integer  "updated_by_id",       null: false
    t.string   "verbatim_short_name"
  end

  add_index "namespaces", ["created_by_id"], :name => "index_namespaces_on_created_by_id"
  add_index "namespaces", ["updated_by_id"], :name => "index_namespaces_on_updated_by_id"

  create_table "notes", force: true do |t|
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

  add_index "notes", ["created_by_id"], :name => "index_notes_on_created_by_id"
  add_index "notes", ["note_object_id", "note_object_type"], :name => "index_notes_on_note_object_id_and_type"
  add_index "notes", ["project_id"], :name => "index_notes_on_project_id"
  add_index "notes", ["updated_by_id"], :name => "index_notes_on_updated_by_id"

  create_table "otu_page_layout_sections", force: true do |t|
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

  add_index "otu_page_layout_sections", ["created_by_id"], :name => "index_otu_page_layout_sections_on_created_by_id"
  add_index "otu_page_layout_sections", ["otu_page_layout_id"], :name => "index_otu_page_layout_sections_on_otu_page_layout_id"
  add_index "otu_page_layout_sections", ["position"], :name => "index_otu_page_layout_sections_on_position"
  add_index "otu_page_layout_sections", ["project_id"], :name => "index_otu_page_layout_sections_on_project_id"
  add_index "otu_page_layout_sections", ["topic_id"], :name => "index_otu_page_layout_sections_on_topic_id"
  add_index "otu_page_layout_sections", ["type"], :name => "index_otu_page_layout_sections_on_type"
  add_index "otu_page_layout_sections", ["updated_by_id"], :name => "index_otu_page_layout_sections_on_updated_by_id"

  create_table "otu_page_layouts", force: true do |t|
    t.string   "name",          null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "otu_page_layouts", ["created_by_id"], :name => "index_otu_page_layouts_on_created_by_id"
  add_index "otu_page_layouts", ["project_id"], :name => "index_otu_page_layouts_on_project_id"
  add_index "otu_page_layouts", ["updated_by_id"], :name => "index_otu_page_layouts_on_updated_by_id"

  create_table "otus", force: true do |t|
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
    t.integer  "taxon_name_id"
  end

  add_index "otus", ["created_by_id"], :name => "index_otus_on_created_by_id"
  add_index "otus", ["project_id"], :name => "index_otus_on_project_id"
  add_index "otus", ["taxon_name_id"], :name => "index_otus_on_taxon_name_id"
  add_index "otus", ["updated_by_id"], :name => "index_otus_on_updated_by_id"

  create_table "people", force: true do |t|
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

  add_index "people", ["created_by_id"], :name => "index_people_on_created_by_id"
  add_index "people", ["type"], :name => "index_people_on_type"
  add_index "people", ["updated_by_id"], :name => "index_people_on_updated_by_id"

  create_table "pinboard_items", force: true do |t|
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

  add_index "pinboard_items", ["created_by_id"], :name => "index_pinboard_items_on_created_by_id"
  add_index "pinboard_items", ["pinned_object_id", "pinned_object_type"], :name => "index_pinboard_items_on_pinned_object_id_and_pinned_object_type"
  add_index "pinboard_items", ["position"], :name => "index_pinboard_items_on_position"
  add_index "pinboard_items", ["project_id"], :name => "index_pinboard_items_on_project_id"
  add_index "pinboard_items", ["updated_by_id"], :name => "index_pinboard_items_on_updated_by_id"
  add_index "pinboard_items", ["user_id"], :name => "index_pinboard_items_on_user_id"

  create_table "preparation_types", force: true do |t|
    t.string   "name",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.text     "definition",    null: false
  end

  add_index "preparation_types", ["created_by_id"], :name => "index_preparation_types_on_created_by_id"
  add_index "preparation_types", ["updated_by_id"], :name => "index_preparation_types_on_updated_by_id"

  create_table "project_members", force: true do |t|
    t.integer  "project_id",               null: false
    t.integer  "user_id",                  null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "created_by_id",            null: false
    t.integer  "updated_by_id",            null: false
    t.boolean  "is_project_administrator"
  end

  add_index "project_members", ["created_by_id"], :name => "index_project_members_on_created_by_id"
  add_index "project_members", ["project_id"], :name => "index_project_members_on_project_id"
  add_index "project_members", ["updated_by_id"], :name => "index_project_members_on_updated_by_id"
  add_index "project_members", ["user_id"], :name => "index_project_members_on_user_id"

  create_table "project_sources", force: true do |t|
    t.integer  "project_id"
    t.integer  "source_id",     null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "project_sources", ["created_by_id"], :name => "index_project_sources_on_created_by_id"
  add_index "project_sources", ["project_id"], :name => "index_project_sources_on_project_id"
  add_index "project_sources", ["source_id"], :name => "index_project_sources_on_source_id"
  add_index "project_sources", ["updated_by_id"], :name => "index_project_sources_on_updated_by_id"

  create_table "projects", force: true do |t|
    t.string   "name",               null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "created_by_id",      null: false
    t.integer  "updated_by_id",      null: false
    t.hstore   "workbench_settings", null: false
  end

  add_index "projects", ["created_by_id"], :name => "index_projects_on_created_by_id"
  add_index "projects", ["updated_by_id"], :name => "index_projects_on_updated_by_id"

  create_table "public_contents", force: true do |t|
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

  add_index "public_contents", ["content_id"], :name => "index_public_contents_on_content_id"
  add_index "public_contents", ["created_by_id"], :name => "index_public_contents_on_created_by_id"
  add_index "public_contents", ["otu_id"], :name => "index_public_contents_on_otu_id"
  add_index "public_contents", ["project_id"], :name => "index_public_contents_on_project_id"
  add_index "public_contents", ["topic_id"], :name => "index_public_contents_on_topic_id"
  add_index "public_contents", ["updated_by_id"], :name => "index_public_contents_on_updated_by_id"

  create_table "ranged_lot_categories", force: true do |t|
    t.string   "name",          null: false
    t.integer  "minimum_value", null: false
    t.integer  "maximum_value"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
  end

  add_index "ranged_lot_categories", ["created_by_id"], :name => "index_ranged_lot_categories_on_created_by_id"
  add_index "ranged_lot_categories", ["project_id"], :name => "index_ranged_lot_categories_on_project_id"
  add_index "ranged_lot_categories", ["updated_by_id"], :name => "index_ranged_lot_categories_on_updated_by_id"

  create_table "repositories", force: true do |t|
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

  add_index "repositories", ["created_by_id"], :name => "index_repositories_on_created_by_id"
  add_index "repositories", ["updated_by_id"], :name => "index_repositories_on_updated_by_id"

  create_table "roles", force: true do |t|
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

  add_index "roles", ["created_by_id"], :name => "index_roles_on_created_by_id"
  add_index "roles", ["person_id"], :name => "index_roles_on_person_id"
  add_index "roles", ["position"], :name => "index_roles_on_position"
  add_index "roles", ["project_id"], :name => "index_roles_on_project_id"
  add_index "roles", ["role_object_id", "role_object_type"], :name => "index_roles_on_role_object_id_and_type"
  add_index "roles", ["type"], :name => "index_roles_on_type"
  add_index "roles", ["updated_by_id"], :name => "index_roles_on_updated_by_id"

  create_table "serial_chronologies", force: true do |t|
    t.integer  "preceding_serial_id",  null: false
    t.integer  "succeeding_serial_id", null: false
    t.integer  "created_by_id",        null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "updated_by_id",        null: false
    t.string   "type",                 null: false
  end

  add_index "serial_chronologies", ["created_by_id"], :name => "index_serial_chronologies_on_created_by_id"
  add_index "serial_chronologies", ["preceding_serial_id"], :name => "index_serial_chronologies_on_preceding_serial_id"
  add_index "serial_chronologies", ["succeeding_serial_id"], :name => "index_serial_chronologies_on_succeeding_serial_id"
  add_index "serial_chronologies", ["type"], :name => "index_serial_chronologies_on_type"
  add_index "serial_chronologies", ["updated_by_id"], :name => "index_serial_chronologies_on_updated_by_id"

  create_table "serials", force: true do |t|
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

  add_index "serials", ["created_by_id"], :name => "index_serials_on_created_by_id"
  add_index "serials", ["primary_language_id"], :name => "index_serials_on_primary_language_id"
  add_index "serials", ["translated_from_serial_id"], :name => "index_serials_on_translated_from_serial_id"
  add_index "serials", ["updated_by_id"], :name => "index_serials_on_updated_by_id"

  create_table "sources", force: true do |t|
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
    t.string   "title"
    t.string   "type",                               null: false
    t.string   "volume"
    t.string   "doi"
    t.string   "abstract"
    t.string   "copyright"
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

  add_index "sources", ["bibtex_type"], :name => "index_sources_on_bibtex_type"
  add_index "sources", ["created_by_id"], :name => "index_sources_on_created_by_id"
  add_index "sources", ["language_id"], :name => "index_sources_on_language_id"
  add_index "sources", ["serial_id"], :name => "index_sources_on_serial_id"
  add_index "sources", ["type"], :name => "index_sources_on_type"
  add_index "sources", ["updated_by_id"], :name => "index_sources_on_updated_by_id"

  create_table "tagged_section_keywords", force: true do |t|
    t.integer  "otu_page_layout_section_id", null: false
    t.integer  "position",                   null: false
    t.integer  "created_by_id",              null: false
    t.integer  "updated_by_id",              null: false
    t.integer  "project_id",                 null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "keyword_id",                 null: false
  end

  add_index "tagged_section_keywords", ["created_by_id"], :name => "index_tagged_section_keywords_on_created_by_id"
  add_index "tagged_section_keywords", ["keyword_id"], :name => "index_tagged_section_keywords_on_keyword_id"
  add_index "tagged_section_keywords", ["otu_page_layout_section_id"], :name => "index_tagged_section_keywords_on_otu_page_layout_section_id"
  add_index "tagged_section_keywords", ["position"], :name => "index_tagged_section_keywords_on_position"
  add_index "tagged_section_keywords", ["project_id"], :name => "index_tagged_section_keywords_on_project_id"
  add_index "tagged_section_keywords", ["updated_by_id"], :name => "index_tagged_section_keywords_on_updated_by_id"

  create_table "tags", force: true do |t|
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

  add_index "tags", ["created_by_id"], :name => "index_tags_on_created_by_id"
  add_index "tags", ["keyword_id"], :name => "index_tags_on_keyword_id"
  add_index "tags", ["position"], :name => "index_tags_on_position"
  add_index "tags", ["project_id"], :name => "index_tags_on_project_id"
  add_index "tags", ["tag_object_id", "tag_object_type"], :name => "index_tags_on_tag_object_id_and_type"
  add_index "tags", ["updated_by_id"], :name => "index_tags_on_updated_by_id"

  create_table "taxon_determinations", force: true do |t|
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

  add_index "taxon_determinations", ["biological_collection_object_id"], :name => "index_taxon_determinations_on_biological_collection_object_id"
  add_index "taxon_determinations", ["created_by_id"], :name => "index_taxon_determinations_on_created_by_id"
  add_index "taxon_determinations", ["otu_id"], :name => "index_taxon_determinations_on_otu_id"
  add_index "taxon_determinations", ["position"], :name => "index_taxon_determinations_on_position"
  add_index "taxon_determinations", ["project_id"], :name => "index_taxon_determinations_on_project_id"
  add_index "taxon_determinations", ["updated_by_id"], :name => "index_taxon_determinations_on_updated_by_id"

  create_table "taxon_name_classifications", force: true do |t|
    t.integer  "taxon_name_id", null: false
    t.string   "type",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "created_by_id", null: false
    t.integer  "updated_by_id", null: false
    t.integer  "project_id",    null: false
  end

  add_index "taxon_name_classifications", ["created_by_id"], :name => "index_taxon_name_classifications_on_created_by_id"
  add_index "taxon_name_classifications", ["project_id"], :name => "index_taxon_name_classifications_on_project_id"
  add_index "taxon_name_classifications", ["taxon_name_id"], :name => "index_taxon_name_classifications_on_taxon_name_id"
  add_index "taxon_name_classifications", ["type"], :name => "index_taxon_name_classifications_on_type"
  add_index "taxon_name_classifications", ["updated_by_id"], :name => "index_taxon_name_classifications_on_updated_by_id"

  create_table "taxon_name_relationships", force: true do |t|
    t.integer  "subject_taxon_name_id", null: false
    t.integer  "object_taxon_name_id",  null: false
    t.string   "type",                  null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "created_by_id",         null: false
    t.integer  "updated_by_id",         null: false
    t.integer  "project_id",            null: false
    t.integer  "source_id"
  end

  add_index "taxon_name_relationships", ["created_by_id"], :name => "index_taxon_name_relationships_on_created_by_id"
  add_index "taxon_name_relationships", ["object_taxon_name_id"], :name => "index_taxon_name_relationships_on_object_taxon_name_id"
  add_index "taxon_name_relationships", ["project_id"], :name => "index_taxon_name_relationships_on_project_id"
  add_index "taxon_name_relationships", ["source_id"], :name => "index_taxon_name_relationships_on_source_id"
  add_index "taxon_name_relationships", ["subject_taxon_name_id"], :name => "index_taxon_name_relationships_on_subject_taxon_name_id"
  add_index "taxon_name_relationships", ["type"], :name => "index_taxon_name_relationships_on_type"
  add_index "taxon_name_relationships", ["updated_by_id"], :name => "index_taxon_name_relationships_on_updated_by_id"

  create_table "taxon_names", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "cached_html",                                   null: false
    t.string   "cached_author_year"
    t.string   "cached_higher_classification"
    t.integer  "lft",                                           null: false
    t.integer  "rgt",                                           null: false
    t.integer  "source_id"
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
    t.string   "cached",                                        null: false
    t.string   "verbatim_name"
  end

  add_index "taxon_names", ["created_by_id"], :name => "index_taxon_names_on_created_by_id"
  add_index "taxon_names", ["lft"], :name => "index_taxon_names_on_lft"
  add_index "taxon_names", ["name"], :name => "index_taxon_names_on_name"
  add_index "taxon_names", ["parent_id"], :name => "index_taxon_names_on_parent_id"
  add_index "taxon_names", ["project_id"], :name => "index_taxon_names_on_project_id"
  add_index "taxon_names", ["rgt"], :name => "index_taxon_names_on_rgt"
  add_index "taxon_names", ["source_id"], :name => "index_taxon_names_on_source_id"
  add_index "taxon_names", ["type"], :name => "index_taxon_names_on_type"
  add_index "taxon_names", ["updated_by_id"], :name => "index_taxon_names_on_updated_by_id"

  create_table "test_classes", force: true do |t|
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

  add_index "test_classes", ["created_by_id"], :name => "index_test_classes_on_created_by_id"
  add_index "test_classes", ["project_id"], :name => "index_test_classes_on_project_id"
  add_index "test_classes", ["updated_by_id"], :name => "index_test_classes_on_updated_by_id"

  create_table "type_materials", force: true do |t|
    t.integer  "protonym_id",          null: false
    t.integer  "biological_object_id", null: false
    t.string   "type_type",            null: false
    t.integer  "source_id"
    t.integer  "created_by_id",        null: false
    t.integer  "updated_by_id",        null: false
    t.integer  "project_id",           null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "type_materials", ["biological_object_id"], :name => "index_type_materials_on_biological_object_id"
  add_index "type_materials", ["created_by_id"], :name => "index_type_materials_on_created_by_id"
  add_index "type_materials", ["project_id"], :name => "index_type_materials_on_project_id"
  add_index "type_materials", ["protonym_id"], :name => "index_type_materials_on_protonym_id"
  add_index "type_materials", ["source_id"], :name => "index_type_materials_on_source_id"
  add_index "type_materials", ["type_type"], :name => "index_type_materials_on_type_type"
  add_index "type_materials", ["updated_by_id"], :name => "index_type_materials_on_updated_by_id"

  create_table "users", force: true do |t|
    t.string   "email",                                                      null: false
    t.string   "password_digest",                                            null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "remember_token"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.boolean  "is_administrator"
    t.string   "favorite_routes",               limit: 8191, default: [],                 array: true
    t.string   "password_reset_token"
    t.datetime "password_reset_token_date"
    t.string   "name",                                                       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.text     "hub_tab_order",                              default: [],                 array: true
    t.string   "api_access_token"
    t.boolean  "is_flagged_for_password_reset",              default: false
    t.json     "footprints",                                 default: {}
    t.integer  "sign_in_count",                              default: 0
  end

  add_index "users", ["created_by_id"], :name => "index_users_on_created_by_id"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["updated_by_id"], :name => "index_users_on_updated_by_id"

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at", null: false
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
