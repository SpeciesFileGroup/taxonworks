require 'rails_helper'

describe AssertedDistribution, type: :model, group: [:geo, :shared_geo] do
  let(:asserted_distribution) { AssertedDistribution.new }
  let(:source) { FactoryBot.create(:valid_source) }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:geographic_area) { FactoryBot.create(:valid_geographic_area) }
  let(:gazetteer) { FactoryBot.create(:valid_gazetteer) }

  specify '#unique 1' do
    a = FactoryBot.create(:valid_asserted_distribution)
    b = FactoryBot.build(:valid_asserted_distribution, asserted_distribution_shape: a.asserted_distribution_shape, asserted_distribution_object: a.asserted_distribution_object)
    expect(b.valid?).to be_falsey
  end

  specify '#unique 2' do
    a = FactoryBot.create(:valid_asserted_distribution)
    b = FactoryBot.build(:valid_asserted_distribution, asserted_distribution_shape_id: a.asserted_distribution_shape_id, asserted_distribution_shape_type: a.asserted_distribution_shape_type, asserted_distribution_object_id: a.asserted_distribution_object_id, asserted_distribution_object_type: a.asserted_distribution_object_type)
    expect(b.valid?).to be_falsey
  end

  specify '#unique on object_id *and* object_type' do
    bag = FactoryBot.create(:valid_biological_associations_graph)

    a = FactoryBot.create(:valid_biological_association_asserted_distribution)
    expect(a.asserted_distribution_object_id).to eq(bag.id)

    # Same as a except for object type.
    b = FactoryBot.build(:valid_asserted_distribution, asserted_distribution_shape_id: a.asserted_distribution_shape_id, asserted_distribution_shape_type: a.asserted_distribution_shape_type, asserted_distribution_object_id: a.asserted_distribution_object_id,
    is_absent: a.is_absent,
    asserted_distribution_object_type: 'BiologicalAssociationsGraph')
    expect(b.valid?).to be_truthy
  end

  specify '#unique is_absent nil/false' do
    a = FactoryBot.create(:valid_asserted_distribution, is_absent: false)
    b = FactoryBot.build(:valid_asserted_distribution, asserted_distribution_shape: a.asserted_distribution_shape, asserted_distribution_object: a.asserted_distribution_object, is_absent: nil)
    expect(b.valid?).to be_falsey
  end

  specify '#destroy' do
    a = FactoryBot.create(:valid_geographic_area_asserted_distribution)
    expect(a.destroy).to be_truthy
  end

  specify '#destroy 2' do
    a = FactoryBot.create(:valid_gazetteer_asserted_distribution)
    expect(a.destroy).to be_truthy
  end

  specify '#destroy 3' do
    a = FactoryBot.create(:valid_observation_asserted_distribution)
    expect(a.destroy).to be_truthy
  end

  context 'associations' do
    context 'belongs_to' do
      context 'object' do
        DISTRIBUTION_ASSERTABLE_TYPES.each do |t|
          specify "polymorphic for #{t} object" do
            expect(
              asserted_distribution.asserted_distribution_object =
                t.constantize.new
            ).to be_truthy
          end
        end

        specify 'there are types not accepted as object' do
          expect{
            asserted_distribution.asserted_distribution_object =
              CollectionObject.new
          }.to raise_error(ActiveRecord::InverseOfAssociationNotFoundError)
        end

        specify 'conveyance on otu is accepted as object' do
          expect(
            FactoryBot.create(:valid_asserted_distribution,
              asserted_distribution_object: FactoryBot.create(:valid_conveyance,
                conveyance_object: FactoryBot.create(:valid_otu)))
          ).to be_truthy
        end

        specify 'not everything is acccepted as conveyance object type' do
          expect{
            FactoryBot.create(:valid_asserted_distribution,
              asserted_distribution_object: FactoryBot.create(:valid_conveyance,
                conveyance_object: FactoryBot.create(:valid_collection_object)))
          }.to raise_error(ActiveRecord::RecordInvalid)
        end

        specify 'conveyance on depiction is accepted as object' do
          expect(
            FactoryBot.create(:valid_asserted_distribution,
              asserted_distribution_object: FactoryBot.create(:valid_depiction,
                depiction_object: FactoryBot.create(:valid_otu)))
          ).to be_truthy
        end

        specify 'not everything is acccepted as depiction object type' do
          expect{
            FactoryBot.create(:valid_asserted_distribution,
              asserted_distribution_object: FactoryBot.create(:valid_depiction,
                depiction_object: FactoryBot.create(:valid_collection_object)))
          }.to raise_error(ActiveRecord::RecordInvalid)
        end

        specify 'observation on otu is accepted as object' do
          expect(
            FactoryBot.create(:valid_asserted_distribution,
              asserted_distribution_object: FactoryBot.create(:valid_observation,
                observation_object: FactoryBot.create(:valid_otu)))
          ).to be_truthy
        end

        specify 'not everything is acccepted as observation object type' do
          expect{
            FactoryBot.create(:valid_asserted_distribution,
              asserted_distribution_object: FactoryBot.create(:valid_observation,
                observation_object: FactoryBot.create(:valid_collection_object)))
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      specify 'polymorphic for geographic_area shape' do
        expect(asserted_distribution.asserted_distribution_shape = GeographicArea.new).to be_truthy
      end

      specify 'polymorphic for gazetteer shape' do
        expect(asserted_distribution.asserted_distribution_shape = Gazetteer.new).to be_truthy
      end
    end
  end

  context 'validation' do
    context 'required base attributes' do
      before { asserted_distribution.valid? }

      specify 'an object is required' do
        expect(asserted_distribution.errors.include?(:asserted_distribution_object)).to be_truthy
      end

      specify 'a shape is required' do
        expect(asserted_distribution.errors.include?(:asserted_distribution_shape)).to be_truthy
      end
    end

    context 'a citation is required' do
      before do
        asserted_distribution.asserted_distribution_shape = geographic_area
        asserted_distribution.asserted_distribution_object = otu
      end

      specify 'citations count works after save through source' do
        asserted_distribution.source = source
        asserted_distribution.save!

        # If we load/iterate the citations association during AD validation
        # after assignment through source, the association is empty because the
        # citation the source determines hasn't been created yet, and then
        # citations stays empty until we reload/reset the association. Check
        # that we're doing that.
        expect(asserted_distribution.citations.first.source.id).to eq(source.id)
      end

      specify 'absence of #source, #origin_citation, #citations invalidates' do
        expect(asserted_distribution.valid?).to be_falsey
        expect(asserted_distribution.errors.include?(:base)).to be_truthy
      end

      specify 'providing #source validates' do
        asserted_distribution.source = source
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'providing #origin_citation validates' do
        asserted_distribution.origin_citation = Citation.new(source:)
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'providing a citation with #citations_attributes validates' do
        asserted_distribution.citations_attributes = [{source:}]
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'providing a citation with #origin_citation_attributes validates' do
        asserted_distribution.origin_citation_attributes = {source:}
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'providing a citation with #citations.build validates' do
        asserted_distribution.citations.build(source:)
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'providing a citation with #citations <<  validates' do
        asserted_distribution.citations << Citation.new(source:)
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'all attributes with #new validates' do
        a = AssertedDistribution.new(
          asserted_distribution_object_id: otu.id,
          asserted_distribution_object_type: 'Otu',
          asserted_distribution_shape_id: geographic_area.id,
          asserted_distribution_shape_type: 'GeographicArea',
          citations_attributes: [{source_id: source.id}])
        expect(a.save).to be_truthy
        expect(a.citations.count).to eq(1)
      end

      context 'attempting to delete last citation' do
        specify 'permitted when deleting self 1' do
          asserted_distribution.origin_citation = Citation.new(source:)
          asserted_distribution.save!
          expect(asserted_distribution.destroy).to be_truthy
          expect(AssertedDistribution.count).to be(0)
        end

        specify 'permitted when deleting self 2' do
          asserted_distribution.citations << Citation.new(source:)
          asserted_distribution.save!
          expect(asserted_distribution.destroy).to be_truthy
          expect(AssertedDistribution.count).to be(0)
        end

        specify 'when citation is origin_citation' do
          asserted_distribution.source = source
          asserted_distribution.save!
          expect(asserted_distribution.citations.count).to eq(1)
          expect(asserted_distribution.citations.reload.first.destroy).to be_falsey
        end

        specify 'when citation is not origin citation' do
          asserted_distribution.citations << Citation.new(source:)
          expect(asserted_distribution.save).to be_truthy
          expect(asserted_distribution.citations.count).to eq(1)
          expect(asserted_distribution.citations.reload.first.destroy).to be_falsey
        end

        context 'with _delete / marked_for_destruction' do
          specify 'origin citation via a nested attribute delete is NOT allowed' do
            asserted_distribution.origin_citation = Citation.new(source:, is_original: true)
            asserted_distribution.save!
            expect(asserted_distribution.origin_citation).to be_truthy
            expect{asserted_distribution.update!(origin_citation_attributes: {
              _destroy: true, id: asserted_distribution.origin_citation.id
            })}.to raise_error(ArgumentError)
          end

          specify 'not-origin-citation via a nested attribute delete' do
            asserted_distribution.citations << Citation.new(source:)
            asserted_distribution.save!
            expect(asserted_distribution.citations.count).to eq(1)
            expect{asserted_distribution.update!(citations_attributes: {
              _destroy: true, id: asserted_distribution.citations.first.id
            })}.to raise_error(ActiveRecord::RecordNotDestroyed)
          end

          specify 'trying to save citation with marked_for_destruction citation' do
            asserted_distribution.citations << Citation.new(source:)
            asserted_distribution.mark_citations_for_destruction

            expect{asserted_distribution.save!}
              .to raise_error(ActiveRecord::RecordInvalid)
          end

          specify 'trying to save origin citation with marked_for_destruction citation' do
            asserted_distribution.origin_citation = Citation.new(source:)
            asserted_distribution.origin_citation.mark_for_destruction

            expect{asserted_distribution.save!}
              .to raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end
    end

    specify 'duplicate record' do
      ad1 = FactoryBot.create(:valid_asserted_distribution)
      ad2 = FactoryBot.build_stubbed(
        :valid_asserted_distribution,
        asserted_distribution_object: ad1.asserted_distribution_object,
        asserted_distribution_shape: ad1.asserted_distribution_shape)
      expect(ad1.valid?).to be_truthy
      expect(ad2.valid?).to be_falsey
      expect(ad2.errors.include?(:asserted_distribution_object)).to be_truthy
    end

    context 'is_absent' do
      before do
        asserted_distribution.update!(
          asserted_distribution_object: otu,
          asserted_distribution_shape: gazetteer,
          citations_attributes: [{source_id: source.id}]
        )
      end

      specify 'is allowed with identical' do
        expect( AssertedDistribution.create!(asserted_distribution_object: otu, asserted_distribution_shape: gazetteer, is_absent: true, citations_attributes: [{source_id: source.id}])).to be_truthy
      end
    end
  end

  context 'soft validation' do
    # Can't miss source, it's required by definition
    specify 'is_absent - False' do
      ga  = FactoryBot.create(:level2_geographic_area)
      _ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_shape: ga.parent, is_absent: true)
      ad2 = FactoryBot.build_stubbed(:valid_asserted_distribution, asserted_distribution_object: _ad1.asserted_distribution_object, asserted_distribution_shape: ga)
      ad2.soft_validate(only_methods: :sv_conflicting_geographic_area)
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end

    specify 'is_absent - True' do
      ga  = FactoryBot.create(:level2_geographic_area)
      _ad1 = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_shape: ga)
      ad2 = FactoryBot.build_stubbed(:valid_asserted_distribution, asserted_distribution_object: _ad1.asserted_distribution_object, asserted_distribution_shape: ga, is_absent: true)
      ad2.soft_validate(only_methods: [:sv_conflicting_geographic_area])
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end
  end

  context '#stub_new' do
    include_context 'stuff for complex geo tests'

    before { [ce_a, gr_a].each }
    let(:otu) { FactoryBot.create(:valid_otu) }

    specify 'stubs some number of new AssertedDistibutionsADs' do
      point = ce_a.georeferences.first.geographic_item.geo_object
      areas = GeographicArea.find_by_lat_long(point.y, point.x)
      stubs = AssertedDistribution.stub_new(
        {otu: otu.id,
         source: source.id,
         geographic_areas: areas}).map(&:asserted_distribution_shape)
      expect(stubs.map(&:name)).to include('A', 'E')
    end
  end

  context 'concerns' do
    it_behaves_like 'notable'
    it_behaves_like 'citations'
  end

  context '::batch_template_create' do
    let!(:template_asserted_distribution) {{
      asserted_distribution_shape_id: geographic_area.id,
      asserted_distribution_shape_type: 'GeographicArea',
      citations_attributes: [{ source_id: source.id }]
    }}

    let(:otu2) { FactoryBot.create(:valid_otu) }

    specify 'preview creates none' do
      r = AssertedDistribution.batch_template_create(
        preview: true,
        async_cutoff: 10,
        object_query: { otu_id: [otu.id] },
        object_type: 'Otu',
        template_asserted_distribution:
      )

      expect(AssertedDistribution.count).to eq(0)
      expect(r.preview).to be_truthy
    end

    specify 'non-async create creates' do
      r = AssertedDistribution.batch_template_create(
        preview: false,
        async_cutoff: 10,
        object_query: { otu_id: [otu.id, otu2.id] },
        object_type: 'Otu',
        template_asserted_distribution:
      )

      expect(AssertedDistribution.all.map(&:asserted_distribution_object_id))
        .to contain_exactly(otu.id, otu2.id)
      expect(AssertedDistribution.all.map(&:asserted_distribution_shape_id))
        .to contain_exactly(geographic_area.id, geographic_area.id)
    end

    specify 'non-async create returns correct counts' do
      AssertedDistribution.create!(
        template_asserted_distribution.merge(asserted_distribution_object: otu)
      )

      r = AssertedDistribution.batch_template_create(
        preview: false,
        async_cutoff: 10,
        object_query: { otu_id: [otu.id, otu2.id] },
        object_type: 'Otu',
        template_asserted_distribution:
      )

      expect(r.total_attempted).to eq(2)
      expect(r.updated.count).to eq(1)
      expect(r.not_updated.count).to eq(1)
    end

    specify 'async create creates in the background' do
      # Cause the async delayed job to run immediately here.
      allow_any_instance_of(ActiveSupport::Duration).to receive(:from_now).and_return(Time.now)
      r = AssertedDistribution.batch_template_create(
        preview: false,
        async_cutoff: 1,
        object_query: { otu_id: [otu.id, otu2.id] },
        object_type: 'Otu',
        template_asserted_distribution:,
        user_id: Current.user_id,
        project_id: Current.project_id
      )
      expect(AssertedDistribution.count).to eq(0)

      Delayed::Worker.new.work_off

      expect(AssertedDistribution.all.map(&:asserted_distribution_object_id))
        .to contain_exactly(otu.id, otu2.id)
      expect(AssertedDistribution.all.map(&:asserted_distribution_shape_id))
        .to contain_exactly(geographic_area.id, geographic_area.id)
    end

    specify 'adds citation to existing AD instead of creating new' do
      source2 = FactoryBot.create(:valid_source, title: 'Where the pigeons poop')
      # Dup of the AD to be batch-created below, execept for citation.
      ad = AssertedDistribution.create!(
        asserted_distribution_object: otu,
        asserted_distribution_shape: geographic_area,
        citations_attributes: [{ source_id: source2.id }]
      )

      r = AssertedDistribution.batch_template_create(
        preview: false,
        async_cutoff: 10,
        object_query: { otu_id: [otu.id] },
        object_type: 'Otu',
        template_asserted_distribution:
      )

      expect(AssertedDistribution.all.map(&:asserted_distribution_object_id))
        .to contain_exactly(otu.id)

      expect(AssertedDistribution.first.citations.count).to eq(2)
    end
  end

  context '::batch_update' do
    let!(:ga1) { FactoryBot.create(:valid_geographic_area, name: 'pre') }
    let!(:ga2) { FactoryBot.create(:valid_geographic_area, name: 'post') }
    let!(:ad1) { FactoryBot.create(:valid_asserted_distribution,
      asserted_distribution_object: otu,
      asserted_distribution_shape: ga1)
    }
    let!(:ad2) { FactoryBot.create(:valid_asserted_distribution,
      asserted_distribution_object: FactoryBot.create(:valid_biological_association),
      asserted_distribution_shape: ga1)
    }
    let!(:params) {{
	    asserted_distribution: {
		    asserted_distribution_shape_id: ga2.id,
		    asserted_distribution_shape_type: 'GeographicArea'
	    },
      asserted_distribution_query: {
		    asserted_distribution_id: [ad1.id, ad2.id]
	    }
    }}

    specify 'moves' do
      AssertedDistribution.batch_update(params)
      expect(ad1.reload.asserted_distribution_shape_id).to eq(ga2.id)
      expect(ad2.reload.asserted_distribution_shape_id).to eq(ga2.id)
    end

    specify 'async moves' do
      # Cause the async delayed job to run immediately here.
      allow_any_instance_of(ActiveSupport::Duration).to receive(:from_now).and_return(Time.now)

      AssertedDistribution.batch_update(params.merge({ async_cutoff: 1 }))

      expect(ad1.reload.asserted_distribution_shape_id).to eq(ga1.id)

      Delayed::Worker.new.work_off

      expect(ad1.reload.asserted_distribution_shape_id).to eq(ga2.id)
      expect(ad2.reload.asserted_distribution_shape_id).to eq(ga2.id)
    end

    specify 'sets counts' do
      r = AssertedDistribution.batch_update(params)
      expect(r.total_attempted).to eq(2)
      expect(r.updated.count).to eq(2)
      expect(r.not_updated.count).to eq(0)
    end
  end

end
