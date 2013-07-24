require 'spec_helper'



describe GeoRef do

  let(:geo_ref) { GeoRef.new }

  context "validation" do
    context "requires" do
      before do
        # this code does *not* execute.  Why not?
        geo_ref.a_point
        geo_ref.save
      end
    end

    specify "At least one point or one line or one polygon or one multi_polygon is provided" do
      expect(geo_ref.errors.include?(:cashed_display)).to be_true
    end
  end
end
