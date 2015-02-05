require 'rails_helper'

RSpec.describe GeographicItem::Point, :type => :model do

  let(:point) {GeographicItem::Point.new}

    # e.g. not 400,400
    specify 'a point, when provided, has a legal geography' do
      point.point = 'POINT(200.0 200.0)'
      point.valid?
      expect(point.errors.keys.include?(:point_limit)).to be_truthy
    end

end
