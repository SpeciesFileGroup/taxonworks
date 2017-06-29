require 'rails_helper'
require 'batch_load/import/collection_objects'

describe BatchLoad::Import::DWCA, type: :model do
  # iconv -f iso-8859-15 -t UTF-8  spec/files/batch/dwca/PSUC3-Test.txt >spec/files/batch/dwca/PSUC3-Test.utf8.txt
  let(:file_name) {'spec/files/batch/dwca/PSUC3-Test.utf8.txt'}

  context 'building objects from valid tsv lines' do

    let(:user) {User.find(1)}
    let(:project) {Project.find(1)}

    let(:upload_file) {fixture_file_upload(file_name)}
    let(:root) {Protonym.find_or_create_by(name:       'Root',
                                           rank_class: 'NomenclaturalRank',
                                           parent_id:  nil,
                                           project:    project)
    }
    let(:kingdom) {Protonym.find_or_create_by(name:       'Animalia',
                                              parent:     root,
                                              rank_class: NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom,
                                              project:    project)}
    let(:cat_no_pred) {Predicate.find_or_create_by(name:       'catalogNumber',
                                                   definition: 'The verbatim value imported from PSUC for "catalogNumber".',
                                                   project:    $project)}
    let(:geo_rem_kw) {Keyword.find_or_create_by(name:       'georeferenceRemarks',
                                                definition: 'The verbatim value imported from PSUC for "georeferenceRemarks".',
                                                project:    $project)}
    let(:repo) {Repository.find_or_create_by(name:                 'Frost Entomological Museum, Penn State University',
                                             url:                  'http://grbio.org/institution/frost-entomological-museum-penn-state-university',
                                             status:               'Yes',
                                             acronym:              'PSUC',
                                             is_index_herbariorum: false)}
    let(:namespace) {Namespace.find_or_create_by(institution: 'Penn State University Collection',
                                                 name:        'Frost Entomological Museum',
                                                 short_name:  'PSUC_FEM')}
    let(:pre_load) {{root:        root,
                     kingdom:     kingdom,
                     cat_no_pred: cat_no_pred,
                     geo_rem_kw:  geo_rem_kw,
                     repo:        repo,
                     namespace:   namespace}}
    let(:import) {BatchLoad::Import::DWCA::new({project_id: project.id,
                                                user_id:    user.id,
                                                file:       upload_file}.merge(pre_load))
    }
    let(:event) {CollectingEvent.create(verbatim_date: 'some more text')}

    context 'file provided' do
      it 'loads supplied data' do
        pre_load
        result = import.rows
        expect(result).to be_truthy
        expect(CollectionObject.count).to eq(24)
        expect(Otu.count).to eq(27)
        expect(BiologicalRelationship.count).to eq(1)
        expect(BiologicalAssociation.count).to eq(5)
        expect(CollectingEvent.count).to eq(21) # some of the collecting events are used more than once
        expect(TaxonDetermination.count).to eq(24) # one for each new OTU
        expect(Identifier.count).to eq(35) # 25 identifiers, the last one fails
        expect(Identifier.of_type(:catalog_number).count).to eq(24)
        expect(Identifier.of_type(:occurrence_id).count).to eq(11)
        expect(Identifier.of_type(:catalog_number).first.identifier).to eq('107450')
        expect(Identifier.of_type(:catalog_number).last.identifier).to eq('107690')
        expect(Georeference.count).to eq(18)
        expect(Georeference::VerbatimData.count).to eq(1) # 'verbatim' in georeferencedBy
        expect(Georeference::GeoLocate.count).to eq(17)
        expect(Note.count).to eq(9)
        expect(TaxonName.count).to eq(43)
        expect(Person.count).to eq(4)
        expect(Note.all.map(&:note_object_type).uniq).to include("Georeference",
                                                                 "CollectingEvent",
                                                                 "CollectionObject")
        # expect(result.processed_rows[61].objects[:ce].first.verbatim_locality).to eq('Collecting Event No. 59353')
      end
    end
  end
end
