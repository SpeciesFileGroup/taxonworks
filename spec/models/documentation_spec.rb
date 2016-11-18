require 'rails_helper'

RSpec.describe Documentation, type: :model, group: :documentation do

  let(:documentation) { Documentation.new }

  context 'validation' do
    before { documentation.valid? } 

    specify 'requires #document' do
      expect(documentation.errors.include?(:document)).to be_truthy
    end
  end

end
