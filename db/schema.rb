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

ActiveRecord::Schema[8.1].define(version: 2025_12_15_142258) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "fuzzystrmatch"
  enable_extension "hstore"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "postgis"
  enable_extension "postgis_raster"
  enable_extension "tablefunc"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alternate_values", id: :serial, force: :cascade do |t|
    t.string "alternate_value_object_attribute"
    t.integer "alternate_value_object_id", null: false
    t.string "alternate_value_object_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "language_id"
    t.integer "project_id"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.text "value", null: false
    t.index ["alternate_value_object_attribute", "value"], name: "idx_on_alternate_value_object_attribute_value_fc5a1a12bc"
    t.index ["alternate_value_object_id", "alternate_value_object_type"], name: "index_alternate_values_on_alternate_value_object_id_and_type"
    t.index ["created_by_id"], name: "index_alternate_values_on_created_by_id"
    t.index ["language_id"], name: "index_alternate_values_on_language_id"
    t.index ["project_id"], name: "index_alternate_values_on_project_id"
    t.index ["type"], name: "index_alternate_values_on_type"
    t.index ["updated_by_id"], name: "index_alternate_values_on_updated_by_id"
  end

  create_table "anatomical_parts", force: :cascade do |t|
    t.text "cached"
    t.bigint "cached_otu_id"
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.boolean "is_material"
    t.text "name"
    t.bigint "preparation_type_id"
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.text "uri"
    t.text "uri_label"
    t.index ["cached"], name: "index_anatomical_parts_on_cached"
    t.index ["cached_otu_id"], name: "index_anatomical_parts_on_cached_otu_id"
    t.index ["created_by_id"], name: "index_anatomical_parts_on_created_by_id"
    t.index ["is_material"], name: "index_anatomical_parts_on_is_material"
    t.index ["name"], name: "index_anatomical_parts_on_name"
    t.index ["preparation_type_id"], name: "index_anatomical_parts_on_preparation_type_id"
    t.index ["project_id"], name: "index_anatomical_parts_on_project_id"
    t.index ["updated_by_id"], name: "index_anatomical_parts_on_updated_by_id"
    t.index ["uri"], name: "index_anatomical_parts_on_uri"
    t.index ["uri_label"], name: "index_anatomical_parts_on_uri_label"
  end

  create_table "asserted_distributions", id: :serial, force: :cascade do |t|
    t.integer "asserted_distribution_object_id", null: false
    t.string "asserted_distribution_object_type", null: false
    t.integer "asserted_distribution_shape_id", null: false
    t.string "asserted_distribution_shape_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.boolean "is_absent"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["asserted_distribution_object_id", "asserted_distribution_object_type"], name: "asserted_distribution_polymorphic_object_index"
    t.index ["asserted_distribution_shape_id", "asserted_distribution_shape_type"], name: "asserted_distribution_polymorphic_shape_index"
    t.index ["created_by_id"], name: "index_asserted_distributions_on_created_by_id"
    t.index ["project_id"], name: "index_asserted_distributions_on_project_id"
    t.index ["updated_by_id"], name: "index_asserted_distributions_on_updated_by_id"
  end

  create_table "attributions", force: :cascade do |t|
    t.bigint "attribution_object_id", null: false
    t.string "attribution_object_type", null: false
    t.integer "copyright_year"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "license"
    t.bigint "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["attribution_object_id"], name: "attr_obj_id_index"
    t.index ["attribution_object_type", "attribution_object_id"], name: "attribution_object_index"
    t.index ["attribution_object_type"], name: "attr_obj_type_index"
    t.index ["created_by_id"], name: "index_attributions_on_created_by_id"
    t.index ["project_id"], name: "index_attributions_on_project_id"
    t.index ["updated_by_id"], name: "index_attributions_on_updated_by_id"
  end

  create_table "biocuration_classifications", id: :serial, force: :cascade do |t|
    t.integer "biocuration_class_id", null: false
    t.bigint "biocuration_classification_object_id"
    t.string "biocuration_classification_object_type"
    t.bigint "biological_collection_object_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["biocuration_class_id"], name: "index_biocuration_classifications_on_biocuration_class_id"
    t.index ["biocuration_classification_object_type", "biocuration_classification_object_id"], name: "bc_poly"
    t.index ["biological_collection_object_id"], name: "bio_c_bio_collection_object"
    t.index ["created_by_id"], name: "index_biocuration_classifications_on_created_by_id"
    t.index ["position"], name: "index_biocuration_classifications_on_position"
    t.index ["project_id"], name: "index_biocuration_classifications_on_project_id"
    t.index ["updated_by_id"], name: "index_biocuration_classifications_on_updated_by_id"
  end

  create_table "biological_association_indices", force: :cascade do |t|
    t.bigint "biological_association_id", null: false
    t.integer "biological_association_uuid"
    t.bigint "biological_relationship_id", null: false
    t.string "biological_relationship_uri"
    t.string "citation_year"
    t.text "citations"
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.string "established_date"
    t.string "object_family"
    t.string "object_genus"
    t.integer "object_id", null: false
    t.string "object_label"
    t.string "object_order"
    t.string "object_properties"
    t.string "object_type", null: false
    t.string "object_uuid"
    t.bigint "project_id", null: false
    t.string "rebuild_set"
    t.string "relationship_inverted_name"
    t.string "relationship_name"
    t.text "remarks"
    t.string "subject_family"
    t.string "subject_genus"
    t.integer "subject_id", null: false
    t.string "subject_label"
    t.string "subject_order"
    t.string "subject_properties"
    t.string "subject_type", null: false
    t.string "subject_uuid"
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["biological_association_id"], name: "idx_on_biological_association_id_58cd768e96"
    t.index ["biological_relationship_id"], name: "idx_on_biological_relationship_id_a634a0b467"
    t.index ["biological_relationship_uri"], name: "idx_on_biological_relationship_uri_58607d5e1e"
    t.index ["object_family"], name: "index_biological_association_indices_on_object_family"
    t.index ["object_genus"], name: "index_biological_association_indices_on_object_genus"
    t.index ["object_id", "object_type"], name: "idx_on_object_id_object_type_0eedf4ae5a"
    t.index ["object_order"], name: "index_biological_association_indices_on_object_order"
    t.index ["object_properties"], name: "index_biological_association_indices_on_object_properties"
    t.index ["project_id"], name: "index_biological_association_indices_on_project_id"
    t.index ["rebuild_set"], name: "index_biological_association_indices_on_rebuild_set"
    t.index ["relationship_inverted_name"], name: "idx_on_relationship_inverted_name_8e42f527b3"
    t.index ["relationship_name"], name: "index_biological_association_indices_on_relationship_name"
    t.index ["subject_family"], name: "index_biological_association_indices_on_subject_family"
    t.index ["subject_genus"], name: "index_biological_association_indices_on_subject_genus"
    t.index ["subject_id", "subject_type"], name: "idx_on_subject_id_subject_type_6dfd7ad8ad"
    t.index ["subject_order"], name: "index_biological_association_indices_on_subject_order"
    t.index ["subject_properties"], name: "index_biological_association_indices_on_subject_properties"
  end

  create_table "biological_associations", id: :serial, force: :cascade do |t|
    t.integer "biological_association_object_id", null: false
    t.string "biological_association_object_type", null: false
    t.integer "biological_association_subject_id", null: false
    t.string "biological_association_subject_type", null: false
    t.integer "biological_relationship_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["biological_association_object_id", "biological_association_object_type"], name: "index_biological_associations_on_object_id_and_type"
    t.index ["biological_association_subject_id", "biological_association_subject_type"], name: "index_biological_associations_on_subject_id_and_type"
    t.index ["biological_relationship_id"], name: "index_biological_associations_on_biological_relationship_id"
    t.index ["created_by_id"], name: "index_biological_associations_on_created_by_id"
    t.index ["project_id"], name: "index_biological_associations_on_project_id"
    t.index ["updated_at"], name: "index_biological_associations_on_updated_at"
    t.index ["updated_by_id"], name: "index_biological_associations_on_updated_by_id"
  end

  create_table "biological_associations_biological_associations_graphs", id: :serial, force: :cascade do |t|
    t.integer "biological_association_id", null: false
    t.integer "biological_associations_graph_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["biological_association_id"], name: "bio_asc_bio_asc_graph_bio_asc"
    t.index ["biological_associations_graph_id"], name: "bio_asc_bio_asc_graph_bio_asc_graph"
    t.index ["created_by_id"], name: "bio_asc_bio_asc_graph_created_by"
    t.index ["project_id"], name: "bio_asc_bio_asc_graph_project"
    t.index ["updated_by_id"], name: "bio_asc_bio_asc_graph_updated_by"
  end

  create_table "biological_associations_graphs", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.jsonb "layout"
    t.string "name"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_biological_associations_graphs_on_created_by_id"
    t.index ["project_id"], name: "index_biological_associations_graphs_on_project_id"
    t.index ["updated_by_id"], name: "index_biological_associations_graphs_on_updated_by_id"
  end

  create_table "biological_relationship_types", id: :serial, force: :cascade do |t|
    t.integer "biological_property_id", null: false
    t.integer "biological_relationship_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "project_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["biological_property_id"], name: "index_biological_relationship_types_on_biological_property_id"
    t.index ["biological_relationship_id"], name: "bio_rel_type_bio_rel"
    t.index ["created_by_id"], name: "bio_rel_type_created_by"
    t.index ["project_id"], name: "bio_rel_type_project"
    t.index ["type"], name: "index_biological_relationship_types_on_type"
    t.index ["updated_by_id"], name: "bio_rel_type_updated_by"
  end

  create_table "biological_relationships", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.text "definition"
    t.string "inverted_name"
    t.boolean "is_reflexive"
    t.boolean "is_transitive"
    t.string "name", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "bio_rel_created_by"
    t.index ["project_id"], name: "bio_rel_project"
    t.index ["updated_by_id"], name: "bio_rel_updated_by"
  end

  create_table "cached_map_item_translations", force: :cascade do |t|
    t.string "cached_map_type"
    t.datetime "created_at", null: false
    t.bigint "geographic_item_id"
    t.bigint "translated_geographic_item_id"
    t.datetime "updated_at", null: false
    t.index ["cached_map_type"], name: "cmgit_cmt"
    t.index ["geographic_item_id", "translated_geographic_item_id", "cached_map_type"], name: "cmgit_translation", unique: true
    t.index ["geographic_item_id"], name: "cmgit_gi"
    t.index ["translated_geographic_item_id"], name: "cmgit_tgi"
  end

  create_table "cached_map_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "geographic_item_id", null: false
    t.string "level0_geographic_name"
    t.string "level1_geographic_name"
    t.string "level2_geographic_name"
    t.bigint "otu_id", null: false
    t.bigint "project_id"
    t.integer "reference_count"
    t.string "type"
    t.boolean "untranslated"
    t.datetime "updated_at", null: false
    t.index ["geographic_item_id"], name: "index_cached_map_items_on_geographic_item_id"
    t.index ["otu_id", "geographic_item_id"], name: "index_cached_map_items_on_otu_id_and_geographic_item_id"
    t.index ["otu_id"], name: "index_cached_map_items_on_otu_id"
    t.index ["project_id"], name: "index_cached_map_items_on_project_id"
  end

  create_table "cached_map_registers", force: :cascade do |t|
    t.bigint "cached_map_register_object_id"
    t.string "cached_map_register_object_type"
    t.datetime "created_at", null: false
    t.bigint "project_id"
    t.datetime "updated_at", null: false
    t.index ["cached_map_register_object_type", "cached_map_register_object_id"], name: "index_cached_map_registers_on_cached_map_register_object"
    t.index ["project_id"], name: "index_cached_map_registers_on_project_id"
  end

  create_table "cached_maps", force: :cascade do |t|
    t.string "cached_map_type", null: false
    t.datetime "created_at", null: false
    t.geography "geometry", limit: {srid: 4326, type: "geometry", geographic: true}
    t.bigint "otu_id", null: false
    t.bigint "project_id", null: false
    t.integer "reference_count"
    t.datetime "updated_at", null: false
    t.index ["otu_id"], name: "index_cached_maps_on_otu_id"
    t.index ["project_id"], name: "index_cached_maps_on_project_id"
  end

  create_table "character_states", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "description_name"
    t.integer "descriptor_id", null: false
    t.string "key_name"
    t.string "label", null: false
    t.string "name", null: false
    t.integer "position"
    t.integer "project_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_character_states_on_created_by_id"
    t.index ["descriptor_id"], name: "index_character_states_on_descriptor_id"
    t.index ["label"], name: "index_character_states_on_label"
    t.index ["name"], name: "index_character_states_on_name"
    t.index ["project_id"], name: "index_character_states_on_project_id"
    t.index ["updated_by_id"], name: "index_character_states_on_updated_by_id"
  end

  create_table "citation_topics", id: :serial, force: :cascade do |t|
    t.integer "citation_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "pages"
    t.integer "project_id", null: false
    t.integer "topic_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["citation_id"], name: "index_citation_topics_on_citation_id"
    t.index ["created_by_id"], name: "index_citation_topics_on_created_by_id"
    t.index ["project_id"], name: "index_citation_topics_on_project_id"
    t.index ["topic_id"], name: "index_citation_topics_on_topic_id"
    t.index ["updated_by_id"], name: "index_citation_topics_on_updated_by_id"
  end

  create_table "citations", id: :serial, force: :cascade do |t|
    t.integer "citation_object_id", null: false
    t.string "citation_object_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.boolean "is_original"
    t.string "pages"
    t.integer "project_id", null: false
    t.integer "source_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["citation_object_id", "citation_object_type"], name: "index_citations_on_citation_object_id_and_citation_object_type"
    t.index ["citation_object_id"], name: "index_citations_on_citation_object_id"
    t.index ["citation_object_type"], name: "index_citations_on_citation_object_type"
    t.index ["created_by_id"], name: "index_citations_on_created_by_id"
    t.index ["project_id"], name: "index_citations_on_project_id"
    t.index ["source_id"], name: "index_citations_on_source_id"
    t.index ["updated_by_id"], name: "index_citations_on_updated_by_id"
  end

  create_table "collecting_events", id: :serial, force: :cascade do |t|
    t.text "cached"
    t.string "cached_level0_geographic_name"
    t.string "cached_level1_geographic_name"
    t.string "cached_level2_geographic_name"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.text "document_label"
    t.string "elevation_precision"
    t.integer "end_date_day"
    t.integer "end_date_month"
    t.integer "end_date_year"
    t.text "field_notes"
    t.string "formation"
    t.integer "geographic_area_id"
    t.string "group"
    t.string "lithology"
    t.decimal "max_ma"
    t.decimal "maximum_elevation"
    t.string "md5_of_verbatim_label"
    t.string "member"
    t.boolean "meta_prioritize_geographic_area"
    t.decimal "min_ma"
    t.decimal "minimum_elevation"
    t.text "print_label"
    t.integer "project_id", null: false
    t.integer "start_date_day"
    t.integer "start_date_month"
    t.integer "start_date_year"
    t.integer "time_end_hour", limit: 2
    t.integer "time_end_minute", limit: 2
    t.integer "time_end_second", limit: 2
    t.integer "time_start_hour", limit: 2
    t.integer "time_start_minute", limit: 2
    t.integer "time_start_second", limit: 2
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.string "verbatim_collectors"
    t.string "verbatim_date"
    t.string "verbatim_datum"
    t.string "verbatim_elevation"
    t.string "verbatim_field_number"
    t.string "verbatim_geolocation_uncertainty"
    t.text "verbatim_habitat"
    t.text "verbatim_label"
    t.string "verbatim_latitude"
    t.string "verbatim_locality"
    t.string "verbatim_longitude"
    t.string "verbatim_method"
    t.index ["created_at"], name: "index_collecting_events_on_created_at"
    t.index ["created_by_id"], name: "index_collecting_events_on_created_by_id"
    t.index ["geographic_area_id"], name: "index_collecting_events_on_geographic_area_id"
    t.index ["project_id"], name: "index_collecting_events_on_project_id"
    t.index ["updated_at"], name: "index_collecting_events_on_updated_at"
    t.index ["updated_by_id"], name: "index_collecting_events_on_updated_by_id"
  end

  create_table "collection_object_observations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.text "data", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_collection_object_observations_on_created_by_id"
    t.index ["data"], name: "index_collection_object_observations_on_data"
    t.index ["project_id"], name: "index_collection_object_observations_on_project_id"
    t.index ["updated_by_id"], name: "index_collection_object_observations_on_updated_by_id"
  end

  create_table "collection_objects", id: :serial, force: :cascade do |t|
    t.date "accessioned_at"
    t.text "buffered_collecting_event"
    t.text "buffered_determinations"
    t.text "buffered_other_labels"
    t.integer "collecting_event_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "current_repository_id"
    t.string "deaccession_reason"
    t.date "deaccessioned_at"
    t.integer "preparation_type_id"
    t.integer "project_id", null: false
    t.integer "ranged_lot_category_id"
    t.integer "repository_id"
    t.integer "total"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["buffered_collecting_event"], name: "index_collection_objects_on_buffered_collecting_event"
    t.index ["buffered_determinations"], name: "index_collection_objects_on_buffered_determinations"
    t.index ["buffered_other_labels"], name: "index_collection_objects_on_buffered_other_labels"
    t.index ["collecting_event_id"], name: "index_collection_objects_on_collecting_event_id"
    t.index ["created_at"], name: "index_collection_objects_on_created_at"
    t.index ["created_by_id"], name: "index_collection_objects_on_created_by_id"
    t.index ["current_repository_id"], name: "index_collection_objects_on_current_repository_id"
    t.index ["preparation_type_id"], name: "index_collection_objects_on_preparation_type_id"
    t.index ["project_id"], name: "index_collection_objects_on_project_id"
    t.index ["ranged_lot_category_id"], name: "index_collection_objects_on_ranged_lot_category_id"
    t.index ["repository_id"], name: "index_collection_objects_on_repository_id"
    t.index ["type"], name: "index_collection_objects_on_type"
    t.index ["updated_at"], name: "index_collection_objects_on_updated_at"
    t.index ["updated_by_id"], name: "index_collection_objects_on_updated_by_id"
  end

  create_table "collection_profiles", id: :serial, force: :cascade do |t|
    t.integer "arrangement_level"
    t.string "collection_type"
    t.integer "computerization_level"
    t.integer "condition_of_labels"
    t.integer "conservation_status"
    t.integer "container_condition"
    t.integer "container_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "data_quality"
    t.integer "identification_level"
    t.integer "number_of_collection_objects"
    t.integer "number_of_containers"
    t.integer "otu_id"
    t.integer "processing_state"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["collection_type"], name: "index_collection_profiles_on_collection_type"
    t.index ["container_id"], name: "index_collection_profiles_on_container_id"
    t.index ["created_by_id"], name: "index_collection_profiles_on_created_by_id"
    t.index ["otu_id"], name: "index_collection_profiles_on_otu_id"
    t.index ["project_id"], name: "index_collection_profiles_on_project_id"
    t.index ["updated_by_id"], name: "index_collection_profiles_on_updated_by_id"
  end

  create_table "common_names", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "end_year"
    t.integer "geographic_area_id"
    t.integer "language_id"
    t.string "name", null: false
    t.integer "otu_id"
    t.integer "project_id", null: false
    t.integer "start_year"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_common_names_on_created_by_id"
    t.index ["geographic_area_id"], name: "index_common_names_on_geographic_area_id"
    t.index ["language_id"], name: "index_common_names_on_language_id"
    t.index ["name"], name: "index_common_names_on_name"
    t.index ["otu_id"], name: "index_common_names_on_otu_id"
    t.index ["project_id"], name: "index_common_names_on_project_id"
    t.index ["updated_by_id"], name: "index_common_names_on_updated_by_id"
  end

  create_table "confidences", id: :serial, force: :cascade do |t|
    t.integer "confidence_level_id", null: false
    t.integer "confidence_object_id", null: false
    t.string "confidence_object_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["project_id"], name: "index_confidences_on_project_id"
  end

  create_table "container_item_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "container_item_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "container_item_desc_idx"
  end

  create_table "container_items", id: :serial, force: :cascade do |t|
    t.integer "contained_object_id", null: false
    t.string "contained_object_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "disposition"
    t.integer "disposition_x"
    t.integer "disposition_y"
    t.integer "disposition_z"
    t.integer "parent_id"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["contained_object_id", "contained_object_type"], name: "index_container_items_on_contained_object_id_and_type"
    t.index ["created_by_id"], name: "index_container_items_on_created_by_id"
    t.index ["project_id"], name: "index_container_items_on_project_id"
    t.index ["updated_by_id"], name: "index_container_items_on_updated_by_id"
  end

  create_table "containers", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "disposition"
    t.string "name"
    t.text "print_label"
    t.integer "project_id", null: false
    t.integer "size_x"
    t.integer "size_y"
    t.integer "size_z"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_containers_on_created_by_id"
    t.index ["disposition"], name: "index_containers_on_disposition"
    t.index ["project_id"], name: "index_containers_on_project_id"
    t.index ["type"], name: "index_containers_on_type"
    t.index ["updated_by_id"], name: "index_containers_on_updated_by_id"
  end

  create_table "contents", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.bigint "language_id"
    t.integer "otu_id", null: false
    t.integer "project_id", null: false
    t.integer "revision_id"
    t.text "text", null: false
    t.integer "topic_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_contents_on_created_by_id"
    t.index ["language_id"], name: "index_contents_on_language_id"
    t.index ["otu_id"], name: "index_contents_on_otu_id"
    t.index ["project_id"], name: "index_contents_on_project_id"
    t.index ["revision_id"], name: "index_contents_on_revision_id"
    t.index ["topic_id"], name: "index_contents_on_topic_id"
    t.index ["updated_at"], name: "index_contents_on_updated_at"
    t.index ["updated_by_id"], name: "index_contents_on_updated_by_id"
  end

  create_table "controlled_vocabulary_terms", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "css_color"
    t.text "definition", null: false
    t.string "name", null: false
    t.integer "position"
    t.integer "project_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.string "uri"
    t.string "uri_relation"
    t.index ["created_at"], name: "index_controlled_vocabulary_terms_on_created_at"
    t.index ["created_by_id"], name: "index_controlled_vocabulary_terms_on_created_by_id"
    t.index ["project_id"], name: "index_controlled_vocabulary_terms_on_project_id"
    t.index ["type"], name: "index_controlled_vocabulary_terms_on_type"
    t.index ["updated_at"], name: "index_controlled_vocabulary_terms_on_updated_at"
    t.index ["updated_by_id"], name: "index_controlled_vocabulary_terms_on_updated_by_id"
  end

  create_table "conveyances", force: :cascade do |t|
    t.bigint "conveyance_object_id", null: false
    t.string "conveyance_object_type", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.decimal "end_time"
    t.integer "position", null: false
    t.bigint "project_id", null: false
    t.bigint "sound_id", null: false
    t.decimal "start_time"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id", null: false
    t.index ["conveyance_object_type", "conveyance_object_id"], name: "index_conveyances_on_conveyance_object"
    t.index ["created_by_id"], name: "index_conveyances_on_created_by_id"
    t.index ["position"], name: "index_conveyances_on_position"
    t.index ["project_id"], name: "index_conveyances_on_project_id"
    t.index ["sound_id"], name: "index_conveyances_on_sound_id"
    t.index ["updated_by_id"], name: "index_conveyances_on_updated_by_id"
  end

  create_table "data_attributes", id: :serial, force: :cascade do |t|
    t.integer "attribute_subject_id", null: false
    t.string "attribute_subject_type", null: false
    t.integer "controlled_vocabulary_term_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "import_predicate"
    t.integer "project_id"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.text "value", null: false
    t.index ["attribute_subject_id", "attribute_subject_type"], name: "index_data_attributes_on_attribute_subject_id_and_type"
    t.index ["attribute_subject_id"], name: "index_data_attributes_on_attribute_subject_id"
    t.index ["attribute_subject_type"], name: "index_data_attributes_on_attribute_subject_type"
    t.index ["controlled_vocabulary_term_id"], name: "index_data_attributes_on_controlled_vocabulary_term_id"
    t.index ["created_by_id"], name: "index_data_attributes_on_created_by_id"
    t.index ["project_id"], name: "index_data_attributes_on_project_id"
    t.index ["type"], name: "index_data_attributes_on_type"
    t.index ["updated_at"], name: "index_data_attributes_on_updated_at"
    t.index ["updated_by_id"], name: "index_data_attributes_on_updated_by_id"
  end

  create_table "dataset_record_fields", force: :cascade do |t|
    t.bigint "dataset_record_id", null: false
    t.integer "encoded_dataset_record_type", null: false
    t.integer "import_dataset_id", null: false
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.string "value", null: false
    t.index "import_dataset_id, encoded_dataset_record_type, \"position\", substr((value)::text, 1, 1000), dataset_record_id", name: "index_dataset_record_fields_for_filters", unique: true
    t.index ["dataset_record_id", "position"], name: "index_dataset_record_fields_on_dataset_record_id_and_position", unique: true
  end

  create_table "dataset_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.bigint "import_dataset_id"
    t.jsonb "metadata"
    t.bigint "project_id"
    t.string "status", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_dataset_records_on_created_by_id"
    t.index ["import_dataset_id", "type", "id"], name: "index_dataset_records_on_import_dataset_id_and_type_and_id"
    t.index ["import_dataset_id"], name: "index_dataset_records_on_import_dataset_id"
    t.index ["project_id"], name: "index_dataset_records_on_project_id"
    t.index ["updated_by_id"], name: "index_dataset_records_on_updated_by_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "depictions", id: :serial, force: :cascade do |t|
    t.text "caption"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "depiction_object_id", null: false
    t.string "depiction_object_type", null: false
    t.string "figure_label"
    t.integer "image_id", null: false
    t.boolean "is_metadata_depiction"
    t.integer "position"
    t.integer "project_id", null: false
    t.bigint "sled_image_id"
    t.integer "sled_image_x_position"
    t.integer "sled_image_y_position"
    t.xml "svg_clip"
    t.string "svg_view_box"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_depictions_on_created_by_id"
    t.index ["depiction_object_id"], name: "index_depictions_on_depiction_object_id"
    t.index ["depiction_object_type"], name: "index_depictions_on_depiction_object_type"
    t.index ["image_id"], name: "index_depictions_on_image_id"
    t.index ["project_id"], name: "index_depictions_on_project_id"
    t.index ["sled_image_id"], name: "index_depictions_on_sled_image_id"
    t.index ["updated_by_id"], name: "index_depictions_on_updated_by_id"
  end

  create_table "derived_collection_objects", id: :serial, force: :cascade do |t|
    t.integer "collection_object_id", null: false
    t.integer "collection_object_observation_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "position"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["collection_object_id"], name: "dco_collection_object"
    t.index ["collection_object_observation_id"], name: "dco_collection_object_observation"
    t.index ["project_id"], name: "index_derived_collection_objects_on_project_id"
  end

  create_table "descriptors", id: :serial, force: :cascade do |t|
    t.string "cached_gene_attribute_sql"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "default_unit"
    t.text "description"
    t.string "description_name"
    t.string "gene_attribute_logic"
    t.string "key_name"
    t.string "name", null: false
    t.integer "position"
    t.integer "project_id", null: false
    t.string "short_name"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.integer "weight"
    t.index ["created_by_id"], name: "index_descriptors_on_created_by_id"
    t.index ["name"], name: "index_descriptors_on_name"
    t.index ["project_id"], name: "index_descriptors_on_project_id"
    t.index ["short_name"], name: "index_descriptors_on_short_name"
    t.index ["updated_by_id"], name: "index_descriptors_on_updated_by_id"
  end

  create_table "documentation", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "document_id", null: false
    t.integer "documentation_object_id", null: false
    t.string "documentation_object_type", null: false
    t.integer "position"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_documentation_on_created_by_id"
    t.index ["document_id"], name: "index_documentation_on_document_id"
    t.index ["documentation_object_id", "documentation_object_type"], name: "index_doc_on_doc_object_type_and_doc_object_id"
    t.index ["project_id"], name: "index_documentation_on_project_id"
    t.index ["updated_by_id"], name: "index_documentation_on_updated_by_id"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "document_file_content_type", null: false
    t.string "document_file_file_name", null: false
    t.integer "document_file_file_size", null: false
    t.string "document_file_fingerprint"
    t.datetime "document_file_updated_at", precision: nil, null: false
    t.boolean "is_public"
    t.jsonb "page_map", default: {}
    t.integer "page_total"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["document_file_content_type"], name: "index_documents_on_document_file_content_type"
    t.index ["document_file_file_name"], name: "index_documents_on_document_file_file_name"
    t.index ["document_file_file_size"], name: "index_documents_on_document_file_file_size"
    t.index ["document_file_updated_at"], name: "index_documents_on_document_file_updated_at"
  end

  create_table "downloads", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "description"
    t.datetime "expires", precision: nil, null: false
    t.string "filename", null: false
    t.boolean "is_public"
    t.string "name", null: false
    t.bigint "project_id"
    t.string "request"
    t.string "sha2"
    t.integer "times_downloaded", default: 0, null: false
    t.integer "total_records"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_downloads_on_created_by_id"
    t.index ["filename"], name: "index_downloads_on_filename"
    t.index ["project_id"], name: "index_downloads_on_project_id"
    t.index ["request"], name: "index_downloads_on_request"
    t.index ["updated_by_id"], name: "index_downloads_on_updated_by_id"
  end

  create_table "dwc_occurrences", id: :serial, force: :cascade do |t|
    t.string "acceptedNameUsage"
    t.string "acceptedNameUsageID"
    t.string "accessRights"
    t.string "associatedMedia"
    t.string "associatedOccurrences"
    t.string "associatedOrganisms"
    t.string "associatedReferences"
    t.string "associatedSequences"
    t.string "associatedTaxa"
    t.string "basisOfRecord"
    t.string "bed"
    t.string "behavior"
    t.string "bibliographicCitation"
    t.string "caste"
    t.string "catalogNumber"
    t.string "collectionCode"
    t.string "collectionID"
    t.string "continent"
    t.string "coordinatePrecision"
    t.string "coordinateUncertaintyInMeters"
    t.string "country"
    t.string "countryCode"
    t.string "county"
    t.datetime "created_at", precision: nil
    t.integer "created_by_id", null: false
    t.string "dataGeneralizations"
    t.string "datasetID"
    t.string "datasetName"
    t.string "dateIdentified"
    t.string "day"
    t.string "decimalLatitude"
    t.string "decimalLongitude"
    t.string "disposition"
    t.string "dwcClass"
    t.integer "dwc_occurrence_object_id"
    t.string "dwc_occurrence_object_type"
    t.string "dynamicProperties"
    t.string "earliestAgeOrLowestStage"
    t.string "earliestEonOrLowestEonothem"
    t.string "earliestEpochOrLowestSeries"
    t.string "earliestEraOrLowestErathem"
    t.string "earliestPeriodOrLowestSystem"
    t.string "endDayOfYear"
    t.string "establishmentMeans"
    t.string "eventDate"
    t.string "eventID"
    t.string "eventRemarks"
    t.string "eventTime"
    t.string "family"
    t.string "fieldNotes"
    t.string "fieldNumber"
    t.string "footprintSRS"
    t.string "footprintSpatialFit"
    t.string "footprintWKT"
    t.string "formation"
    t.string "genus"
    t.string "geodeticDatum"
    t.string "geologicalContextID"
    t.string "georeferenceProtocol"
    t.string "georeferenceRemarks"
    t.string "georeferenceSources"
    t.string "georeferenceVerificationStatus"
    t.string "georeferencedBy"
    t.string "georeferencedDate"
    t.string "group"
    t.string "habitat"
    t.string "higherClassification"
    t.string "higherGeography"
    t.string "higherGeographyID"
    t.string "highestBiostratigraphicZone"
    t.string "identificationID"
    t.string "identificationQualifier"
    t.string "identificationReferences"
    t.string "identificationRemarks"
    t.string "identificationVerificationStatus"
    t.string "identifiedBy"
    t.string "identifiedByID"
    t.integer "individualCount"
    t.string "informationWithheld"
    t.string "infraspecificEpithet"
    t.string "institutionCode"
    t.string "institutionID"
    t.string "island"
    t.string "islandGroup"
    t.string "kingdom"
    t.string "language"
    t.string "latestAgeOrHighestStage"
    t.string "latestEonOrHighestEonothem"
    t.string "latestEpochOrHighestSeries"
    t.string "latestEraOrHighestErathem"
    t.string "latestPeriodOrHighestSystem"
    t.string "license"
    t.string "lifeStage"
    t.string "lithostratigraphicTerms"
    t.string "locality"
    t.string "locationAccordingTo"
    t.string "locationID"
    t.string "locationRemarks"
    t.string "lowestBiostratigraphicZone"
    t.string "materialSampleID"
    t.string "maximumDepthInMeters"
    t.string "maximumDistanceAboveSurfaceInMeters"
    t.string "maximumElevationInMeters"
    t.string "member"
    t.string "minimumDepthInMeters"
    t.string "minimumDistanceAboveSurfaceInMeters"
    t.string "minimumElevationInMeters"
    t.string "modified"
    t.string "month"
    t.string "municipality"
    t.string "nameAccordingTo"
    t.string "nameAccordingToID"
    t.string "namePublishedIn"
    t.string "namePublishedInID"
    t.string "namePublishedInYear"
    t.string "nomenclaturalCode"
    t.string "nomenclaturalStatus"
    t.string "occurrenceID"
    t.string "occurrenceRemarks"
    t.string "occurrenceStatus"
    t.string "order"
    t.string "organismID"
    t.string "organismName"
    t.string "organismQuantity"
    t.string "organismQuantityType"
    t.string "organismRemarks"
    t.string "organismScope"
    t.string "originalNameUsage"
    t.string "originalNameUsageID"
    t.string "otherCatalogNumbers"
    t.string "ownerInstitutionCode"
    t.string "parentEventID"
    t.string "parentNameUsage"
    t.string "parentNameUsageID"
    t.string "phylum"
    t.string "pointRadiusSpatialFit"
    t.string "preparations"
    t.string "previousIdentifications"
    t.integer "project_id"
    t.text "rebuild_set"
    t.string "recordNumber"
    t.string "recordedBy"
    t.string "recordedByID"
    t.string "references"
    t.string "reproductiveCondition"
    t.string "rightsHolder"
    t.string "sampleSizeUnit"
    t.string "sampleSizeValue"
    t.string "samplingEffort"
    t.string "samplingProtocol"
    t.string "scientificName"
    t.string "scientificNameAuthorship"
    t.string "scientificNameID"
    t.string "sex"
    t.string "specificEpithet"
    t.string "startDayOfYear"
    t.string "stateProvince"
    t.string "subfamily"
    t.string "subgenus"
    t.string "subtribe"
    t.string "superfamily"
    t.string "taxonConceptID"
    t.string "taxonID"
    t.string "taxonRank"
    t.string "taxonRemarks"
    t.string "taxonomicStatus"
    t.string "tribe"
    t.string "type"
    t.string "typeStatus"
    t.datetime "updated_at", precision: nil
    t.integer "updated_by_id", null: false
    t.string "verbatimCoordinateSystem"
    t.string "verbatimCoordinates"
    t.string "verbatimDepth"
    t.string "verbatimElevation"
    t.string "verbatimEventDate"
    t.text "verbatimLabel"
    t.string "verbatimLatitude"
    t.string "verbatimLocality"
    t.string "verbatimLongitude"
    t.string "verbatimSRS"
    t.string "verbatimTaxonRank"
    t.string "vernacularName"
    t.string "waterBody"
    t.string "year"
    t.index ["country"], name: "index_dwc_occurrences_on_country"
    t.index ["county"], name: "index_dwc_occurrences_on_county"
    t.index ["created_at"], name: "index_dwc_occurrences_on_created_at"
    t.index ["dwc_occurrence_object_id", "dwc_occurrence_object_type"], name: "dwc_occurrences_object_index"
    t.index ["project_id"], name: "index_dwc_occurrences_on_project_id"
    t.index ["rebuild_set", "id"], name: "idx_dwc_occurrences_rebuild_set_id"
    t.index ["rebuild_set", "id"], name: "index_dwc_occurrences_on_rebuild_set_and_id"
    t.index ["stateProvince"], name: "index_dwc_occurrences_on_stateProvince"
    t.index ["updated_at"], name: "index_dwc_occurrences_on_updated_at"
  end

  create_table "extracts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "day_made"
    t.integer "month_made"
    t.integer "project_id", null: false
    t.bigint "repository_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.string "verbatim_anatomical_origin"
    t.integer "year_made"
    t.index ["project_id"], name: "index_extracts_on_project_id"
    t.index ["repository_id"], name: "index_extracts_on_repository_id"
  end

  create_table "field_occurrences", force: :cascade do |t|
    t.bigint "collecting_event_id", null: false
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.boolean "is_absent"
    t.bigint "project_id", null: false
    t.bigint "ranged_lot_category_id"
    t.integer "total", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["collecting_event_id"], name: "index_field_occurrences_on_collecting_event_id"
    t.index ["created_by_id"], name: "index_field_occurrences_on_created_by_id"
    t.index ["is_absent"], name: "index_field_occurrences_on_is_absent"
    t.index ["project_id"], name: "index_field_occurrences_on_project_id"
    t.index ["ranged_lot_category_id"], name: "index_field_occurrences_on_ranged_lot_category_id"
    t.index ["updated_by_id"], name: "index_field_occurrences_on_updated_by_id"
  end

  create_table "gazetteer_imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.datetime "ended_at"
    t.string "error_messages"
    t.integer "num_records"
    t.integer "num_records_imported"
    t.bigint "project_id"
    t.string "project_names"
    t.string "shapefile"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_gazetteer_imports_on_created_by_id"
    t.index ["project_id"], name: "index_gazetteer_imports_on_project_id"
    t.index ["updated_by_id"], name: "index_gazetteer_imports_on_updated_by_id"
  end

  create_table "gazetteers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.integer "geographic_item_id", null: false
    t.string "iso_3166_a2"
    t.string "iso_3166_a3"
    t.string "name", null: false
    t.bigint "project_id"
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_gazetteers_on_created_by_id"
    t.index ["geographic_item_id"], name: "index_gazetteers_on_geographic_item_id"
    t.index ["iso_3166_a2"], name: "index_gazetteers_on_iso_3166_a2"
    t.index ["iso_3166_a3"], name: "index_gazetteers_on_iso_3166_a3"
    t.index ["name"], name: "index_gazetteers_on_name"
    t.index ["project_id"], name: "index_gazetteers_on_project_id"
    t.index ["updated_by_id"], name: "index_gazetteers_on_updated_by_id"
  end

  create_table "gene_attributes", id: :serial, force: :cascade do |t|
    t.integer "controlled_vocabulary_term_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "descriptor_id", null: false
    t.integer "position"
    t.integer "project_id", null: false
    t.integer "sequence_id", null: false
    t.string "sequence_relationship_type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["controlled_vocabulary_term_id"], name: "index_gene_attributes_on_controlled_vocabulary_term_id"
    t.index ["project_id"], name: "index_gene_attributes_on_project_id"
    t.index ["sequence_id"], name: "index_gene_attributes_on_sequence_id"
  end

  create_table "geographic_area_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "geographic_area_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "geographic_area_desc_idx"
  end

  create_table "geographic_area_types", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_geographic_area_types_on_created_by_id"
    t.index ["name"], name: "index_geographic_area_types_on_name"
    t.index ["updated_by_id"], name: "index_geographic_area_types_on_updated_by_id"
  end

  create_table "geographic_areas", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "data_origin", null: false
    t.integer "geographic_area_type_id"
    t.string "iso_3166_a2"
    t.string "iso_3166_a3"
    t.integer "level0_id"
    t.integer "level1_id"
    t.integer "level2_id"
    t.string "name", null: false
    t.integer "parent_id"
    t.string "tdwgID"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_geographic_areas_on_created_by_id"
    t.index ["geographic_area_type_id"], name: "index_geographic_areas_on_geographic_area_type_id"
    t.index ["level0_id"], name: "index_geographic_areas_on_level0_id"
    t.index ["level1_id"], name: "index_geographic_areas_on_level1_id"
    t.index ["level2_id"], name: "index_geographic_areas_on_level2_id"
    t.index ["name"], name: "index_geographic_areas_on_name"
    t.index ["parent_id"], name: "index_geographic_areas_on_parent_id"
    t.index ["updated_by_id"], name: "index_geographic_areas_on_updated_by_id"
  end

  create_table "geographic_areas_geographic_items", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "data_origin"
    t.string "date_valid_from"
    t.string "date_valid_to"
    t.integer "geographic_area_id", null: false
    t.integer "geographic_item_id"
    t.integer "origin_gid"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["data_origin"], name: "index_geographic_areas_geographic_items_on_data_origin"
    t.index ["geographic_area_id"], name: "index_geographic_areas_geographic_items_on_geographic_area_id"
    t.index ["geographic_item_id"], name: "index_geographic_areas_geographic_items_on_geographic_item_id"
  end

  create_table "geographic_items", id: :serial, force: :cascade do |t|
    t.decimal "cached_total_area"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.geography "geography", limit: {srid: 4326, type: "geometry", has_z: true, geographic: true}
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_geographic_items_on_created_by_id"
    t.index ["geography"], name: "index_geographic_items_on_geography", using: :gist
    t.index ["type"], name: "index_geographic_items_on_type"
    t.index ["updated_by_id"], name: "index_geographic_items_on_updated_by_id"
  end

  create_table "georeferences", id: :serial, force: :cascade do |t|
    t.string "api_request"
    t.integer "collecting_event_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "day_georeferenced"
    t.decimal "error_depth"
    t.integer "error_geographic_item_id"
    t.decimal "error_radius"
    t.integer "geographic_item_id", null: false
    t.boolean "is_public", default: false, null: false
    t.integer "month_georeferenced"
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.integer "year_georeferenced"
    t.index ["collecting_event_id"], name: "index_georeferences_on_collecting_event_id"
    t.index ["created_by_id"], name: "index_georeferences_on_created_by_id"
    t.index ["error_geographic_item_id"], name: "index_georeferences_on_error_geographic_item_id"
    t.index ["geographic_item_id"], name: "index_georeferences_on_geographic_item_id"
    t.index ["position"], name: "index_georeferences_on_position"
    t.index ["project_id"], name: "index_georeferences_on_project_id"
    t.index ["type"], name: "index_georeferences_on_type"
    t.index ["updated_by_id"], name: "index_georeferences_on_updated_by_id"
  end

  create_table "identifiers", id: :serial, force: :cascade do |t|
    t.text "cached"
    t.float "cached_numeric_identifier"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "identifier", null: false
    t.integer "identifier_object_id", null: false
    t.string "identifier_object_type", null: false
    t.integer "namespace_id"
    t.integer "position"
    t.integer "project_id"
    t.string "relation"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["cached"], name: "index_identifiers_on_cached"
    t.index ["cached_numeric_identifier"], name: "index_identifiers_on_cached_numeric_identifier"
    t.index ["created_at"], name: "index_identifiers_on_created_at"
    t.index ["created_by_id"], name: "index_identifiers_on_created_by_id"
    t.index ["identifier"], name: "index_identifiers_on_identifier"
    t.index ["identifier_object_id", "identifier_object_type"], name: "index_identifiers_on_identifier_object_id_and_type"
    t.index ["namespace_id"], name: "index_identifiers_on_namespace_id"
    t.index ["project_id"], name: "index_identifiers_on_project_id"
    t.index ["type"], name: "index_identifiers_on_type"
    t.index ["updated_at"], name: "index_identifiers_on_updated_at"
    t.index ["updated_by_id"], name: "index_identifiers_on_updated_by_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "height"
    t.string "image_file_content_type"
    t.string "image_file_file_name"
    t.integer "image_file_file_size"
    t.string "image_file_fingerprint"
    t.text "image_file_meta"
    t.datetime "image_file_updated_at", precision: nil
    t.float "pixels_to_centimeter"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.string "user_file_name"
    t.integer "width"
    t.index ["created_by_id"], name: "index_images_on_created_by_id"
    t.index ["image_file_content_type"], name: "index_images_on_image_file_content_type"
    t.index ["project_id"], name: "index_images_on_project_id"
    t.index ["updated_by_id"], name: "index_images_on_updated_by_id"
  end

  create_table "import_datasets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.string "description", null: false
    t.jsonb "metadata"
    t.bigint "project_id"
    t.string "source_content_type"
    t.string "source_file_name"
    t.bigint "source_file_size"
    t.datetime "source_updated_at", precision: nil
    t.string "status", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_import_datasets_on_created_by_id"
    t.index ["project_id"], name: "index_import_datasets_on_project_id"
    t.index ["updated_by_id"], name: "index_import_datasets_on_updated_by_id"
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.hstore "metadata"
    t.json "metadata_json"
    t.string "name"
    t.datetime "updated_at", precision: nil
  end

  create_table "labels", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id"
    t.boolean "is_copy_edited", default: false
    t.boolean "is_printed", default: false
    t.bigint "label_object_id"
    t.string "label_object_type"
    t.integer "project_id"
    t.string "style"
    t.string "text", null: false
    t.integer "total", null: false
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "labels_created_by_id_index"
    t.index ["label_object_type", "label_object_id"], name: "index_labels_on_label_object_type_and_label_object_id"
    t.index ["project_id"], name: "index_labels_on_project_id"
    t.index ["updated_by_id"], name: "labels_updated_by_id_index"
  end

  create_table "languages", id: :serial, force: :cascade do |t|
    t.string "alpha_2"
    t.string "alpha_3_bibliographic"
    t.string "alpha_3_terminologic"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "english_name"
    t.string "french_name"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_languages_on_created_by_id"
    t.index ["updated_by_id"], name: "index_languages_on_updated_by_id"
  end

  create_table "lead_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "lead_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "lead_desc_idx"
  end

  create_table "lead_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.integer "lead_id", null: false
    t.integer "otu_id", null: false
    t.integer "position"
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_lead_items_on_created_by_id"
    t.index ["lead_id"], name: "index_lead_items_on_lead_id"
    t.index ["otu_id"], name: "index_lead_items_on_otu_id"
    t.index ["project_id"], name: "index_lead_items_on_project_id"
    t.index ["updated_by_id"], name: "index_lead_items_on_updated_by_id"
  end

  create_table "leads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.boolean "is_public"
    t.text "link_out"
    t.string "link_out_text"
    t.bigint "observation_matrix_id"
    t.string "origin_label"
    t.bigint "otu_id"
    t.bigint "parent_id"
    t.integer "position"
    t.bigint "project_id", null: false
    t.bigint "redirect_id"
    t.text "text"
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_leads_on_created_by_id"
    t.index ["observation_matrix_id"], name: "index_leads_on_observation_matrix_id"
    t.index ["otu_id"], name: "index_leads_on_otu_id"
    t.index ["parent_id"], name: "index_leads_on_parent_id"
    t.index ["position"], name: "index_leads_on_position"
    t.index ["project_id"], name: "index_leads_on_project_id"
    t.index ["redirect_id"], name: "index_leads_on_redirect_id"
    t.index ["text"], name: "index_leads_on_text"
    t.index ["updated_by_id"], name: "index_leads_on_updated_by_id"
  end

  create_table "loan_items", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.date "date_returned"
    t.string "disposition"
    t.integer "loan_id", null: false
    t.integer "loan_item_object_id"
    t.string "loan_item_object_type"
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.integer "total"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_loan_items_on_created_by_id"
    t.index ["loan_id"], name: "index_loan_items_on_loan_id"
    t.index ["position"], name: "index_loan_items_on_position"
    t.index ["project_id"], name: "index_loan_items_on_project_id"
    t.index ["updated_by_id"], name: "index_loan_items_on_updated_by_id"
  end

  create_table "loans", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.date "date_closed"
    t.date "date_received"
    t.date "date_requested"
    t.date "date_return_expected"
    t.date "date_sent"
    t.boolean "is_gift"
    t.text "lender_address", default: "Lender's address not provided.", null: false
    t.integer "project_id", null: false
    t.string "recipient_address"
    t.string "recipient_country"
    t.string "recipient_email"
    t.string "recipient_honorific"
    t.string "recipient_phone"
    t.string "request_method"
    t.string "supervisor_email"
    t.string "supervisor_phone"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_loans_on_created_by_id"
    t.index ["project_id"], name: "index_loans_on_project_id"
    t.index ["updated_at"], name: "index_loans_on_updated_at"
    t.index ["updated_by_id"], name: "index_loans_on_updated_by_id"
  end

  create_table "namespaces", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "delimiter"
    t.string "institution"
    t.boolean "is_virtual", default: false
    t.string "name", null: false
    t.string "short_name", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.string "verbatim_short_name"
    t.index ["created_at"], name: "index_namespaces_on_created_at"
    t.index ["created_by_id"], name: "index_namespaces_on_created_by_id"
    t.index ["updated_at"], name: "index_namespaces_on_updated_at"
    t.index ["updated_by_id"], name: "index_namespaces_on_updated_by_id"
  end

  create_table "news", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.datetime "display_end"
    t.datetime "display_start"
    t.boolean "is_public"
    t.bigint "project_id"
    t.text "title"
    t.text "type"
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.index ["is_public"], name: "index_news_on_is_public"
    t.index ["project_id"], name: "index_news_on_project_id"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "note_object_attribute"
    t.integer "note_object_id", null: false
    t.string "note_object_type", null: false
    t.integer "project_id", null: false
    t.text "text", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_notes_on_created_by_id"
    t.index ["note_object_id", "note_object_type"], name: "index_notes_on_note_object_id_and_type"
    t.index ["project_id"], name: "index_notes_on_project_id"
    t.index ["updated_by_id"], name: "index_notes_on_updated_by_id"
  end

  create_table "observation_matrices", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.boolean "is_public"
    t.string "name", null: false
    t.bigint "otu_id"
    t.integer "project_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_observation_matrices_on_created_by_id"
    t.index ["name"], name: "index_observation_matrices_on_name"
    t.index ["otu_id"], name: "index_observation_matrices_on_otu_id"
    t.index ["project_id"], name: "index_observation_matrices_on_project_id"
    t.index ["updated_by_id"], name: "index_observation_matrices_on_updated_by_id"
  end

  create_table "observation_matrix_column_items", id: :serial, force: :cascade do |t|
    t.integer "controlled_vocabulary_term_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "descriptor_id"
    t.integer "observation_matrix_id", null: false
    t.integer "position"
    t.integer "project_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["controlled_vocabulary_term_id"], name: "omrc_cvt_index"
    t.index ["created_by_id"], name: "index_observation_matrix_column_items_on_created_by_id"
    t.index ["descriptor_id"], name: "omci_d_index"
    t.index ["observation_matrix_id"], name: "omci_om_index"
    t.index ["project_id"], name: "index_observation_matrix_column_items_on_project_id"
    t.index ["updated_by_id"], name: "index_observation_matrix_column_items_on_updated_by_id"
  end

  create_table "observation_matrix_columns", id: :serial, force: :cascade do |t|
    t.integer "cached_observation_matrix_column_item_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "descriptor_id", null: false
    t.integer "observation_matrix_id", null: false
    t.integer "position"
    t.integer "project_id", null: false
    t.integer "reference_count"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_observation_matrix_columns_on_created_by_id"
    t.index ["descriptor_id"], name: "index_observation_matrix_columns_on_descriptor_id"
    t.index ["observation_matrix_id"], name: "imc_om_index"
    t.index ["project_id"], name: "index_observation_matrix_columns_on_project_id"
    t.index ["updated_by_id"], name: "index_observation_matrix_columns_on_updated_by_id"
  end

  create_table "observation_matrix_row_items", id: :serial, force: :cascade do |t|
    t.integer "controlled_vocabulary_term_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "observation_matrix_id", null: false
    t.integer "observation_object_id"
    t.string "observation_object_type"
    t.integer "position"
    t.integer "project_id", null: false
    t.bigint "taxon_name_id"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["controlled_vocabulary_term_id"], name: "omri_cvt_index"
    t.index ["created_by_id"], name: "index_observation_matrix_row_items_on_created_by_id"
    t.index ["observation_matrix_id"], name: "omri_om_index"
    t.index ["observation_object_id", "observation_object_type"], name: "omrowitem_oo_polymorphic_index"
    t.index ["project_id"], name: "index_observation_matrix_row_items_on_project_id"
    t.index ["taxon_name_id"], name: "index_observation_matrix_row_items_on_taxon_name_id"
    t.index ["updated_by_id"], name: "index_observation_matrix_row_items_on_updated_by_id"
  end

  create_table "observation_matrix_rows", id: :serial, force: :cascade do |t|
    t.integer "cached_observation_matrix_row_item_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "name"
    t.integer "observation_matrix_id", null: false
    t.integer "observation_object_id"
    t.string "observation_object_type"
    t.integer "position"
    t.integer "project_id", null: false
    t.integer "reference_count"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_observation_matrix_rows_on_created_by_id"
    t.index ["observation_matrix_id"], name: "omr_om_index"
    t.index ["observation_object_id", "observation_object_type"], name: "obmxrow_polymorphic_obj_index"
    t.index ["project_id"], name: "index_observation_matrix_rows_on_project_id"
    t.index ["updated_by_id"], name: "index_observation_matrix_rows_on_updated_by_id"
  end

  create_table "observations", id: :serial, force: :cascade do |t|
    t.string "cached"
    t.string "cached_column_label"
    t.string "cached_row_label"
    t.integer "character_state_id"
    t.string "continuous_unit"
    t.decimal "continuous_value"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "day_made"
    t.text "description"
    t.integer "descriptor_id"
    t.string "frequency"
    t.integer "month_made"
    t.integer "observation_object_id"
    t.string "observation_object_type"
    t.boolean "presence"
    t.integer "project_id", null: false
    t.decimal "sample_max"
    t.decimal "sample_mean"
    t.decimal "sample_median"
    t.decimal "sample_min"
    t.integer "sample_n"
    t.decimal "sample_standard_deviation"
    t.decimal "sample_standard_error"
    t.string "sample_units"
    t.time "time_made"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.integer "year_made"
    t.index ["character_state_id"], name: "index_observations_on_character_state_id"
    t.index ["descriptor_id"], name: "index_observations_on_descriptor_id"
    t.index ["observation_object_id", "observation_object_type"], name: "observation_polymorphic_index"
    t.index ["project_id"], name: "index_observations_on_project_id"
    t.index ["updated_at"], name: "index_observations_on_updated_at"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "address"
    t.string "alternate_name"
    t.integer "area_served_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "department_id"
    t.text "description"
    t.text "disambiguating_description"
    t.string "duns"
    t.string "email"
    t.string "global_location_number"
    t.string "legal_name"
    t.string "name", null: false
    t.integer "parent_organization_id"
    t.integer "same_as_id"
    t.string "telephone"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_organizations_on_created_by_id"
    t.index ["name"], name: "index_organizations_on_name"
    t.index ["updated_by_id"], name: "index_organizations_on_updated_by_id"
  end

  create_table "origin_relationships", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "new_object_id", null: false
    t.string "new_object_type", null: false
    t.integer "old_object_id", null: false
    t.string "old_object_type", null: false
    t.integer "position"
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_origin_relationships_on_created_by_id"
    t.index ["new_object_type", "new_object_id"], name: "index_origin_relationships_on_new_object_type_and_new_object_id"
    t.index ["old_object_type", "old_object_id"], name: "index_origin_relationships_on_old_object_type_and_old_object_id"
    t.index ["project_id"], name: "index_origin_relationships_on_project_id"
    t.index ["updated_by_id"], name: "index_origin_relationships_on_updated_by_id"
  end

  create_table "otu_page_layout_sections", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "dynamic_content_class"
    t.integer "otu_page_layout_id", null: false
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.integer "topic_id"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_otu_page_layout_sections_on_created_by_id"
    t.index ["otu_page_layout_id"], name: "index_otu_page_layout_sections_on_otu_page_layout_id"
    t.index ["position"], name: "index_otu_page_layout_sections_on_position"
    t.index ["project_id"], name: "index_otu_page_layout_sections_on_project_id"
    t.index ["topic_id"], name: "index_otu_page_layout_sections_on_topic_id"
    t.index ["type"], name: "index_otu_page_layout_sections_on_type"
    t.index ["updated_by_id"], name: "index_otu_page_layout_sections_on_updated_by_id"
  end

  create_table "otu_page_layouts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "name", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_otu_page_layouts_on_created_by_id"
    t.index ["project_id"], name: "index_otu_page_layouts_on_project_id"
    t.index ["updated_by_id"], name: "index_otu_page_layouts_on_updated_by_id"
  end

  create_table "otu_relationships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.integer "object_otu_id", null: false
    t.bigint "project_id"
    t.integer "subject_otu_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_otu_relationships_on_created_by_id"
    t.index ["object_otu_id"], name: "index_otu_relationships_on_object_otu_id"
    t.index ["project_id"], name: "index_otu_relationships_on_project_id"
    t.index ["subject_otu_id"], name: "index_otu_relationships_on_subject_otu_id"
    t.index ["updated_by_id"], name: "index_otu_relationships_on_updated_by_id"
  end

  create_table "otus", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.text "name"
    t.integer "project_id", null: false
    t.integer "taxon_name_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_otus_on_created_by_id"
    t.index ["name"], name: "otu_name_gin_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["project_id"], name: "index_otus_on_project_id"
    t.index ["taxon_name_id"], name: "index_otus_on_taxon_name_id"
    t.index ["updated_at"], name: "index_otus_on_updated_at"
    t.index ["updated_by_id"], name: "index_otus_on_updated_by_id"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.text "cached"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "first_name"
    t.string "last_name", null: false
    t.string "prefix"
    t.string "suffix"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.integer "year_active_end"
    t.integer "year_active_start"
    t.integer "year_born"
    t.integer "year_died"
    t.index ["cached"], name: "index_people_on_cached"
    t.index ["cached"], name: "ppl_cached_gin_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["created_by_id"], name: "index_people_on_created_by_id"
    t.index ["last_name"], name: "index_people_on_last_name"
    t.index ["type"], name: "index_people_on_type"
    t.index ["updated_by_id"], name: "index_people_on_updated_by_id"
  end

  create_table "pinboard_items", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "inserted_count"
    t.boolean "is_cross_project"
    t.boolean "is_inserted"
    t.integer "pinned_object_id", null: false
    t.string "pinned_object_type", null: false
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.integer "user_id", null: false
    t.index ["created_by_id"], name: "index_pinboard_items_on_created_by_id"
    t.index ["pinned_object_type", "pinned_object_id"], name: "index_pinboard_items_on_pinned_object_type_and_pinned_object_id"
    t.index ["position"], name: "index_pinboard_items_on_position"
    t.index ["project_id"], name: "index_pinboard_items_on_project_id"
    t.index ["updated_by_id"], name: "index_pinboard_items_on_updated_by_id"
    t.index ["user_id"], name: "index_pinboard_items_on_user_id"
  end

  create_table "preparation_types", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.text "definition", null: false
    t.string "name", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_preparation_types_on_created_by_id"
    t.index ["updated_by_id"], name: "index_preparation_types_on_updated_by_id"
  end

  create_table "project_members", id: :serial, force: :cascade do |t|
    t.jsonb "clipboard", default: {}
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.boolean "is_project_administrator"
    t.datetime "last_seen_at", precision: nil
    t.integer "project_id", null: false
    t.integer "time_active", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.integer "user_id", null: false
    t.index ["created_by_id"], name: "index_project_members_on_created_by_id"
    t.index ["project_id"], name: "index_project_members_on_project_id"
    t.index ["updated_by_id"], name: "index_project_members_on_updated_by_id"
    t.index ["user_id"], name: "index_project_members_on_user_id"
  end

  create_table "project_sources", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "project_id", null: false
    t.integer "source_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_project_sources_on_created_by_id"
    t.index ["project_id"], name: "index_project_sources_on_project_id"
    t.index ["source_id"], name: "index_project_sources_on_source_id"
    t.index ["updated_by_id"], name: "index_project_sources_on_updated_by_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "api_access_token"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "data_curation_issue_tracker_url"
    t.string "name", null: false
    t.jsonb "preferences", default: {}, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_projects_on_created_by_id"
    t.index ["updated_by_id"], name: "index_projects_on_updated_by_id"
  end

  create_table "protocol_relationships", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.integer "protocol_id", null: false
    t.integer "protocol_relationship_object_id", null: false
    t.string "protocol_relationship_object_type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["project_id"], name: "index_protocol_relationships_on_project_id"
    t.index ["protocol_id"], name: "index_protocol_relationships_on_protocol_id"
  end

  create_table "protocols", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.text "description", null: false
    t.boolean "is_machine_output"
    t.string "name", null: false
    t.integer "project_id", null: false
    t.text "short_name", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["project_id"], name: "index_protocols_on_project_id"
  end

  create_table "public_contents", id: :serial, force: :cascade do |t|
    t.integer "content_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "otu_id", null: false
    t.integer "project_id", null: false
    t.text "text", null: false
    t.integer "topic_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["content_id"], name: "index_public_contents_on_content_id"
    t.index ["created_by_id"], name: "index_public_contents_on_created_by_id"
    t.index ["otu_id"], name: "index_public_contents_on_otu_id"
    t.index ["project_id"], name: "index_public_contents_on_project_id"
    t.index ["topic_id"], name: "index_public_contents_on_topic_id"
    t.index ["updated_by_id"], name: "index_public_contents_on_updated_by_id"
  end

  create_table "ranged_lot_categories", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "maximum_value"
    t.integer "minimum_value", null: false
    t.string "name", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_ranged_lot_categories_on_created_by_id"
    t.index ["project_id"], name: "index_ranged_lot_categories_on_project_id"
    t.index ["updated_by_id"], name: "index_ranged_lot_categories_on_updated_by_id"
  end

  create_table "repositories", id: :serial, force: :cascade do |t|
    t.string "acronym"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "institutional_LSID"
    t.boolean "is_index_herbariorum"
    t.string "name", null: false
    t.string "status"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.string "url"
    t.index ["created_by_id"], name: "index_repositories_on_created_by_id"
    t.index ["updated_by_id"], name: "index_repositories_on_updated_by_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.bigint "organization_id"
    t.integer "person_id"
    t.integer "position", null: false
    t.integer "project_id"
    t.integer "role_object_id", null: false
    t.string "role_object_type", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_at"], name: "index_roles_on_created_at"
    t.index ["created_by_id"], name: "index_roles_on_created_by_id"
    t.index ["organization_id"], name: "index_roles_on_organization_id"
    t.index ["person_id"], name: "index_roles_on_person_id"
    t.index ["position"], name: "index_roles_on_position"
    t.index ["project_id"], name: "index_roles_on_project_id"
    t.index ["role_object_id", "role_object_type"], name: "index_roles_on_role_object_id_and_type"
    t.index ["type"], name: "index_roles_on_type"
    t.index ["updated_at"], name: "index_roles_on_updated_at"
    t.index ["updated_by_id"], name: "index_roles_on_updated_by_id"
  end

  create_table "sequence_relationships", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "object_sequence_id", null: false
    t.integer "project_id", null: false
    t.integer "subject_sequence_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
  end

  create_table "sequences", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "name"
    t.integer "project_id", null: false
    t.text "sequence", null: false
    t.string "sequence_type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_sequences_on_created_by_id"
    t.index ["updated_at"], name: "index_sequences_on_updated_at"
    t.index ["updated_by_id"], name: "index_sequences_on_updated_by_id"
  end

  create_table "serial_chronologies", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "preceding_serial_id", null: false
    t.integer "succeeding_serial_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_serial_chronologies_on_created_by_id"
    t.index ["preceding_serial_id"], name: "index_serial_chronologies_on_preceding_serial_id"
    t.index ["succeeding_serial_id"], name: "index_serial_chronologies_on_succeeding_serial_id"
    t.index ["type"], name: "index_serial_chronologies_on_type"
    t.index ["updated_by_id"], name: "index_serial_chronologies_on_updated_by_id"
  end

  create_table "serials", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "first_year_of_issue", limit: 2
    t.boolean "is_electronic_only"
    t.integer "last_year_of_issue", limit: 2
    t.text "name", null: false
    t.string "place_published"
    t.integer "primary_language_id"
    t.text "publisher"
    t.integer "translated_from_serial_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_serials_on_created_by_id"
    t.index ["primary_language_id"], name: "index_serials_on_primary_language_id"
    t.index ["translated_from_serial_id"], name: "index_serials_on_translated_from_serial_id"
    t.index ["updated_by_id"], name: "index_serials_on_updated_by_id"
  end

  create_table "shortened_urls", id: :serial, force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", precision: nil
    t.datetime "expires_at", precision: nil
    t.integer "owner_id"
    t.string "owner_type", limit: 20
    t.string "unique_key", limit: 10, null: false
    t.datetime "updated_at", precision: nil
    t.text "url", null: false
    t.integer "use_count", default: 0, null: false
    t.index ["category"], name: "index_shortened_urls_on_category"
    t.index ["owner_id", "owner_type"], name: "index_shortened_urls_on_owner_id_and_owner_type"
    t.index ["unique_key"], name: "index_shortened_urls_on_unique_key", unique: true
    t.index ["url"], name: "index_shortened_urls_on_url"
  end

  create_table "sled_images", force: :cascade do |t|
    t.integer "cached_total_collection_objects", default: 0, null: false
    t.integer "cached_total_columns"
    t.integer "cached_total_rows"
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.bigint "image_id", null: false
    t.jsonb "metadata"
    t.jsonb "object_layout"
    t.bigint "project_id"
    t.datetime "updated_at", null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_sled_images_on_created_by_id"
    t.index ["image_id"], name: "index_sled_images_on_image_id"
    t.index ["project_id"], name: "index_sled_images_on_project_id"
    t.index ["updated_by_id"], name: "index_sled_images_on_updated_by_id"
  end

  create_table "sounds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.text "name"
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_sounds_on_created_by_id"
    t.index ["project_id"], name: "index_sounds_on_project_id"
    t.index ["updated_by_id"], name: "index_sounds_on_updated_by_id"
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.text "abstract"
    t.string "address"
    t.string "annote"
    t.text "author"
    t.string "bibtex_type"
    t.string "booktitle"
    t.text "cached"
    t.text "cached_author_string"
    t.date "cached_nomenclature_date"
    t.string "chapter"
    t.text "copyright"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.string "crossref"
    t.integer "day", limit: 2
    t.string "doi"
    t.string "edition"
    t.string "editor"
    t.string "howpublished"
    t.string "institution"
    t.string "isbn"
    t.string "issn"
    t.string "journal"
    t.string "key"
    t.string "language"
    t.integer "language_id"
    t.string "month"
    t.string "note"
    t.string "number"
    t.string "organization"
    t.string "pages"
    t.string "publisher"
    t.string "school"
    t.integer "serial_id"
    t.string "series"
    t.string "stated_year"
    t.text "title"
    t.string "translator"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.string "url"
    t.string "verbatim"
    t.text "verbatim_contents"
    t.text "verbatim_keywords"
    t.string "volume"
    t.integer "year", limit: 2
    t.string "year_suffix"
    t.index ["author"], name: "index_sources_on_author"
    t.index ["bibtex_type"], name: "index_sources_on_bibtex_type"
    t.index ["cached"], name: "index_sources_on_cached"
    t.index ["cached"], name: "src_cached_gin_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["cached_author_string"], name: "index_sources_on_cached_author_string"
    t.index ["cached_nomenclature_date"], name: "index_sources_on_cached_nomenclature_date"
    t.index ["created_at"], name: "index_sources_on_created_at"
    t.index ["created_by_id"], name: "index_sources_on_created_by_id"
    t.index ["language_id"], name: "index_sources_on_language_id"
    t.index ["serial_id"], name: "index_sources_on_serial_id"
    t.index ["title"], name: "index_sources_on_title"
    t.index ["type"], name: "index_sources_on_type"
    t.index ["updated_at"], name: "index_sources_on_updated_at"
    t.index ["updated_by_id"], name: "index_sources_on_updated_by_id"
    t.index ["year"], name: "index_sources_on_year"
  end

  create_table "sqed_depictions", id: :serial, force: :cascade do |t|
    t.string "boundary_color", null: false
    t.string "boundary_finder", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "depiction_id", null: false
    t.boolean "has_border", null: false
    t.datetime "in_progress", precision: nil
    t.string "layout", null: false
    t.jsonb "metadata_map", default: {}, null: false
    t.integer "project_id", null: false
    t.jsonb "result_boundary_coordinates"
    t.jsonb "result_ocr"
    t.jsonb "specimen_coordinates", default: {}, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["depiction_id"], name: "index_sqed_depictions_on_depiction_id"
    t.index ["project_id"], name: "index_sqed_depictions_on_project_id"
  end

  create_table "tagged_section_keywords", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "keyword_id", null: false
    t.integer "otu_page_layout_section_id", null: false
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_tagged_section_keywords_on_created_by_id"
    t.index ["keyword_id"], name: "index_tagged_section_keywords_on_keyword_id"
    t.index ["otu_page_layout_section_id"], name: "index_tagged_section_keywords_on_otu_page_layout_section_id"
    t.index ["position"], name: "index_tagged_section_keywords_on_position"
    t.index ["project_id"], name: "index_tagged_section_keywords_on_project_id"
    t.index ["updated_by_id"], name: "index_tagged_section_keywords_on_updated_by_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "keyword_id", null: false
    t.integer "position", null: false
    t.integer "project_id", null: false
    t.string "tag_object_attribute"
    t.integer "tag_object_id", null: false
    t.string "tag_object_type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_at"], name: "index_tags_on_created_at"
    t.index ["created_by_id"], name: "index_tags_on_created_by_id"
    t.index ["keyword_id"], name: "index_tags_on_keyword_id"
    t.index ["position"], name: "index_tags_on_position"
    t.index ["project_id"], name: "index_tags_on_project_id"
    t.index ["tag_object_id", "tag_object_type"], name: "index_tags_on_tag_object_id_and_type"
    t.index ["updated_at"], name: "index_tags_on_updated_at"
    t.index ["updated_by_id"], name: "index_tags_on_updated_by_id"
  end

  create_table "taxon_determinations", id: :serial, force: :cascade do |t|
    t.bigint "biological_collection_object_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "day_made"
    t.integer "month_made"
    t.integer "otu_id", null: false
    t.integer "position", null: false
    t.text "print_label"
    t.integer "project_id", null: false
    t.bigint "taxon_determination_object_id"
    t.string "taxon_determination_object_type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.integer "year_made"
    t.index ["biological_collection_object_id"], name: "index_taxon_determinations_on_biological_collection_object_id"
    t.index ["created_by_id"], name: "index_taxon_determinations_on_created_by_id"
    t.index ["otu_id"], name: "index_taxon_determinations_on_otu_id"
    t.index ["position"], name: "index_taxon_determinations_on_position"
    t.index ["project_id"], name: "index_taxon_determinations_on_project_id"
    t.index ["taxon_determination_object_type", "taxon_determination_object_id"], name: "td_poly"
    t.index ["updated_by_id"], name: "index_taxon_determinations_on_updated_by_id"
  end

  create_table "taxon_name_classifications", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "project_id", null: false
    t.integer "taxon_name_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_taxon_name_classifications_on_created_by_id"
    t.index ["project_id"], name: "index_taxon_name_classifications_on_project_id"
    t.index ["taxon_name_id"], name: "index_taxon_name_classifications_on_taxon_name_id"
    t.index ["type"], name: "index_taxon_name_classifications_on_type"
    t.index ["updated_by_id"], name: "index_taxon_name_classifications_on_updated_by_id"
  end

  create_table "taxon_name_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "taxon_name_anc_desc_idx", unique: true
    t.index ["ancestor_id", "descendant_id"], name: "index_taxon_name_hierarchies_on_ancestor_id_and_descendant_id"
    t.index ["ancestor_id"], name: "index_taxon_name_hierarchies_on_ancestor_id"
    t.index ["descendant_id"], name: "taxon_name_desc_idx"
  end

  create_table "taxon_name_relationships", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "object_taxon_name_id", null: false
    t.integer "project_id", null: false
    t.integer "subject_taxon_name_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["created_by_id"], name: "index_taxon_name_relationships_on_created_by_id"
    t.index ["object_taxon_name_id"], name: "index_taxon_name_relationships_on_object_taxon_name_id"
    t.index ["project_id"], name: "index_taxon_name_relationships_on_project_id"
    t.index ["subject_taxon_name_id"], name: "index_taxon_name_relationships_on_subject_taxon_name_id"
    t.index ["type"], name: "index_taxon_name_relationships_on_type"
    t.index ["updated_by_id"], name: "index_taxon_name_relationships_on_updated_by_id"
  end

  create_table "taxon_names", id: :serial, force: :cascade do |t|
    t.text "cached"
    t.text "cached_author"
    t.text "cached_author_year"
    t.text "cached_classified_as"
    t.text "cached_gender"
    t.text "cached_html"
    t.boolean "cached_is_available"
    t.boolean "cached_is_valid"
    t.boolean "cached_misspelling"
    t.date "cached_nomenclature_date"
    t.text "cached_original_combination"
    t.text "cached_original_combination_html"
    t.text "cached_primary_homonym"
    t.text "cached_primary_homonym_alternative_spelling"
    t.text "cached_secondary_homonym"
    t.text "cached_secondary_homonym_alternative_spelling"
    t.integer "cached_valid_taxon_name_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.text "etymology"
    t.text "feminine_name"
    t.text "masculine_name"
    t.text "name"
    t.text "neuter_name"
    t.integer "parent_id"
    t.integer "project_id", null: false
    t.text "rank_class"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.text "verbatim_author"
    t.text "verbatim_name"
    t.integer "year_of_publication"
    t.index ["cached"], name: "index_taxon_names_on_cached"
    t.index ["cached"], name: "tn_cached_gin_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["cached_author_year"], name: "tn_cached_auth_year_gin_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["cached_gender"], name: "index_taxon_names_on_cached_gender"
    t.index ["cached_is_available"], name: "index_taxon_names_on_cached_is_available"
    t.index ["cached_is_valid"], name: "index_taxon_names_on_cached_is_valid"
    t.index ["cached_original_combination"], name: "index_taxon_names_on_cached_original_combination"
    t.index ["cached_original_combination"], name: "tn_cached_original_gin_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["cached_valid_taxon_name_id"], name: "index_taxon_names_on_cached_valid_taxon_name_id"
    t.index ["created_at"], name: "index_taxon_names_on_created_at"
    t.index ["created_by_id"], name: "index_taxon_names_on_created_by_id"
    t.index ["name"], name: "index_taxon_names_on_name"
    t.index ["parent_id"], name: "index_taxon_names_on_parent_id"
    t.index ["project_id"], name: "index_taxon_names_on_project_id"
    t.index ["rank_class"], name: "index_taxon_names_on_rank_class"
    t.index ["type"], name: "index_taxon_names_on_type"
    t.index ["updated_at"], name: "index_taxon_names_on_updated_at"
    t.index ["updated_by_id"], name: "index_taxon_names_on_updated_by_id"
  end

  create_table "test_classes", id: :serial, force: :cascade do |t|
    t.boolean "boolean"
    t.datetime "created_at", precision: nil
    t.integer "created_by_id"
    t.integer "integer"
    t.integer "project_id"
    t.integer "sti_id"
    t.string "sti_type"
    t.string "string"
    t.text "text"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_test_classes_on_created_by_id"
    t.index ["project_id"], name: "index_test_classes_on_project_id"
    t.index ["updated_by_id"], name: "index_test_classes_on_updated_by_id"
  end

  create_table "type_materials", id: :serial, force: :cascade do |t|
    t.integer "collection_object_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "project_id", null: false
    t.integer "protonym_id", null: false
    t.string "type_type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id", null: false
    t.index ["collection_object_id"], name: "index_type_materials_on_collection_object_id"
    t.index ["created_by_id"], name: "index_type_materials_on_created_by_id"
    t.index ["project_id"], name: "index_type_materials_on_project_id"
    t.index ["protonym_id"], name: "index_type_materials_on_protonym_id"
    t.index ["type_type"], name: "index_type_materials_on_type_type"
    t.index ["updated_by_id"], name: "index_type_materials_on_updated_by_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "api_access_token"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id"
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", null: false
    t.json "footprints", default: {}
    t.json "hub_favorites"
    t.text "hub_tab_order", default: [], array: true
    t.boolean "is_administrator"
    t.boolean "is_flagged_for_password_reset", default: false
    t.datetime "last_seen_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "password_reset_token"
    t.datetime "password_reset_token_date", precision: nil
    t.bigint "person_id"
    t.json "preferences", default: {}
    t.string "remember_token"
    t.integer "sign_in_count", default: 0
    t.integer "time_active", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["person_id"], name: "index_users_on_person_id"
    t.index ["remember_token"], name: "index_users_on_remember_token"
    t.index ["updated_by_id"], name: "index_users_on_updated_by_id"
  end

  create_table "version_associations", id: :serial, force: :cascade do |t|
    t.integer "foreign_key_id"
    t.string "foreign_key_name", null: false
    t.integer "version_id"
    t.index ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.integer "transaction_id"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alternate_values", "languages", name: "alternate_values_language_id_fkey"
  add_foreign_key "alternate_values", "projects", name: "alternate_values_project_id_fkey"
  add_foreign_key "alternate_values", "users", column: "created_by_id", name: "alternate_values_created_by_id_fkey"
  add_foreign_key "alternate_values", "users", column: "updated_by_id", name: "alternate_values_updated_by_id_fkey"
  add_foreign_key "anatomical_parts", "otus", column: "cached_otu_id"
  add_foreign_key "anatomical_parts", "preparation_types"
  add_foreign_key "anatomical_parts", "projects"
  add_foreign_key "anatomical_parts", "users", column: "created_by_id"
  add_foreign_key "anatomical_parts", "users", column: "updated_by_id"
  add_foreign_key "asserted_distributions", "projects", name: "asserted_distributions_project_id_fkey"
  add_foreign_key "asserted_distributions", "users", column: "created_by_id", name: "asserted_distributions_created_by_id_fkey"
  add_foreign_key "asserted_distributions", "users", column: "updated_by_id", name: "asserted_distributions_updated_by_id_fkey"
  add_foreign_key "attributions", "projects"
  add_foreign_key "attributions", "users", column: "created_by_id"
  add_foreign_key "attributions", "users", column: "updated_by_id"
  add_foreign_key "biocuration_classifications", "controlled_vocabulary_terms", column: "biocuration_class_id", name: "biocuration_classifications_biocuration_class_id_fkey"
  add_foreign_key "biocuration_classifications", "projects", name: "biocuration_classifications_project_id_fkey"
  add_foreign_key "biocuration_classifications", "users", column: "created_by_id", name: "biocuration_classifications_created_by_id_fkey"
  add_foreign_key "biocuration_classifications", "users", column: "updated_by_id", name: "biocuration_classifications_updated_by_id_fkey"
  add_foreign_key "biological_association_indices", "biological_associations"
  add_foreign_key "biological_association_indices", "biological_relationships"
  add_foreign_key "biological_association_indices", "projects"
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
  add_foreign_key "cached_map_item_translations", "geographic_items"
  add_foreign_key "cached_map_item_translations", "geographic_items", column: "translated_geographic_item_id"
  add_foreign_key "cached_map_registers", "projects"
  add_foreign_key "character_states", "descriptors"
  add_foreign_key "character_states", "projects"
  add_foreign_key "character_states", "users", column: "created_by_id"
  add_foreign_key "character_states", "users", column: "updated_by_id"
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
  add_foreign_key "containers", "projects", name: "containers_project_id_fkey"
  add_foreign_key "containers", "users", column: "created_by_id", name: "containers_created_by_id_fkey"
  add_foreign_key "containers", "users", column: "updated_by_id", name: "containers_updated_by_id_fkey"
  add_foreign_key "contents", "controlled_vocabulary_terms", column: "topic_id", name: "contents_topic_id_fkey"
  add_foreign_key "contents", "languages"
  add_foreign_key "contents", "otus", name: "contents_otu_id_fkey"
  add_foreign_key "contents", "projects", name: "contents_project_id_fkey"
  add_foreign_key "contents", "users", column: "created_by_id", name: "contents_created_by_id_fkey"
  add_foreign_key "contents", "users", column: "updated_by_id", name: "contents_updated_by_id_fkey"
  add_foreign_key "controlled_vocabulary_terms", "projects", name: "controlled_vocabulary_terms_project_id_fkey"
  add_foreign_key "controlled_vocabulary_terms", "users", column: "created_by_id", name: "controlled_vocabulary_terms_created_by_id_fkey"
  add_foreign_key "controlled_vocabulary_terms", "users", column: "updated_by_id", name: "controlled_vocabulary_terms_updated_by_id_fkey"
  add_foreign_key "conveyances", "projects"
  add_foreign_key "conveyances", "sounds"
  add_foreign_key "conveyances", "users", column: "created_by_id"
  add_foreign_key "conveyances", "users", column: "updated_by_id"
  add_foreign_key "data_attributes", "controlled_vocabulary_terms", name: "data_attributes_controlled_vocabulary_term_id_fkey"
  add_foreign_key "data_attributes", "projects", name: "data_attributes_project_id_fkey"
  add_foreign_key "data_attributes", "users", column: "created_by_id", name: "data_attributes_created_by_id_fkey"
  add_foreign_key "data_attributes", "users", column: "updated_by_id", name: "data_attributes_updated_by_id_fkey"
  add_foreign_key "dataset_record_fields", "dataset_records"
  add_foreign_key "dataset_record_fields", "import_datasets"
  add_foreign_key "dataset_record_fields", "projects"
  add_foreign_key "dataset_records", "import_datasets"
  add_foreign_key "dataset_records", "projects"
  add_foreign_key "depictions", "sled_images"
  add_foreign_key "descriptors", "projects"
  add_foreign_key "descriptors", "users", column: "created_by_id"
  add_foreign_key "descriptors", "users", column: "updated_by_id"
  add_foreign_key "documentation", "documents"
  add_foreign_key "documentation", "projects"
  add_foreign_key "documentation", "users", column: "created_by_id"
  add_foreign_key "documentation", "users", column: "updated_by_id"
  add_foreign_key "documents", "users", column: "created_by_id"
  add_foreign_key "documents", "users", column: "updated_by_id"
  add_foreign_key "downloads", "projects"
  add_foreign_key "downloads", "users", column: "created_by_id"
  add_foreign_key "downloads", "users", column: "updated_by_id"
  add_foreign_key "dwc_occurrences", "projects"
  add_foreign_key "dwc_occurrences", "users", column: "created_by_id"
  add_foreign_key "dwc_occurrences", "users", column: "updated_by_id"
  add_foreign_key "extracts", "projects"
  add_foreign_key "extracts", "repositories"
  add_foreign_key "extracts", "users", column: "created_by_id"
  add_foreign_key "extracts", "users", column: "updated_by_id"
  add_foreign_key "field_occurrences", "collecting_events"
  add_foreign_key "field_occurrences", "projects"
  add_foreign_key "field_occurrences", "ranged_lot_categories"
  add_foreign_key "field_occurrences", "users", column: "created_by_id"
  add_foreign_key "field_occurrences", "users", column: "updated_by_id"
  add_foreign_key "gazetteer_imports", "projects"
  add_foreign_key "gazetteers", "projects"
  add_foreign_key "gene_attributes", "controlled_vocabulary_terms"
  add_foreign_key "gene_attributes", "projects"
  add_foreign_key "gene_attributes", "sequences"
  add_foreign_key "gene_attributes", "users", column: "created_by_id"
  add_foreign_key "gene_attributes", "users", column: "updated_by_id"
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
  add_foreign_key "import_datasets", "projects"
  add_foreign_key "labels", "projects"
  add_foreign_key "labels", "users", column: "created_by_id", name: "labels_created_by_id_fk"
  add_foreign_key "labels", "users", column: "updated_by_id", name: "labels_updated_by_id_fk"
  add_foreign_key "languages", "users", column: "created_by_id", name: "languages_created_by_id_fkey"
  add_foreign_key "languages", "users", column: "updated_by_id", name: "languages_updated_by_id_fkey"
  add_foreign_key "lead_items", "projects"
  add_foreign_key "leads", "leads", column: "parent_id"
  add_foreign_key "leads", "leads", column: "redirect_id"
  add_foreign_key "leads", "observation_matrices", on_delete: :nullify
  add_foreign_key "leads", "otus"
  add_foreign_key "leads", "projects"
  add_foreign_key "loan_items", "loans", name: "loan_items_loan_id_fkey"
  add_foreign_key "loan_items", "projects", name: "loan_items_project_id_fkey"
  add_foreign_key "loan_items", "users", column: "created_by_id", name: "loan_items_created_by_id_fkey"
  add_foreign_key "loan_items", "users", column: "updated_by_id", name: "loan_items_updated_by_id_fkey"
  add_foreign_key "loans", "projects", name: "loans_project_id_fkey"
  add_foreign_key "loans", "users", column: "created_by_id", name: "loans_created_by_id_fkey"
  add_foreign_key "loans", "users", column: "updated_by_id", name: "loans_updated_by_id_fkey"
  add_foreign_key "namespaces", "users", column: "created_by_id", name: "namespaces_created_by_id_fkey"
  add_foreign_key "namespaces", "users", column: "updated_by_id", name: "namespaces_updated_by_id_fkey"
  add_foreign_key "news", "projects"
  add_foreign_key "news", "users", column: "created_by_id"
  add_foreign_key "news", "users", column: "updated_by_id"
  add_foreign_key "notes", "projects", name: "notes_project_id_fkey"
  add_foreign_key "notes", "users", column: "created_by_id", name: "notes_created_by_id_fkey"
  add_foreign_key "notes", "users", column: "updated_by_id", name: "notes_updated_by_id_fkey"
  add_foreign_key "observation_matrices", "otus"
  add_foreign_key "observation_matrices", "projects"
  add_foreign_key "observation_matrices", "users", column: "created_by_id"
  add_foreign_key "observation_matrices", "users", column: "updated_by_id"
  add_foreign_key "observation_matrix_column_items", "controlled_vocabulary_terms"
  add_foreign_key "observation_matrix_column_items", "descriptors"
  add_foreign_key "observation_matrix_column_items", "observation_matrices"
  add_foreign_key "observation_matrix_column_items", "projects"
  add_foreign_key "observation_matrix_column_items", "users", column: "created_by_id"
  add_foreign_key "observation_matrix_column_items", "users", column: "updated_by_id"
  add_foreign_key "observation_matrix_columns", "descriptors"
  add_foreign_key "observation_matrix_columns", "observation_matrices"
  add_foreign_key "observation_matrix_columns", "projects"
  add_foreign_key "observation_matrix_columns", "users", column: "created_by_id"
  add_foreign_key "observation_matrix_columns", "users", column: "updated_by_id"
  add_foreign_key "observation_matrix_row_items", "controlled_vocabulary_terms"
  add_foreign_key "observation_matrix_row_items", "observation_matrices"
  add_foreign_key "observation_matrix_row_items", "projects"
  add_foreign_key "observation_matrix_row_items", "taxon_names"
  add_foreign_key "observation_matrix_row_items", "users", column: "created_by_id"
  add_foreign_key "observation_matrix_row_items", "users", column: "updated_by_id"
  add_foreign_key "observation_matrix_rows", "observation_matrices"
  add_foreign_key "observation_matrix_rows", "projects"
  add_foreign_key "observation_matrix_rows", "users", column: "created_by_id"
  add_foreign_key "observation_matrix_rows", "users", column: "updated_by_id"
  add_foreign_key "observations", "descriptors"
  add_foreign_key "observations", "projects"
  add_foreign_key "observations", "users", column: "created_by_id"
  add_foreign_key "observations", "users", column: "updated_by_id"
  add_foreign_key "organizations", "geographic_areas", column: "area_served_id"
  add_foreign_key "organizations", "organizations", column: "department_id"
  add_foreign_key "organizations", "organizations", column: "parent_organization_id"
  add_foreign_key "organizations", "organizations", column: "same_as_id"
  add_foreign_key "organizations", "users", column: "created_by_id"
  add_foreign_key "organizations", "users", column: "updated_by_id"
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
  add_foreign_key "otu_relationships", "otus", column: "object_otu_id"
  add_foreign_key "otu_relationships", "otus", column: "subject_otu_id"
  add_foreign_key "otu_relationships", "projects"
  add_foreign_key "otu_relationships", "users", column: "created_by_id"
  add_foreign_key "otu_relationships", "users", column: "updated_by_id"
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
  add_foreign_key "roles", "organizations"
  add_foreign_key "roles", "people", name: "roles_person_id_fkey"
  add_foreign_key "roles", "projects", name: "roles_project_id_fkey"
  add_foreign_key "roles", "users", column: "created_by_id", name: "roles_created_by_id_fkey"
  add_foreign_key "roles", "users", column: "updated_by_id", name: "roles_updated_by_id_fkey"
  add_foreign_key "sequence_relationships", "projects"
  add_foreign_key "sequence_relationships", "sequences", column: "object_sequence_id"
  add_foreign_key "sequence_relationships", "sequences", column: "subject_sequence_id"
  add_foreign_key "sequence_relationships", "users", column: "created_by_id"
  add_foreign_key "sequence_relationships", "users", column: "updated_by_id"
  add_foreign_key "sequences", "projects"
  add_foreign_key "sequences", "users", column: "created_by_id"
  add_foreign_key "sequences", "users", column: "updated_by_id"
  add_foreign_key "serial_chronologies", "serials", column: "preceding_serial_id", name: "serial_chronologies_preceding_serial_id_fkey"
  add_foreign_key "serial_chronologies", "serials", column: "succeeding_serial_id", name: "serial_chronologies_succeeding_serial_id_fkey"
  add_foreign_key "serial_chronologies", "users", column: "created_by_id", name: "serial_chronologies_created_by_id_fkey"
  add_foreign_key "serial_chronologies", "users", column: "updated_by_id", name: "serial_chronologies_updated_by_id_fkey"
  add_foreign_key "serials", "languages", column: "primary_language_id", name: "serials_primary_language_id_fkey"
  add_foreign_key "serials", "serials", column: "translated_from_serial_id", name: "serials_translated_from_serial_id_fkey"
  add_foreign_key "serials", "users", column: "created_by_id", name: "serials_created_by_id_fkey"
  add_foreign_key "serials", "users", column: "updated_by_id", name: "serials_updated_by_id_fkey"
  add_foreign_key "sled_images", "projects"
  add_foreign_key "sled_images", "users", column: "created_by_id"
  add_foreign_key "sled_images", "users", column: "updated_by_id"
  add_foreign_key "sounds", "projects"
  add_foreign_key "sounds", "users", column: "created_by_id"
  add_foreign_key "sounds", "users", column: "updated_by_id"
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
  add_foreign_key "type_materials", "collection_objects", name: "type_materials_biological_object_id_fkey"
  add_foreign_key "type_materials", "projects", name: "type_materials_project_id_fkey"
  add_foreign_key "type_materials", "taxon_names", column: "protonym_id", name: "type_materials_protonym_id_fkey"
  add_foreign_key "type_materials", "users", column: "created_by_id", name: "type_materials_created_by_id_fkey"
  add_foreign_key "type_materials", "users", column: "updated_by_id", name: "type_materials_updated_by_id_fkey"
  add_foreign_key "users", "people"
  add_foreign_key "users", "users", column: "created_by_id", name: "users_created_by_id_fkey"
  add_foreign_key "users", "users", column: "updated_by_id", name: "users_updated_by_id_fkey"
end
