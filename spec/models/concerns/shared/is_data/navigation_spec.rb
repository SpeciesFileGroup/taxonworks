require 'rails_helper'

describe 'IsData::Navigation', type: :model do

  before do
    (0..5).each do |i|
      TestIsDataNavigation.create!(id: i)
    end
  end

  specify '#base_navigation_next' do
    o = TestIsDataNavigation.first
    expect(o.base_navigation_next.all.map(&:id)).to eq([1])
  end

  specify '#base_navigation_previous' do
    o = TestIsDataNavigation.second
    expect(o.base_navigation_previous.all.map(&:id)).to eq([0])
  end

end

class TestIsDataNavigation < ApplicationRecord
  include FakeTable
  include Shared::IsData::Navigation
end

