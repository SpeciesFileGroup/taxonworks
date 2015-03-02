require 'rails_helper'

describe SerialChronology, :type => :model do

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
