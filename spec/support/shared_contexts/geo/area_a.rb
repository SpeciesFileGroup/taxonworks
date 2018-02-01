shared_context 'stuff for area_a' do
  let(:list_shape_a) {
    RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(0, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 10, 0.0),
                                   RSPEC_GEO_FACTORY.point(10, 0, 0.0),
                                   RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
  }
  let(:shape_a) { RSPEC_GEO_FACTORY.polygon(list_shape_a) }
  let(:item_a) { FactoryBot.create(:geographic_item, multi_polygon: RSPEC_GEO_FACTORY.multi_polygon([shape_a])) }
  let(:area_a) {
    area = FactoryBot.create(:level1_geographic_area,
                             name:                 'A',
                             geographic_area_type: gat_parish,
                             iso_3166_a3:          nil,
                             iso_3166_a2:          nil,
                             parent:               area_e)
    area.geographic_items << item_a
    area.save!
    area
  }
end
