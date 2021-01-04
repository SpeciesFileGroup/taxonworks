require 'rails_helper'

describe Georeference::Wkt, type: :model, group: :geo do

  # https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry
  let(:ce) { FactoryBot.create(:valid_collecting_event) }
  let(:point) { 'POINT(0 0)' }
  let(:line_string) { 'LINESTRING (30 10, 10 30, 40 40)'}
  let(:polygon) { 'POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10), (20 30, 35 35, 30 20, 20 30)) '}
  let(:geometry_collection) { 'GEOMETRYCOLLECTION (POINT (40 10), LINESTRING (10 10, 20 20, 10 40), POLYGON ((40 40, 20 45, 45 30, 40 40)))'}

  specify '#wkt, point' do
    expect( Georeference::Wkt.new(wkt: point, collecting_event: ce).valid?).to be_truthy
  end

  specify '#wkt, line_string' do
    expect( Georeference::Wkt.new(wkt: line_string, collecting_event: ce).valid?).to be_truthy
  end

  specify '#wkt, polygon' do
    expect( Georeference::Wkt.new(wkt: polygon, collecting_event: ce).valid?).to be_truthy
  end

  specify '#wkt, point 1' do
    expect( Georeference::Wkt.create(wkt: point, collecting_event: ce)).to be_truthy
  end

  specify '#wkt, line_string 1' do
    expect( Georeference::Wkt.create(wkt: line_string, collecting_event: ce)).to be_truthy
  end

  specify '#wkt, polygon' do
    expect( Georeference::Wkt.create(wkt: polygon, collecting_event: ce)).to be_truthy
  end


 end
