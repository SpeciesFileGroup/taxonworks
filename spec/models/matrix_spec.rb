require 'rails_helper'

RSpec.describe Matrix, type: :model do

<<<<<<< 78e56ca3c2632af3840134e92a40c450e3f7cb5d
  let(:matrix) {Matrix.new}

  context 'associations' do 
    context 'has_many' do
      specify '#matrix_column_items' do
        expect(matrix.matrix_column_items << MatrixColumnItem.new).to be_truthy
      end
    end

  end
=======

  let(:matrix) {Matrix.new}
>>>>>>> Scaffolded matrix model, basics integrated in TW interface. Tests updated.

  context :validation do
    before {matrix.valid?}
    specify 'name is required' do
      expect(matrix.errors.include?(:name)).to be_truthy
    end
<<<<<<< 78e56ca3c2632af3840134e92a40c450e3f7cb5d
=======

>>>>>>> Scaffolded matrix model, basics integrated in TW interface. Tests updated.
  end

end
