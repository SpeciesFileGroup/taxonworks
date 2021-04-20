require 'rails_helper'

describe AssertedDistribution, type: :model, group: [:geo, :shared_geo] do

  let(:asserted_distribution) { AssertedDistribution.new }
  let(:source) { FactoryBot.create(:valid_source) }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:geographic_area) { FactoryBot.create(:valid_geographic_area) }

  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(asserted_distribution.otu = Otu.new).to be_truthy
      end

      specify 'geographic_area' do
        expect(asserted_distribution.geographic_area = GeographicArea.new).to be_truthy
      end
    end
  end

  context 'validation' do
    context 'required base attributes' do
      before { asserted_distribution.valid? }

      specify '#otu is required' do
        expect(asserted_distribution.errors.include?(:otu)).to be_truthy
      end

      specify '#geographic_area is required' do
        expect(asserted_distribution.errors.include?(:geographic_area)).to be_truthy
      end
    end

    context 'a citation is required' do
      before {
        asserted_distribution.geographic_area = geographic_area
        asserted_distribution.otu = otu
      }

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
        asserted_distribution.origin_citation = Citation.new(source: source)
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'providing a citation with #citations_attributes validates' do
        asserted_distribution.citations_attributes = [{source: source}]
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'providing a citation with #citations.build validates' do
        asserted_distribution.citations.build(source: source)
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'providing a citation with #citations <<  validates' do
        asserted_distribution.citations << Citation.new(source: source)
        expect(asserted_distribution.save).to be_truthy
        expect(asserted_distribution.citations.count).to eq(1)
      end

      specify 'all attributes with #new validates' do
        a = AssertedDistribution.new(
          otu: otu,
          geographic_area: geographic_area,
          citations_attributes: [{source_id: source.id}])
        expect(a.save).to be_truthy
        expect(a.citations.count).to eq(1)
      end

      context 'attempting to delete last citation' do
        specify 'when citation is origin_ciation' do
          asserted_distribution.source = source
          asserted_distribution.save!
          expect(asserted_distribution.citations.count).to eq(1)
          expect(asserted_distribution.citations.reload.first.destroy).to be_falsey
        end

        specify 'when citation is not origin citation' do
          asserted_distribution.citations << Citation.new(source: source)
          expect(asserted_distribution.save).to be_truthy
          expect(asserted_distribution.citations.count).to eq(1)
          expect(asserted_distribution.citations.reload.first.destroy).to be_falsey
        end
      end
    end

    specify 'duplicate record' do
      ad1 = FactoryBot.create(:valid_asserted_distribution)
      ad2 = FactoryBot.build_stubbed(
        :valid_asserted_distribution,
        otu_id: ad1.otu_id,
        geographic_area_id: ad1.geographic_area_id)
      expect(ad1.valid?).to be_truthy
      expect(ad2.valid?).to be_falsey
      expect(ad2.errors.include?(:geographic_area_id)).to be_truthy
    end

    context 'is_absent' do
      before do
        asserted_distribution.update!(
          otu: otu,
          geographic_area: geographic_area,
          citations_attributes: [{source_id: source.id}]
        )
      end

      specify 'is allowed with identical' do
        expect( AssertedDistribution.create!(otu: otu, geographic_area: geographic_area, is_absent: true, citations_attributes: [{source_id: source.id}])).to be_truthy
      end
    end

  end

  context 'soft validation' do
    # Can't miss source, it's required by definition
    specify 'is_absent - False' do
      ga  = FactoryBot.create(:level2_geographic_area)
      _ad1 = FactoryBot.create(:valid_asserted_distribution, geographic_area: ga.parent, is_absent: true)
      ad2 = FactoryBot.build_stubbed(:valid_asserted_distribution, otu_id: _ad1.otu_id, geographic_area: ga)
      ad2.soft_validate(only_methods: :sv_conflicting_geographic_area)
      expect(ad2.soft_validations.messages_on(:geographic_area_id).count).to eq(1)
    end

    specify 'is_absent - True' do
      ga  = FactoryBot.create(:level2_geographic_area)
      _ad1 = FactoryBot.create(:valid_asserted_distribution, geographic_area: ga)
      ad2 = FactoryBot.build_stubbed(:valid_asserted_distribution, otu_id: _ad1.otu_id, geographic_area: ga, is_absent: true)
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
         geographic_areas: areas}).map(&:geographic_area)
      expect(stubs.map(&:name)).to include('A', 'E')
    end
  end

  context 'concerns' do
    it_behaves_like 'notable'
    it_behaves_like 'citations'
  end

end
