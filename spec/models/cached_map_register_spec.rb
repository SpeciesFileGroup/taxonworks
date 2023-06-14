require 'rails_helper'

RSpec.describe CachedMapRegister, type: :model do

  specify 'Factory test' do
    expect(FactoryBot.create(:valid_cached_map_register)).to be_truthy
  end

end
