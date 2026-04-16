require 'rails_helper'

RSpec.describe Export::Dwca::Occurrence::PredicateExporter, type: :model do
  let(:project) { FactoryBot.create(:valid_project) }

  describe '#export_to' do
    let!(:specimen1) { FactoryBot.create(:valid_specimen, no_dwc_occurrence: false) }
    let!(:specimen2) { FactoryBot.create(:valid_specimen,  no_dwc_occurrence: false) }
    let(:collection_objects) { CollectionObject.all }
    let(:core_scope) { DwcOccurrence.all }

    context 'with no predicates' do
      let(:exporter) { described_class.new(
        core_scope: core_scope,
        collection_object_predicate_ids: [],
        collecting_event_predicate_ids: []
      )}

      specify 'returns empty file when no predicates configured' do
        output = Tempfile.new('test_predicates')
        result = exporter.export_to(output)

        content = output.read
        expect(content).to be_empty
      end
    end

    context 'with collection object predicates' do
      let!(:predicate) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate) }
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

      specify 'exports data rows' do
        output = Tempfile.new('test_predicates')
        result = exporter.export_to(output)

        content = output.read
        lines = content.lines

        # Should have header + 2 data rows
        expect(lines.count).to eq 3
      end

      specify 'exports expected header' do
        output = Tempfile.new('test_predicates')
        result = exporter.export_to(output)

        content = output.read
        lines = content.lines

        expect(lines.first.chomp)
          .to eq("TW:DataAttribute:CollectionObject:#{predicate.name}")
      end

      specify 'exports expected predicate values' do
        output = Tempfile.new('test_predicates')
        result = exporter.export_to(output)

        content = output.read
        lines = content.lines

        # Data rows should have values
        expect(content).to include('test value 1')
        expect(content).to include('test value 2')
      end

      specify 'only includes predicates with data' do
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

      specify 'concatenates multiple values for same predicate with DwC delimiter' do
        # Create a specimen with multiple values for the same predicate
        multi_specimen = FactoryBot.create(:valid_specimen, project: project)
        multi_specimen.get_dwc_occurrence

        multi_predicate = FactoryBot.create(:valid_controlled_vocabulary_term_predicate, project: project)

        # Create multiple data attributes with same predicate
        FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: multi_specimen,
          predicate: multi_predicate,
          value: 'first value'
        )
        FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: multi_specimen,
          predicate: multi_predicate,
          value: 'second value'
        )

        multi_core_scope = DwcOccurrence.where(dwc_occurrence_object_id: multi_specimen.id, dwc_occurrence_object_type: 'CollectionObject')

        exporter = described_class.new(
          core_scope: multi_core_scope,
          collection_object_predicate_ids: [multi_predicate.id],
          collecting_event_predicate_ids: []
        )

        output = Tempfile.new('test_predicates')
        result = exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Should have header + 1 data row
        expect(lines.count).to eq(2)

        # Data row should have both values concatenated with DwC delimiter
        delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER
        data_row = lines[1].strip
        expect(data_row).to eq("first value#{delimiter}second value")

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

      specify 'exports collecting event predicate data' do
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

    context 'with complex filtering scenarios' do
      let!(:p1) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate, project: project) }
      let!(:p2) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate, project: project) }
      let!(:p3) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate, project: project) }

      specify 'includes only referenced collecting events' do
        # All three specimens share same CE
        s1 = FactoryBot.create(:valid_specimen, project: project)
        s2 = FactoryBot.create(:valid_specimen, project: project)
        s3 = FactoryBot.create(:valid_specimen, project: project)

        ce = FactoryBot.create(:valid_collecting_event)
        s1.update!(collecting_event: ce)
        s2.update!(collecting_event: ce)
        s3.update!(collecting_event: ce)

        s1.get_dwc_occurrence
        s2.get_dwc_occurrence
        s3.get_dwc_occurrence

        # The collecting event has a data attribute
        d1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce,
          predicate: p1,
          value: 'shared ce value'
        )

        # The scope is only two specimens
        scope = DwcOccurrence.where(dwc_occurrence_object: [s1, s2])

        exporter = described_class.new(
          core_scope: scope,
          collection_object_predicate_ids: [],
          collecting_event_predicate_ids: [p1.id]
        )

        output = Tempfile.new('test_predicates')
        exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Should have header + 2 data rows (s1 and s2)
        expect(lines.count).to eq(3)
        expect(lines[0]).to include(p1.name)
        expect(lines[1].strip).to eq('shared ce value')
        expect(lines[2].strip).to eq('shared ce value')

        output.close
        output.unlink
      end

      specify 'filters collecting event attributes to only referenced CEs and predicates' do
        s1 = FactoryBot.create(:valid_specimen, project: project)
        s2 = FactoryBot.create(:valid_specimen, project: project)
        s3 = FactoryBot.create(:valid_specimen, project: project)
        s4 = FactoryBot.create(:valid_specimen, project: project)
        s5 = FactoryBot.create(:valid_specimen, project: project)

        ce1 = FactoryBot.create(:valid_collecting_event)
        ce2 = FactoryBot.create(:valid_collecting_event)
        ce3 = FactoryBot.create(:valid_collecting_event)

        s1.update!(collecting_event: ce1)
        s2.update!(collecting_event: ce1) # not in scope
        s3.update!(collecting_event: ce2) # not in scope
        s4.update!(collecting_event: ce3) # not in scope
        s5.update!(collecting_event: ce3)

        s1.get_dwc_occurrence
        s2.get_dwc_occurrence
        s3.get_dwc_occurrence
        s4.get_dwc_occurrence
        s5.get_dwc_occurrence

        d1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce1,
          predicate: p1,
          value: 'ce1_p1'
        )
        d2 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce3,
          predicate: p1,
          value: 'ce3_p1'
        )
        d3 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce2,
          predicate: p2,
          value: 'ce2_p2'
        ) # not in scope - wrong CE
        d4 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce3,
          predicate: p2,
          value: 'ce3_p2'
        )
        d5 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce3,
          predicate: p3,
          value: 'ce3_p3'
        ) # not in scope - wrong predicate
        d6 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce1,
          predicate: p3,
          value: 'ce1_p3'
        ) # not in scope - wrong predicate

        # The scope is only s1 and s5 (ce1, ce3) with predicates p1, p2
        scope = DwcOccurrence.where(dwc_occurrence_object: [s1, s5])

        exporter = described_class.new(
          core_scope: scope,
          collection_object_predicate_ids: [],
          collecting_event_predicate_ids: [p1.id, p2.id]
        )

        output = Tempfile.new('test_predicates')
        exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines.map(&:strip)

        # Should have header + 2 data rows
        expect(lines.count).to eq(3)

        # Parse TSV
        rows = CSV.parse(content, col_sep: "\t", headers: true)

        # Should have both predicates as columns
        expect(rows.headers).to include("TW:DataAttribute:CollectingEvent:#{p1.name}")
        expect(rows.headers).to include("TW:DataAttribute:CollectingEvent:#{p2.name}")

        # Check values
        row_values = rows.map { |r| [r["TW:DataAttribute:CollectingEvent:#{p1.name}"], r["TW:DataAttribute:CollectingEvent:#{p2.name}"]] }
        expect(row_values).to contain_exactly(['ce1_p1', nil], ['ce3_p1', 'ce3_p2'])

        output.close
        output.unlink
      end

      specify 'does not inject collection_object_ids not in original scope' do
        # All three share CE
        s1 = FactoryBot.create(:valid_specimen, project: project)
        s2 = FactoryBot.create(:valid_specimen, project: project)
        s3 = FactoryBot.create(:valid_specimen, project: project)

        ce = FactoryBot.create(:valid_collecting_event)
        s1.update!(collecting_event: ce)
        s2.update!(collecting_event: ce)
        s3.update!(collecting_event: ce)

        s1.get_dwc_occurrence
        s2.get_dwc_occurrence
        s3.get_dwc_occurrence

        # The collecting event has a data attribute
        d1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce,
          predicate: p1,
          value: 'shared value'
        )

        # The scope is only two specimens (s1, s2) - s3 should NOT appear
        scope = DwcOccurrence.where(dwc_occurrence_object: [s1, s2])

        exporter = described_class.new(
          core_scope: scope,
          collection_object_predicate_ids: [],
          collecting_event_predicate_ids: [p1.id]
        )

        output = Tempfile.new('test_predicates')
        exporter.export_to(output)
        output.rewind

        content = output.read
        lines = content.lines

        # Should have header + 2 data rows (NOT 3)
        expect(lines.count).to eq(3)

        # Both rows should have the shared value
        expect(lines[1].strip).to eq('shared value')
        expect(lines[2].strip).to eq('shared value')

        output.close
        output.unlink
      end

      specify 'exports collection object attributes correctly' do
        s1 = FactoryBot.create(:valid_specimen, project: project)
        s2 = FactoryBot.create(:valid_specimen, project: project)
        s3 = FactoryBot.create(:valid_specimen, project: project)

        s1.get_dwc_occurrence
        s2.get_dwc_occurrence
        s3.get_dwc_occurrence

        d1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: s1,
          predicate: p1,
          value: 's1_p1'
        )
        d2 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: s3,
          predicate: p3,
          value: 's3_p3'
        )
        d3 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: s2,
          predicate: p2,
          value: 's2_p2'
        )

        scope = DwcOccurrence.where(dwc_occurrence_object: [s1, s2, s3])

        exporter = described_class.new(
          core_scope: scope,
          collection_object_predicate_ids: [p1.id, p2.id, p3.id],
          collecting_event_predicate_ids: []
        )

        output = Tempfile.new('test_predicates')
        exporter.export_to(output)
        output.rewind

        content = output.read

        # Parse TSV
        rows = CSV.parse(content, col_sep: "\t", headers: true)

        # Should have all predicates as columns
        expect(rows.headers).to include("TW:DataAttribute:CollectionObject:#{p1.name}")
        expect(rows.headers).to include("TW:DataAttribute:CollectionObject:#{p2.name}")
        expect(rows.headers).to include("TW:DataAttribute:CollectionObject:#{p3.name}")

        # Check that specific values are present
        expect(content).to include('s1_p1')
        expect(content).to include('s3_p3')
        expect(content).to include('s2_p2')

        output.close
        output.unlink
      end

      specify 'exports collecting event attributes correctly' do
        s1 = FactoryBot.create(:valid_specimen, project: project)

        ce = FactoryBot.create(:valid_collecting_event)
        s1.update!(collecting_event: ce)
        s1.get_dwc_occurrence

        d1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce,
          predicate: p1,
          value: 'ce_p1'
        )
        d2 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce,
          predicate: p3,
          value: 'ce_p3'
        )

        scope = DwcOccurrence.where(dwc_occurrence_object: s1)

        exporter = described_class.new(
          core_scope: scope,
          collection_object_predicate_ids: [],
          collecting_event_predicate_ids: [p1.id, p2.id, p3.id]
        )

        output = Tempfile.new('test_predicates')
        exporter.export_to(output)
        output.rewind

        content = output.read

        # Parse TSV
        rows = CSV.parse(content, col_sep: "\t", headers: true)

        # Should include p1 and p3 (p2 has no data so won't be included)
        expect(rows.headers).to include("TW:DataAttribute:CollectingEvent:#{p1.name}")
        expect(rows.headers).to include("TW:DataAttribute:CollectingEvent:#{p3.name}")
        expect(rows.headers).not_to include("TW:DataAttribute:CollectingEvent:#{p2.name}")

        # Check values
        expect(content).to include('ce_p1')
        expect(content).to include('ce_p3')

        output.close
        output.unlink
      end

      specify 'avoids n-times-m join-spread when specimen has multiple CO and CE data attributes' do
        s1 = FactoryBot.create(:valid_specimen, no_dwc_occurrence: false)
        ce = FactoryBot.create(:valid_collecting_event)
        s1.update!(collecting_event: ce)

        co_da1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: s1,
          predicate: p1,
          value: 'co_value_1'
        )
        co_da2 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: s1,
          predicate: p2,
          value: 'co_value_2'
        )

        ce_da1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce,
          predicate: p1,
          value: 'ce_value_1'
        )
        ce_da2 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce,
          predicate: p2,
          value: 'ce_value_2'
        )

        scope = DwcOccurrence.where(dwc_occurrence_object: s1)

        exporter = described_class.new(
          core_scope: scope,
          collection_object_predicate_ids: [p1.id, p2.id],
          collecting_event_predicate_ids: [p1.id, p2.id]
        )

        output = Tempfile.new('test_predicates')
        exporter.export_to(output)
        output.rewind

        content = output.read
        rows = CSV.parse(content, col_sep: "\t", headers: true)

        # Should have exactly 1 data row (not duplicated)
        expect(rows.count).to eq(1)

        row = rows.first

        # Each value should appear exactly once (not repeated due to nxm join)
        expect(row["TW:DataAttribute:CollectionObject:#{p1.name}"]).to eq('co_value_1')
        expect(row["TW:DataAttribute:CollectionObject:#{p2.name}"]).to eq('co_value_2')

        expect(row["TW:DataAttribute:CollectingEvent:#{p1.name}"]).to eq('ce_value_1')
        expect(row["TW:DataAttribute:CollectingEvent:#{p2.name}"]).to eq('ce_value_2')

        output.close
        output.unlink
      end

      specify 'concatenates multiple values for same predicate with DwC delimiter' do
        # When a CO or CE has multiple data attributes with the same predicate,
        # all values should be concatenated with the DwC delimiter (pipe).
        # This preserves all data rather than arbitrarily picking one value.
        s1 = FactoryBot.create(:valid_specimen, project: project)
        ce = FactoryBot.create(:valid_collecting_event)
        s1.update!(collecting_event: ce)
        s1.get_dwc_occurrence

        # Create multiple CO data attributes with the SAME predicate
        co_da1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: s1,
          predicate: p1,
          value: 'first_co_value'
        )
        co_da2 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: s1,
          predicate: p1,
          value: 'second_co_value'
        )

        # Create multiple CE data attributes with the SAME predicate
        ce_da1 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce,
          predicate: p2,
          value: 'first_ce_value'
        )
        ce_da2 = FactoryBot.create(:valid_data_attribute_internal_attribute,
          attribute_subject: ce,
          predicate: p2,
          value: 'second_ce_value'
        )

        scope = DwcOccurrence.where(dwc_occurrence_object: s1)

        exporter = described_class.new(
          core_scope: scope,
          collection_object_predicate_ids: [p1.id],
          collecting_event_predicate_ids: [p2.id]
        )

        output = Tempfile.new('test_predicates')
        exporter.export_to(output)
        output.rewind

        content = output.read
        rows = CSV.parse(content, col_sep: "\t", headers: true)

        expect(rows.count).to eq(1)
        row = rows.first

        # CO predicate should have both values concatenated with pipe
        co_value = row["TW:DataAttribute:CollectionObject:#{p1.name}"]
        expect(co_value).to include('first_co_value')
        expect(co_value).to include('second_co_value')
        expect(co_value).to include(' | ')

        # CE predicate should have both values concatenated with pipe
        ce_value = row["TW:DataAttribute:CollectingEvent:#{p2.name}"]
        expect(ce_value).to include('first_ce_value')
        expect(ce_value).to include('second_ce_value')
        expect(ce_value).to include(' | ')

        output.close
        output.unlink
      end
    end
  end
end
