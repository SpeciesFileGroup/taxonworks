require 'rails_helper'

describe TaxonNameClassification, type: :model, group: [:nomenclature] do
  include ActiveJob::TestHelper

  let(:taxon_name_classification) { TaxonNameClassification.new }

  after(:all) {
    TaxonNameRelationship.delete_all
    TaxonName.delete_all
    TaxonNameClassification.delete_all
  }

  context 'meta/configuration' do
    specify 'missing and duplicate NOMEN_URI' do
      nomen_uris = []
      TaxonNameClassification.descendants.each do |klass|
        uri = klass.nomen_uri
        expect(uri.empty?).to be_falsey, "NOMEN_URI for #{klass.name} is empty!"
        expect(nomen_uris.include?(uri)).to be(false), "#{uri} from #{klass.name} is duplicated!"
        expect(uri).to match(/^http:\/\/purl\.obolibrary\.org\/obo\/NOMEN\/?/), "#{uri} from #{klass.name} is invalid!"
        nomen_uris.push uri
      end
    end

    specify 'single-value/side-effect overrides stay confined to Latinized' do
      # Gender and PartOfSpeech are the only classifications with hard
      # single-value-per-name uniqueness (validate_uniqueness_of_latinized)
      # and cached-name cascade side effects (set_cached /
      # set_cached_names_for_taxon_names) - which is why they're excluded
      # from the generic status picker in StatusSlice.vue's merge(). If a
      # future classification outside Latinized needs the same, that
      # exclusion needs to be revisited too.
      guarded_methods = %i[validate_uniqueness_of_latinized set_cached set_cached_names_for_taxon_names]

      TaxonNameClassification.descendants.each do |klass|
        next if klass.name.start_with?('TaxonNameClassification::Latinized')

        overridden = guarded_methods.select { |m|
          klass.instance_methods(false).include?(m) || klass.private_instance_methods(false).include?(m)
        }

        expect(overridden).to be_empty, "#{klass.name} overrides #{overridden.join(', ')} outside Latinized - decide whether it needs the same generic-status-picker exclusion Gender/PartOfSpeech get in StatusSlice.vue's merge()"
      end
    end
  end

  context 'validation' do
    context 'requires' do
      before { taxon_name_classification.valid? }

      specify 'taxon_name' do
        expect(taxon_name_classification.errors.include?(:taxon_name)).to be_truthy
      end

      specify 'type' do
        expect(taxon_name_classification.errors.include?(:type)).to be_truthy
      end

      specify 'disjoint_taxon_name_relationships' do
        TAXON_NAME_CLASSIFICATION_CLASSES.each do |r|
          r1 = r.disjoint_taxon_name_classes.collect{|i| i.to_s}
          r1 = ['a'] + r1
          r1 = r1.collect {|i| i.class.to_s}.uniq
          expect(r1.first).to eq('String')
          expect(r1.size).to eq(1)
        end
      end

      specify 'applicable_ranks' do
        TAXON_NAME_CLASSIFICATION_CLASSES.each do |r|
          r1 = r.applicable_ranks.collect{|i| i.to_s}
          r1 = ['a'] + r1
          r1 = r1.collect {|i| i.class.to_s}.uniq
          expect(r1.first).to eq('String')
          expect(r1.size).to eq(1)
        end
      end
    end


    context 'validate nomenclature code' do
      before do
        root = FactoryBot.create(:root_taxon_name)
      end

      let(:g) { Protonym.create!(parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus)) }

      specify 'missmatched code returns error' do
        taxon_name_classification.taxon_name = g
        taxon_name_classification.type_class = 'TaxonNameClassification::Icn::Fossil'
        expect(taxon_name_classification.valid?).to be_falsey
        msg = 'Taxon name <i>Aus</i> belongs to the iczn nomenclatural code, but the status is from the icn nomenclatural code'
        expect(taxon_name_classification.errors.full_messages.include?(msg)).to be_truthy
      end
    end

    context 'validate type' do
      specify 'an invalid type' do
        expect { FactoryBot.build(:taxon_name_classification, type: 'aaa') }.to raise_error ActiveRecord::SubclassNotFound
      end

      specify 'another invalid type' do
        c = FactoryBot.build(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
        c.valid?
        expect(c.errors.include?(:type)).to be_falsey
      end

      specify 'not specific relationship' do
        c = FactoryBot.build(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
        c.soft_validate(only_sets: :not_specific_classes)
        expect(c.soft_validations.messages_on(:type).size).to eq(1)
      end

      specify 'specific relationship' do
        c = FactoryBot.build(:taxon_name_classification, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NoDescription')
        c.soft_validate(only_sets: :not_specific_classes)
        expect(c.soft_validations.messages_on(:type).size).to eq(0)
      end

    end
  end

  specify '#type_class can set type' do
    taxon_name_classification.type_class = TaxonNameClassification::Latinized::Gender::Feminine
    expect(taxon_name_classification.type).to eq('TaxonNameClassification::Latinized::Gender::Feminine')
  end

  specify '#type_class returns a klass' do
    a = TaxonNameClassification::Latinized::Gender::Feminine
    taxon_name_classification.type_class = a
    expect(taxon_name_classification.type_class).to eq(a)
    expect(taxon_name_classification.type_class).to eq('TaxonNameClassification::Latinized::Gender::Feminine'.constantize)
  end

  context 'with type set' do
    before { taxon_name_classification.type_class = TaxonNameClassification::Iczn::Unavailable }

    specify '#type_name returns a String' do
      expect(taxon_name_classification.type_name).to be_a(String)
    end

    specify '#nomenclature_code' do
      expect(taxon_name_classification.nomenclature_code).to eq(:iczn)
    end
  end

  context '#nomenclature_code' do
    specify ':iczn' do
      taxon_name_classification.type_class = TaxonNameClassification::Iczn::Unavailable
      expect(taxon_name_classification.nomenclature_code).to eq(:iczn)
    end

    specify ':icn' do
      taxon_name_classification.type_class = TaxonNameClassification::Icn::Fossil
      expect(taxon_name_classification.nomenclature_code).to eq(:icn)
    end

   specify 'none (nil)' do
      taxon_name_classification.type_class = TaxonNameClassification::Latinized::Gender::Feminine
      expect(taxon_name_classification.nomenclature_code).to eq(nil)
    end
  end

  context '#valid status' do
    specify 'and synonym relationship' do
      species = FactoryBot.create(:relationship_species)
      genus = species.ancestor_at_rank('genus')
      genus1 = FactoryBot.create(:relationship_genus, name: 'Aus')
      species1 = FactoryBot.create(:relationship_species, name: 'aaa', parent: genus1)
      c = Combination.new
      c.genus = genus1
      c.species = species
      c.save
      expect(c.cached_valid_taxon_name_id).to eq (species.id)
      TaxonNameRelationship.create(subject_taxon_name: species, object_taxon_name: species1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
      c.reload
      expect(c.cached_valid_taxon_name_id).to eq (species1.id)
      TaxonNameClassification.create(taxon_name: species, type: 'TaxonNameClassification::Iczn::Available::Valid')
      c.reload
      expect(c.cached_valid_taxon_name_id).to eq (species.id)
    end
  end

 context 'soft_validation' do
    before(:each) do
      TaxonName.delete_all
      TaxonNameClassification.delete_all
      @species = FactoryBot.create(:relationship_species)
      @genus = @species.ancestor_at_rank('genus')
      @family = @species.ancestor_at_rank('family')
    end

    specify 'applicable type and year' do
     c = FactoryBot.build_stubbed(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
     c.soft_validate(only_sets: :proper_classification)
     expect(c.soft_validations.messages_on(:type).empty?).to be_truthy
   end
    specify 'unapplicable type' do
      c = FactoryBot.build_stubbed(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::NotFromGenusName')
      c.soft_validate(only_sets: :proper_classification)
      expect(c.soft_validations.messages_on(:type).size).to eq(1)
    end
    specify 'unapplicable year' do
      c = FactoryBot.build_stubbed(:taxon_name_classification, taxon_name: @species, type: 'TaxonNameClassification::Iczn::Unavailable::ElectronicPublicationNotInPdfFormat')
      c.soft_validate(only_sets: :proper_classification)
      expect(c.soft_validations.messages_on(:type).size).to eq(1)
    end
    specify 'disjoint classes' do
      g = FactoryBot.create(:iczn_genus, parent: @family)
      s = FactoryBot.create(:iczn_species, parent: g)
      _r1 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: s, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      c1 = FactoryBot.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Unavailable')
      c2 = FactoryBot.create(:taxon_name_classification, taxon_name: s, type: 'TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology')
      c1.soft_validate(only_sets: :validate_disjoint_classes)
      c2.soft_validate(only_sets: :validate_disjoint_classes)
      #conflicting with c2
      expect(c1.soft_validations.messages_on(:type).size).to eq(1)
      #conflicting with c1
      expect(c2.soft_validations.messages_on(:type).size).to eq(1)
    end
    specify 'not specific classes: nomen nudum' do
      c1 = FactoryBot.build_stubbed(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
      c1.soft_validate(only_sets: :not_specific_classes)
      expect(c1.soft_validations.messages_on(:type).size).to eq(1)
    end
    specify 'not specific classes: homonym' do
      c1 = FactoryBot.build_stubbed(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Iczn::Available::Invalid::Homonym')
      c1.soft_validate(only_sets: :not_specific_classes)
      expect(c1.soft_validations.messages_on(:type).size).to eq(1)
    end
    specify 'not specific classes: CitationOfUnavailableName' do
      c1 = FactoryBot.build_stubbed(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum::CitationOfUnavailableName')
      c1.soft_validate(only_sets: :not_specific_classes)
      expect(c1.soft_validations.messages_on(:type).size).to eq(0)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

  context '.batch_by_filter_scope' do
    let(:iczn_name) { FactoryBot.create(:valid_protonym) }
    let(:icn_name) { FactoryBot.create(:icn_genus) }

    context ':set and :remove_gender' do
      let(:genus) { FactoryBot.create(:iczn_genus) }
      let(:masculine) { 'TaxonNameClassification::Latinized::Gender::Masculine' }
      let(:feminine)  { 'TaxonNameClassification::Latinized::Gender::Feminine' }

      specify ':set records non-genus taxon names in not_updated' do
        species = Protonym.create!(name: 'aus', parent: genus, rank_class: Ranks.lookup(:iczn, :species))
        q = Queries::TaxonName::Filter.new(taxon_name_id: species.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :set,
          params: { type: masculine }
        )
        expect(r[:not_updated]).to include(species.id)
        expect(TaxonNameClassification.where(taxon_name: species).count).to eq(0)
        expect(r[:validation_errors].keys).to include(a_string_matching(/Gender is only applicable to genus names/))
      end

      specify ':set creates a gender classification when none exists' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: genus.id)
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :set,
          params: { type: masculine }
        )
        expect(
          TaxonNameClassification.where(taxon_name: genus, type: masculine).count
        ).to eq(1)
      end

      specify ':set updates an existing gender classification to the new type' do
        TaxonNameClassification.create!(taxon_name: genus, type: masculine)
        q = Queries::TaxonName::Filter.new(taxon_name_id: genus.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :set,
          params: { type: feminine }
        )
        expect(r[:updated].length).to eq(1)
        expect(r[:not_updated]).to be_empty
        expect(TaxonNameClassification.where(taxon_name: genus, type: feminine).count).to eq(1)
        expect(TaxonNameClassification.where(taxon_name: genus, type: masculine).count).to eq(0)
      end

      specify ':set skips the update (and its cached-name cascade) when the classification already has the requested gender' do
        existing = TaxonNameClassification.create!(taxon_name: genus, type: masculine)
        original_updated_at = existing.reload.updated_at
        q = Queries::TaxonName::Filter.new(taxon_name_id: genus.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :set,
          params: { type: masculine }
        )
        expect(r[:updated]).to eq([existing.id])
        expect(existing.reload.updated_at).to eq(original_updated_at)
      end

      specify ':set is a no-op and returns not_updated when type is invalid' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: genus.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :set,
          params: { type: 'TaxonNameClassification::Iczn::Fossil' }
        )
        expect(TaxonNameClassification.where(taxon_name: genus).count).to eq(0)
        expect(r[:updated]).to be_empty
      end

      specify ':remove_gender deletes an existing gender classification' do
        TaxonNameClassification.create!(taxon_name: genus, type: masculine)
        q = Queries::TaxonName::Filter.new(taxon_name_id: genus.id)
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :remove_gender,
          params: {}
        )
        expect(TaxonNameClassification.where(taxon_name: genus, type: masculine).count).to eq(0)
      end

      specify ':remove_gender is a no-op when no gender classification exists' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: genus.id)
        expect {
          TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :remove_gender,
            params: {}
          )
        }.not_to change(TaxonNameClassification, :count)
      end

      specify ':remove_gender accounts for every taxon name in the filter, without miscounting a no-op as updated' do
        TaxonNameClassification.create!(taxon_name: genus, type: masculine)
        other_genus = FactoryBot.create(:iczn_genus)
        q = Queries::TaxonName::Filter.new(taxon_name_id: [genus.id, other_genus.id])
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :remove_gender,
          params: {}
        )
        expect(r[:total_attempted]).to eq(2)
        expect(r[:updated].length).to eq(1)
        expect(r[:not_updated]).to include(other_genus.id)
        expect(r[:validation_errors]).to be_empty
      end

      specify ':set async dispatches a job and creates the gender classification after processing' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: genus.id)
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :set,
          params: { type: masculine },
          project_id: Project.first.id,
          user_id: User.first.id,
          async_cutoff: 0
        )
        expect(TaxonNameClassification.where(taxon_name: genus, type: masculine).count).to eq(0)
        perform_enqueued_jobs
        expect(TaxonNameClassification.where(taxon_name: genus, type: masculine).count).to eq(1)
      end
    end

    context ':add_status and :remove_status' do
      let(:invalid_type) { 'TaxonNameClassification::Iczn::Available::Invalid' }
      let(:nomen_dubium) { 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium' }
      let(:fossil_type) { 'TaxonNameClassification::Iczn::Fossil' }
      let(:ichnotaxon_type) { 'TaxonNameClassification::Iczn::Fossil::Ichnotaxon' }

      specify ':add_status does not create a conflicting classification when a disjoint classification already exists' do
        existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: ichnotaxon_type)
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :add_status,
          params: { type: fossil_type }
        )
        expect(r[:not_updated]).to include(iczn_name.id)
        expect(r[:validation_errors]).to include('conflicts with an existing disjoint classification' => 1)
        expect(TaxonNameClassification.where(taxon_name: iczn_name, type: fossil_type).count).to eq(0)
        expect(TaxonNameClassification.where(taxon_name: iczn_name, type: ichnotaxon_type).count).to eq(1)
        expect(existing.reload).to be_persisted
      end

      specify ':remove_status leaves more specific forms of the status untouched' do
        TaxonNameClassification.create!(taxon_name: iczn_name, type: ichnotaxon_type)
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :remove_status,
          params: { type: fossil_type }
        )
        expect(r[:not_updated]).to include(iczn_name.id)
        expect(TaxonNameClassification.where(taxon_name: iczn_name, type: ichnotaxon_type).count).to eq(1)
      end

      specify ':remove_status leaves disjoint but unrelated classifications of the same taxon name untouched' do
        nomen_nudum = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum'
        available = 'TaxonNameClassification::Iczn::Available'
        TaxonNameClassification.create!(taxon_name: iczn_name, type: nomen_nudum)
        TaxonNameClassification.create!(taxon_name: iczn_name, type: available)
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :remove_status,
          params: { type: nomen_nudum }
        )
        expect(TaxonNameClassification.where(taxon_name: iczn_name, type: nomen_nudum).count).to eq(0)
        expect(TaxonNameClassification.where(taxon_name: iczn_name, type: available).count).to eq(1)
      end

      specify ':remove_status of an ICZN status leaves the corresponding status of another code untouched' do
        icn_fossil = 'TaxonNameClassification::Icn::Fossil'
        TaxonNameClassification.create!(taxon_name: iczn_name, type: fossil_type)
        TaxonNameClassification.create!(taxon_name: icn_name, type: icn_fossil)
        q = Queries::TaxonName::Filter.new(taxon_name_id: [iczn_name.id, icn_name.id])
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :remove_status,
          params: { type: fossil_type }
        )
        expect(TaxonNameClassification.where(taxon_name: iczn_name, type: fossil_type).count).to eq(0)
        expect(TaxonNameClassification.where(taxon_name: icn_name, type: icn_fossil).count).to eq(1)
      end

      specify ':add_status creates a classification of the given type' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :add_status,
          params: { type: invalid_type }
        )
        expect(
          TaxonNameClassification.where(taxon_name: iczn_name, type: invalid_type).count
        ).to eq(1)
      end

      specify ':add_status is idempotent (and reported as updated) when the classification already exists' do
        existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :add_status,
          params: { type: invalid_type }
        )
        expect(r[:updated]).to eq([existing.id])
        expect(
          TaxonNameClassification.where(taxon_name: iczn_name, type: invalid_type).count
        ).to eq(1)
      end

      specify ':add_status records a taxon name in not_updated when the nomenclature code does not match' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: icn_name.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :add_status,
          params: { type: invalid_type } # ICZN-only type used against an ICN name
        )
        expect(r[:not_updated]).to include(icn_name.id)
        expect(r[:validation_errors].keys).to include(a_string_matching(/nomenclatural code/))
        expect(TaxonNameClassification.where(taxon_name: icn_name).count).to eq(0)
      end

      specify ':add_status is a no-op when type is not a known classification' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :add_status,
          params: { type: 'NotARealClassification' }
        )
        expect(TaxonNameClassification.where(taxon_name: iczn_name).count).to eq(0)
        expect(r[:updated]).to be_empty
      end

      specify ':remove_status deletes an existing classification of the given type' do
        TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :remove_status,
          params: { type: invalid_type }
        )
        expect(
          TaxonNameClassification.where(taxon_name: iczn_name, type: invalid_type).count
        ).to eq(0)
      end

      specify ':remove_status leaves other classification types on the same taxon name untouched' do
        TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
        TaxonNameClassification.create!(taxon_name: iczn_name, type: nomen_dubium)
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :remove_status,
          params: { type: invalid_type }
        )
        expect(
          TaxonNameClassification.where(taxon_name: iczn_name, type: invalid_type).count
        ).to eq(0)
        expect(
          TaxonNameClassification.where(taxon_name: iczn_name, type: nomen_dubium).count
        ).to eq(1)
      end

      specify ':remove_status is a no-op when no classification of that type exists' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        expect {
          TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :remove_status,
            params: { type: invalid_type }
          )
        }.not_to change(TaxonNameClassification, :count)
      end

      specify ':remove_status accounts for every taxon name in the filter, without miscounting a no-op as updated' do
        TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
        other_name = FactoryBot.create(:valid_protonym)
        q = Queries::TaxonName::Filter.new(taxon_name_id: [iczn_name.id, other_name.id])
        r = TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :remove_status,
          params: { type: invalid_type }
        )
        expect(r[:total_attempted]).to eq(2)
        expect(r[:updated].length).to eq(1)
        expect(r[:not_updated]).to include(other_name.id)
        expect(r[:validation_errors]).to be_empty
      end

      specify ':add_status async dispatches a job and creates the classification after processing' do
        q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
        TaxonNameClassification.batch_by_filter_scope(
          filter_query: { 'taxon_name_query' => q.params },
          mode: :add_status,
          params: { type: invalid_type },
          project_id: Project.first.id,
          user_id: User.first.id,
          async_cutoff: 0
        )
        expect(
          TaxonNameClassification.where(taxon_name: iczn_name, type: invalid_type).count
        ).to eq(0)
        perform_enqueued_jobs
        expect(
          TaxonNameClassification.where(taxon_name: iczn_name, type: invalid_type).count
        ).to eq(1)
      end

      context ':add_status with a citation' do
        let(:source) { FactoryBot.create(:valid_source) }

        specify 'attaches the citation to a newly created status' do
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '12' } }
          )
          classification = TaxonNameClassification.find_by(taxon_name: iczn_name, type: invalid_type)
          expect(classification.citations.count).to eq(1)
          expect(classification.citations.first.source_id).to eq(source.id)
          expect(classification.citations.first.pages).to eq('12')
        end

        specify 'attaches the citation to a status that already existed' do
          existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          r = TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '12' } }
          )
          expect(r[:updated]).to eq([existing.id])
          expect(existing.citations.reload.count).to eq(1)
          expect(existing.citations.first.source_id).to eq(source.id)
        end

        specify 'tolerates a citation with the same source and pages already existing on the status' do
          existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
          existing.citations.create!(source_id: source.id, pages: '12')
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          r = TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '12' } }
          )
          expect(r[:updated]).to eq([existing.id])
          expect(existing.citations.reload.count).to eq(1)
          expect(r[:validation_errors]).to be_empty
        end

        specify 'tolerates a citation with the same source and no pages already existing on the status when blank pages are requested' do
          existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
          existing.citations.create!(source_id: source.id)
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          r = TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '' } }
          )
          expect(r[:updated]).to eq([existing.id])
          expect(existing.citations.reload.count).to eq(1)
          expect(r[:validation_errors]).to be_empty
        end

        specify 'reports not_updated, rather than silently no-op, when only is_original differs from an existing citation with the same source and pages' do
          existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
          existing.citations.create!(source_id: source.id, pages: '12')
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          r = TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '12', is_original: true } }
          )
          expect(r[:updated]).to be_empty
          expect(r[:not_updated]).to include(iczn_name.id)
          expect(existing.citations.reload.count).to eq(1)
          expect(existing.citations.first.is_original).to be_falsey
          expect(r[:validation_errors].keys).to include(a_string_matching(/different 'original' flag for taxon name id #{iczn_name.id}\b/))
        end

        specify 'reports not_updated, rather than silently no-op, when requesting is_original: false against an existing original citation with the same source and pages' do
          existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
          existing.citations.create!(source_id: source.id, pages: '12', is_original: true)
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          r = TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '12', is_original: false } }
          )
          expect(r[:updated]).to be_empty
          expect(r[:not_updated]).to include(iczn_name.id)
          expect(existing.citations.reload.count).to eq(1)
          expect(existing.citations.first.is_original).to be true
          expect(r[:validation_errors].keys).to include(a_string_matching(/different 'original' flag for taxon name id #{iczn_name.id}\b/))
        end

        specify 'reports not_updated (and why) when the citation fails for a reason other than the tolerated duplicate, leaving the classification in place' do
          existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
          other_source = FactoryBot.create(:valid_source)
          existing.citations.create!(source_id: other_source.id, pages: '1', is_original: true)

          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          r = TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '12', is_original: true } }
          )

          expect(r[:updated]).to be_empty
          expect(r[:not_updated]).to include(iczn_name.id)
          expect(TaxonNameClassification.where(taxon_name: iczn_name, type: invalid_type).count).to eq(1)
          expect(existing.citations.reload.count).to eq(1)
          expect(r[:validation_errors].keys).to include(a_string_matching(/can only be assigned once per object/))
        end

        specify 'a citation with different pages is added alongside an existing citation' do
          existing = TaxonNameClassification.create!(taxon_name: iczn_name, type: invalid_type)
          existing.citations.create!(source_id: source.id, pages: '12')
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '34' } }
          )
          expect(existing.citations.reload.count).to eq(2)
        end

        specify 'is skipped when no source_id is provided' do
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { pages: '12' } }
          )
          classification = TaxonNameClassification.find_by(taxon_name: iczn_name, type: invalid_type)
          expect(classification.citations.count).to eq(0)
        end

        specify 'async attaches the citation after the job processes' do
          q = Queries::TaxonName::Filter.new(taxon_name_id: iczn_name.id)
          TaxonNameClassification.batch_by_filter_scope(
            filter_query: { 'taxon_name_query' => q.params },
            mode: :add_status,
            params: { type: invalid_type, citation: { source_id: source.id, pages: '12' } },
            project_id: Project.first.id,
            user_id: User.first.id,
            async_cutoff: 0
          )
          perform_enqueued_jobs
          classification = TaxonNameClassification.find_by(taxon_name: iczn_name, type: invalid_type)
          expect(classification.citations.count).to eq(1)
          expect(classification.citations.first.source_id).to eq(source.id)
        end
      end
    end
  end

end
