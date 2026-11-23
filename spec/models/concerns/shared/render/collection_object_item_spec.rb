require 'rails_helper'

describe Shared::Render::CollectionObjectItem, type: :model do
  let(:klass) {
    Class.new(LayoutItem) do
      include Shared::Render::ImageItem
      include Shared::Render::CollectionObjectItem
    end
  }

  specify 'permits CollectionObject' do
    expect(klass.composition_item_object_permitted?(CollectionObject)).to be_truthy
  end

  specify 'permits CollectionObject subclasses' do
    expect(klass.composition_item_object_permitted?(CollectionObject::BiologicalCollectionObject)).to be_truthy
  end

  specify 'falls back to super (other concerns still permit)' do
    expect(klass.composition_item_object_permitted?(Image)).to be_truthy
  end

  specify 'does not permit others' do
    expect(klass.composition_item_object_permitted?(Otu)).to be_falsey
  end
end
