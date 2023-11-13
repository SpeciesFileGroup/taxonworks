require 'rails_helper'

describe 'Shared::PolymorphicAnnotator', type: :model do
  let(:class_with_polymorphic_annotator) {TestPolymorphicAnnotator}
  let(:class_with_polymorphic_annotator_instance) {TestPolymorphicAnnotator.new}


  specify '.annotator_reflection' do
    expect(TestPolymorphicAnnotator.annotator_reflection).to eq('sti')
  end

  specify '.annotator_id' do
    expect(TestPolymorphicAnnotator.annotator_id).to eq('sti_id')
  end 

  specify '.annotator_type' do
    expect(TestPolymorphicAnnotator.annotator_type).to eq('sti_type')
  end 

  context 'related foreign_keys' do
    before do
      TestPolymorphicAnnotator.related_foreign_keys.push :foo_id
    end

    specify '.related_foreign_keys' do
      expect(TestPolymorphicAnnotator.related_foreign_keys).to contain_exactly(:foo_id)
    end
  end

  context '#annotated_global_entity' do
    let(:o) {FactoryBot.create(:valid_otu)}
    let(:global_id) { o.to_global_id }

    before do
      class_with_polymorphic_annotator_instance.annotated_global_entity = global_id.to_s
    end

    specify '#annotated_global_entity' do
      expect( class_with_polymorphic_annotator_instance.annotated_global_entity).to eq(global_id)
    end

    context 'after save' do
      before do 
        class_with_polymorphic_annotator_instance.save!
        class_with_polymorphic_annotator_instance.reload
      end

      specify '#..._type' do
        expect(class_with_polymorphic_annotator_instance.sti_type).to eq('Otu')
      end

      specify '#..._id' do
        expect(class_with_polymorphic_annotator_instance.sti_id).to eq(o.id)
      end
    end
  end
end

class Otu
  has_many :test_polymorphic_annotators
end

class TestPolymorphicAnnotator < ApplicationRecord
  include FakeTable
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:sti)
end

