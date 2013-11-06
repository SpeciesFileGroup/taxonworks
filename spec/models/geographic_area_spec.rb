require 'spec_helper'

describe GeographicArea do

  before :all do
    # read_shape('..\shapes\USA_adm\USA_adm1.shp')
    # read_csv('..\shapes\USA_adm\USA_adm1.csv')
  end
  context 'Shape files' do
    specify 'that a shapefile can be read.' do
      expect(true).to eq true
    end

  end
end

def read_shape(filename)

  RGeo::Shapefile::Reader.open(filename) { |file|
    puts "File contains #{file.num_records} items."
    file.each { |item|
      #puts " Geometry: #{record.geometry.as_text}"
      #puts " Attributes: #{record.attributes.inspect}"
      record                               = GeographicArea.new(parent_id: item[:ID_0], name: item[:NAME_1], state_id: item[:ID_1], country_id: item[:ID_0])
      record.geographic_item               = GeographicItem.new
      record.geographic_item.multi_polygon = item.geometry
      record.save
      count = record.geographic_item.multi_polygon.num_geometries
      ess = (count == 1) ? '' : 's'
      puts "#{item.index}:  #{record.name} (#{record.parent_id}:#{record.state_id} => #{count} polygon#{ess}.)"
    }
  }

end

def read_csv(file)

  # data = CSV.open(file)

  data = CSV.read(file, options = {headers: true})

  data.each { |row|
    stuff = {}
    stuff = row
    puts stuff

    # record = GeographicArea.new
    record = GeographicArea.new(parent_id: row[1], name: row[5], state_id: row[4], country_id: row[1])
    record.save
  }

  def read_csv(file)

    # data = CSV.open(file)

    data = CSV.read(file, options = {headers: true})

    data.each { |row|
      stuff = {}
      stuff = row
      puts stuff

      # record = GeographicArea.new
      record = GeographicArea.new(parent_id: row[1], name: row[5], state_id: row[4], country_id: row[1])
      record.save
    }
  end
end
