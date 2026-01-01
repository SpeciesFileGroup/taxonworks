require 'rails_helper'

RSpec.describe Export::Dwca::Occurrence::PredicateExporter, type: :model do
  let(:project) { FactoryBot.create(:valid_project) }
  let(:user) { FactoryBot.create(:valid_user) }
  let(:current_user_id) { user.id }
  let(:current_project_id) { project.id }

  before do
    # Set up project context
    ProjectsController.send(:define_method, :sessions_current_project_id) { current_project_id }
    ProjectsController.send(:define_method, :sessions_current_user_id) { current_user_id }
  end

  describe '#export_to' do
    let!(:specimen1) { FactoryBot.create(:valid_specimen, project: project) }
    let!(:specimen2) { FactoryBot.create(:valid_specimen, project: project) }
    let(:collection_objects) { CollectionObject.where(project_id: project.id) }
    let(:core_scope) { DwcOccurrence.where(project_id: project.id) }

    before do
      # Ensure dwc_occurrences exist
      specimen1.get_dwc_occurrence
      specimen2.get_dwc_occurrence
    end

    context 'with no predicates' do
      let(:exporter) { described_class.new(
        core_scope: core_scope,
        collection_object_predicate_ids: [],
        collecting_event_predicate_ids: []
      )}

      it 'returns empty file when no predicates configured' do
        output = Tempfile.new('test_predicates')
        result = exporter.export_to(output)
        output.rewind

        content = output.read
        expect(content).to be_empty

        output.close
        output.unlink
      end
    end

    context 'with collection object predicates' do
      let!(:predicate) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate, project: project) }
      let!(:data_attr1) { FactoryBot.create(:valid_data_attribute_internal_attribute,
        attribute_subject: specimen1,
        predicate: predicate,
        value: 'test value 1'
      )}
      let!(:data_attr2) { FactoryBot.create(:valid_data_attribute_internal_attribute,
        attribute_subject: specimen2,
        predicate: predicate,
        value: 'test value 2'
      )}

      let(:exporter) { described_class.new(
        core_scope: core_scope,
        collection_object_predicate_ids: [predicate.id],
        collecting_event_predicate_ids: []
      )}

      it 'exports predicate data' do
        output = Tempfile.new('test_predicates')
        result = exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Should have header + data rows
        expect(lines.count).to be >= 2

        # Header should include predicate name
        expect(lines.first).to include(predicate.name)

        # Data rows should have values
        expect(content).to include('test value 1')
        expect(content).to include('test value 2')

        output.close
        output.unlink
      end

      it 'only includes predicates with data' do
        unused_predicate = FactoryBot.create(:valid_controlled_vocabulary_term_predicate, project: project)

        exporter_with_unused = described_class.new(
          core_scope: core_scope,
          collection_object_predicate_ids: [predicate.id, unused_predicate.id],
          collecting_event_predicate_ids: []
        )

        output = Tempfile.new('test_predicates')
        result = exporter_with_unused.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Header should include used predicate
        expect(lines.first).to include(predicate.name)

        # Header should NOT include unused predicate
        expect(lines.first).not_to include(unused_predicate.name)

        output.close
        output.unlink
      end
    end

    context 'with collecting event predicates' do
      let!(:ce1) { FactoryBot.create(:valid_collecting_event) }
      let!(:ce2) { FactoryBot.create(:valid_collecting_event) }
      let!(:ce_specimen1) { FactoryBot.create(:valid_specimen, collecting_event: ce1) }
      let!(:ce_specimen2) { FactoryBot.create(:valid_specimen, collecting_event: ce2) }
      let(:ce_collection_objects) { CollectionObject.where(id: [ce_specimen1.id, ce_specimen2.id]) }
      let(:ce_core_scope) { DwcOccurrence.where(dwc_occurrence_object_id: [ce_specimen1.id, ce_specimen2.id], dwc_occurrence_object_type: 'CollectionObject') }
      let!(:predicate) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate, project: project) }
      let!(:data_attr1) { FactoryBot.create(:valid_data_attribute_internal_attribute,
        attribute_subject: ce1,
        predicate: predicate,
        value: 'ce value 1'
      )}
      let!(:data_attr2) { FactoryBot.create(:valid_data_attribute_internal_attribute,
        attribute_subject: ce2,
        predicate: predicate,
        value: 'ce value 2'
      )}

      before do
        ce_specimen1.get_dwc_occurrence
        ce_specimen2.get_dwc_occurrence
      end

      let(:exporter) { described_class.new(
        core_scope: ce_core_scope,
        collection_object_predicate_ids: [],
        collecting_event_predicate_ids: [predicate.id]
      )}

      it 'exports collecting event predicate data' do
        output = Tempfile.new('test_predicates')
        result = exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Should have header + data rows
        expect(lines.count).to be >= 2

        # Header should include predicate name with CE prefix
        expect(lines.first).to include(predicate.name)

        # Data rows should have values
        expect(content).to include('ce value 1')
        expect(content).to include('ce value 2')

        output.close
        output.unlink
      end
    end
  end
end
