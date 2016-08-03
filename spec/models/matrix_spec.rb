require 'rails_helper'

RSpec.describe Matrix, type: :model do


  let(:matrix) {Matrix.new}

  context :validation do
    before {matrix.valid?}
    specify 'name is required' do
      expect(matrix.errors.include?(:name)).to be_truthy
    end

  end

end
