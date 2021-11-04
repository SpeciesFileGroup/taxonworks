require 'rails_helper'

describe BiocurationGroup, type: :model do

  let(:biocuration_group) {FactoryBot.build(:biocuration_group)}

  context 'has many' do
    before(:each) {
      @biocuration_group = FactoryBot.create(:valid_biocuration_group, name: 'Stages.', definition: 'Life stages of an individual.')
      @bc1 = BiocurationClass.create(name: 'Adult', definition: 'A mature indivdiual.')
      @bc2 = BiocurationClass.create(name: 'Larva', definition: 'Not a mature indivdiual.')
    }

    specify 'tags (through Keywords)' do
      expect(biocuration_group.tags << Tag.new(keyword: FactoryBot.build(:valid_keyword))).to be_truthy
    end

    specify 'biocuration_classes' do
      expect(biocuration_group).to respond_to(:biocuration_classes)
      t1 = Tag.create(keyword: @biocuration_group, tag_object: @bc1)
      t2 = Tag.create(keyword: @biocuration_group, tag_object: @bc2)

      expect(@biocuration_group.biocuration_classes.count).to eq(2)
      expect(@biocuration_group.biocuration_classes.to_a.map(&:class)).to eq([BiocurationClass, BiocurationClass])
    end
  end
end

