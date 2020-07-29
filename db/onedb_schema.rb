# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_27_232820) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "tblAuthUsers", primary_key: "AuthUserID", force: :cascade do |t|
    t.string "Name"
    t.string "HashedPassword"
    t.string "FullName"
    t.integer "TaxaShowSpecs"
    t.integer "CiteShowSpecs"
    t.integer "SpmnShowSpecs"
    t.datetime "LastUpdate"
    t.integer "ModifiedBy"
    t.datetime "CreatedOn"
    t.integer "CreatedBy"
    t.index ["CreatedBy"], name: "index_tblAuthUsers_on_CreatedBy"
    t.index ["ModifiedBy"], name: "index_tblAuthUsers_on_ModifiedBy"
  end

  create_table "tblCites", force: :cascade do |t|
    t.integer "TaxonNameID"
    t.integer "SeqNum"
    t.integer "RefID"
    t.string "CitePages"
    t.string "Note"
    t.integer "NomenclatorID"
    t.integer "NewNameStatusID"
    t.integer "TypeInfoID"
    t.integer "ConceptChangeID"
    t.boolean "CurrentConcept"
    t.integer "InfoFlags"
    t.integer "InfoFlagStatus"
    t.integer "PolynomialStatus"
    t.datetime "LastUpdate"
    t.integer "ModifiedBy"
    t.datetime "CreatedOn"
    t.integer "CreatedBy"
    t.index ["ConceptChangeID"], name: "index_tblCites_on_ConceptChangeID"
    t.index ["CreatedBy"], name: "index_tblCites_on_CreatedBy"
    t.index ["ModifiedBy"], name: "index_tblCites_on_ModifiedBy"
    t.index ["NewNameStatusID"], name: "index_tblCites_on_NewNameStatusID"
    t.index ["NomenclatorID"], name: "index_tblCites_on_NomenclatorID"
    t.index ["RefID"], name: "index_tblCites_on_RefID"
    t.index ["TaxonNameID", "SeqNum"], name: "index_tblCites_on_TaxonNameID_and_SeqNum"
    t.index ["TypeInfoID"], name: "index_tblCites_on_TypeInfoID"
  end

  create_table "tblFileUsers", primary_key: "FileUserID", force: :cascade do |t|
    t.integer "AuthUserID"
    t.integer "FileID"
    t.integer "Access"
    t.datetime "LastLogin"
    t.integer "NumLogins"
    t.datetime "LastEdit"
    t.integer "NumEdits"
    t.datetime "CreatedOn"
    t.integer "CreatedBy"
    t.index ["AuthUserID"], name: "index_tblFileUsers_on_AuthUserID"
    t.index ["CreatedBy"], name: "index_tblFileUsers_on_CreatedBy"
    t.index ["FileID"], name: "index_tblFileUsers_on_FileID"
  end

  create_table "tblFiles", primary_key: "FileID", force: :cascade do |t|
    t.integer "FileTypeID"
    t.string "WebsiteName"
    t.integer "AboveID"
    t.string "Description"
    t.string "URL"
    t.string "DateStarted"
    t.integer "NumSpecies"
    t.integer "NumNames"
    t.integer "NumCites"
    t.integer "NumImages"
    t.integer "NumSpecimens"
    t.integer "NumKeyEndPoints"
    t.string "FileVersion"
    t.integer "Flags"
    t.datetime "LastUpdate"
    t.integer "ModifiedBy"
    t.datetime "CreatedOn"
    t.integer "CreatedBy"
    t.string "ContactPerson"
    t.string "ContactEmail"
  end

  create_table "tblGenusNames", primary_key: "GenusNameID", force: :cascade do |t|
    t.integer "FileID"
    t.string "Name"
    t.boolean "Italicize"
    t.datetime "LastUpdate"
    t.integer "ModifiedBy"
    t.datetime "CreatedOn"
    t.integer "CreatedBy"
    t.index ["CreatedBy"], name: "index_tblGenusNames_on_CreatedBy"
    t.index ["FileID", "Name"], name: "index_tblGenusNames_on_FileID_and_Name"
    t.index ["FileID"], name: "index_tblGenusNames_on_FileID"
    t.index ["ModifiedBy"], name: "index_tblGenusNames_on_ModifiedBy"
  end

  create_table "tblNomenclator", primary_key: "NomenclatorID", force: :cascade do |t|
    t.integer "FileID"
    t.integer "GenusNameID"
    t.integer "SubgenusNameID"
    t.integer "InfragenusNameID"
    t.integer "SpeciesSeriesNameID"
    t.integer "SpeciesGroupNameID"
    t.integer "SpeciesSubgroupNameID"
    t.integer "SpeciesNameID"
    t.integer "SubspeciesNameID"
    t.integer "InfrasubKind"
    t.integer "InfrasubspeciesNameID"
    t.integer "SuitableForRanks"
    t.string "IdentQualifier"
    t.integer "RankQualified"
    t.datetime "LastUpdate"
    t.integer "ModifiedBy"
    t.datetime "CreatedOn"
    t.integer "CreatedBy"
    t.index ["CreatedBy"], name: "index_tblNomenclator_on_CreatedBy"
    t.index ["FileID"], name: "index_tblNomenclator_on_FileID"
    t.index ["GenusNameID"], name: "index_tblNomenclator_on_GenusNameID"
    t.index ["InfragenusNameID"], name: "index_tblNomenclator_on_InfragenusNameID"
    t.index ["InfrasubspeciesNameID"], name: "index_tblNomenclator_on_InfrasubspeciesNameID"
    t.index ["ModifiedBy"], name: "index_tblNomenclator_on_ModifiedBy"
    t.index ["SpeciesGroupNameID"], name: "index_tblNomenclator_on_SpeciesGroupNameID"
    t.index ["SpeciesNameID"], name: "index_tblNomenclator_on_SpeciesNameID"
    t.index ["SpeciesSeriesNameID"], name: "index_tblNomenclator_on_SpeciesSeriesNameID"
    t.index ["SpeciesSubgroupNameID"], name: "index_tblNomenclator_on_SpeciesSubgroupNameID"
    t.index ["SubgenusNameID"], name: "index_tblNomenclator_on_SubgenusNameID"
    t.index ["SubspeciesNameID"], name: "index_tblNomenclator_on_SubspeciesNameID"
  end

  create_table "tblRanks", primary_key: "RankID", force: :cascade do |t|
    t.string "RankName"
    t.integer "DefaultLevel"
  end

  create_table "tblSpeciesNames", primary_key: "SpeciesNameID", force: :cascade do |t|
    t.integer "FileID"
    t.string "Name"
    t.boolean "Italicize"
    t.datetime "LastUpdate"
    t.integer "ModifiedBy"
    t.datetime "CreatedOn"
    t.integer "CreatedBy"
    t.index ["CreatedBy"], name: "index_tblSpeciesNames_on_CreatedBy"
    t.index ["FileID", "Name"], name: "index_tblSpeciesNames_on_FileID_and_Name"
    t.index ["FileID"], name: "index_tblSpeciesNames_on_FileID"
    t.index ["ModifiedBy"], name: "index_tblSpeciesNames_on_ModifiedBy"
  end

  create_table "tblTaxa", primary_key: "TaxonNameID", force: :cascade do |t|
    t.integer "FileID"
    t.string "TaxonNameStr"
    t.integer "RankID"
    t.string "Name"
    t.boolean "Parens"
    t.integer "AboveID"
    t.integer "LikeNameID"
    t.integer "Extinct"
    t.integer "RefID"
    t.string "NecAuthor"
    t.integer "DataFlags"
    t.integer "AccessCode"
    t.integer "NameStatus"
    t.integer "StatusFlags"
    t.integer "OriginalGenusID"
    t.string "Distribution"
    t.string "Ecology"
    t.string "Comment"
    t.integer "ExpertID"
    t.integer "ExpertReason"
    t.integer "CurrentConceptRefID"
    t.integer "LifeZone"
    t.datetime "LastUpdate"
    t.integer "ModifiedBy"
    t.datetime "CreatedOn"
    t.integer "CreatedBy"
    t.integer "UnavailFlags"
    t.boolean "HasPreHolocene"
    t.boolean "HasModern"
    t.index ["AboveID"], name: "index_tblTaxa_on_AboveID"
    t.index ["CreatedBy"], name: "index_tblTaxa_on_CreatedBy"
    t.index ["CurrentConceptRefID"], name: "index_tblTaxa_on_CurrentConceptRefID"
    t.index ["ExpertID"], name: "index_tblTaxa_on_ExpertID"
    t.index ["FileID", "Name"], name: "index_tblTaxa_on_FileID_and_Name"
    t.index ["FileID", "RankID"], name: "index_tblTaxa_on_FileID_and_RankID"
    t.index ["FileID", "TaxonNameStr"], name: "index_tblTaxa_on_FileID_and_TaxonNameStr"
    t.index ["FileID"], name: "index_tblTaxa_on_FileID"
    t.index ["LikeNameID"], name: "index_tblTaxa_on_LikeNameID"
    t.index ["ModifiedBy"], name: "index_tblTaxa_on_ModifiedBy"
    t.index ["OriginalGenusID"], name: "index_tblTaxa_on_OriginalGenusID"
    t.index ["RefID"], name: "index_tblTaxa_on_RefID"
  end

end
