require 'rails_helper'
require 'lib/soft_validation_helpers'

describe 'SoftValidationMethod', group: :soft_validation do
  let(:klass) { 'Hamburger' }
  let(:name) { 'Check for cheeze' }
  let(:method) { :with_cheeze }
  let(:description) { 'Checks to ensure the hamburger has cheeze.'}
  let(:set) { :topings }
  let(:resolution) { [:add_cheeze, :add_the_works] }

  let(:soft_validation_method) { SoftValidation::SoftValidationMethod.new(
    {
      klass: klass,
      method: method,
      name: name,
      description: description,
      set: :topings,
      resolution: resolution 
    }) 
  }

  specify '#klass is required' do
    expect{SoftValidation::SoftValidationMethod.new(method: :bar)}.to raise_error SoftValidation::SoftValidationError
  end 

  specify '#method is required' do
    expect{SoftValidation::SoftValidationMethod.new(klass: 'String')}.to raise_error SoftValidation::SoftValidationError
  end 

  specify '#resolution must be an array or nil' do
    expect{SoftValidation::SoftValidationMethod.new(klass: 'String', method: :bar, resolution: 'String')}.to raise_error SoftValidation::SoftValidationError
  end

  context 'attributes' do
    specify '#method' do
      expect(soft_validation_method.method).to eq(method)
    end

    specify '#name' do
      expect(soft_validation_method.name).to eq(name)
    end

    specify '#description' do
      expect(soft_validation_method.description).to eq(description)
    end

    specify '#resolution' do
      expect(soft_validation_method.resolution).to eq(resolution)
    end

    specify '#klass' do
      expect(soft_validation_method.klass).to eq(klass) 
    end

    specify '#set' do
      expect(soft_validation_method.set).to eq(set)
    end
  end

  context 'instance methods' do
    context 'without description' do 
      before {
        soft_validation_method.name = nil
        soft_validation_method.description = nil
      }
      specify '#described?' do
        expect(soft_validation_method.described?).to be_falsey
      end

      specify '#to_s' do
        expect(soft_validation_method.to_s).to eq('with_cheeze (temporary name): (no description provided)')
      end
    end

    context 'with description' do
      specify '#described?' do
        expect(soft_validation_method.described?).to be_truthy
      end

      specify '#to_s' do
        expect(soft_validation_method.to_s).to eq("#{name}: #{description}")
      end
    end
  end

end

