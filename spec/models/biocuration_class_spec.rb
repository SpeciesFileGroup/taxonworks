require 'rails_helper'

describe BiocurationClass, type: :model do

  let(:biocuration_class) {BiocurationClass.new}

  specify 'dwc_occurrences' do
    b = FactoryBot.create(:valid_biocuration_class)
    g = FactoryBot.create(:valid_biocuration_group, uri: 'http://rs.tdwg.org/dwc/terms/sex')

    Tag.create!(tag_object: b, keyword: g)

    s = Specimen.create!
    expect(s.dwc_occurrence.sex).to eq(nil)

    c = FactoryBot.create(
      :valid_biocuration_classification,
      biocuration_classification_object: s,
      biocuration_class: b)

    expect(s.dwc_occurrence.reload.sex).to eq(b.name)

    b.update!(name: 'foo')

    expect(s.dwc_occurrence.reload.sex).to eq('foo')
  end

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biocuration_class.biocuration_classifications << FactoryBot.build(:valid_biocuration_classification)).to be_truthy
      end

      specify 'collection_objects' do
        expect(biocuration_class.collection_objects << FactoryBot.build(:valid_specimen)).to be_truthy
      end

      specify 'field_occurrences' do
        expect(biocuration_class.field_occurrences << FactoryBot.build(:valid_field_occurrence)).to be_truthy
      end

      specify 'tags' do
        expect(biocuration_class.tags << FactoryBot.build(:valid_tag)).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'taggable'
  end

end
