require 'rails_helper'

describe Loan, :type => :model do
  skip "add some examples to (or delete) #{__FILE__}"

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
