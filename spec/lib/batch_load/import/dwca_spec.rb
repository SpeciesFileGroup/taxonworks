require 'rails_helper'
require 'batch_load/import/collection_objects'

describe BatchLoad::Import::DWCA, type: :model do
  let(:file_name) {'spec/files/batch/dwca/PSUC3-Test.tsv'}

  xcontext 'building objects from valid tsv lines' do

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

    context 'file provided' do
      it 'loads supplied data' do
        result = import.rows
        expect(result).to be_truthy
        expect(Otu.count).to eq(1)
        expect(Identifier.count).to eq(304) # one built above, one for each co in import
        expect(CollectingEvent.count).to eq(140)
        expect(Georeference.count).to eq(65)
        expect(result.processed_rows[61].objects[:ce].first.verbatim_locality).to eq('Collecting Event No. 59353')
      end
    end
  end
end
