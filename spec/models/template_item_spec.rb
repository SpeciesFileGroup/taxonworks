require 'rails_helper'

RSpec.describe TemplateItem, type: :model do
  let(:template_item) { FactoryBot.build(:valid_template_item) }

  specify 'valid_template_item is valid' do
    expect(template_item.valid?).to be_truthy
  end

  specify 'composition is required' do
    template_item.composition = nil
    template_item.valid?
    expect(template_item.errors.include?(:composition)).to be_truthy
  end

  specify 'composition must be a Template' do
    template_item.composition = FactoryBot.create(:valid_layout)
    template_item.valid?
    expect(template_item.errors.include?(:composition)).to be_truthy
  end
end
