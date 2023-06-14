require 'rails_helper'

RSpec.describe CachedMapItem, type: :model do

  let(:cached_map_item) { CachedMap.new }

  specify 'Factory test' do
    expect(FactoryBot.create(:valid_cached_map_item)).to be_truthy
  end

end
