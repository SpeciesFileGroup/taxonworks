require 'spec_helper'

GenTable = true
DoShape  = true
BaseDir  = '../shapes/USA_adm/'

describe GeographicArea do

  before :all do
    if GenTable
      build_gat_table
      if DoShape
        Dir.glob(BaseDir + '*.shp').each { |filename|
          read_shape(filename)
        }
      else
        Dir.glob(BaseDir + '*.csv').each { |filename|
          read_csv(filename)
        }
      end
    end
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

    record    = GeographicArea.new
    area_type = GeographicAreaType.new

    file.each { |item|
      case filename
        when /0/
          record    = GeorgaphicArea.new(parent_id:  0,
                                         name:       item[:NAME_ENGLISH],
                                         country_id: item[:PID])
          area_type = GeographicAreaType.where(name: 'Country')[0]
          if area_type.nil?
            at = GeographicAreaType.new(name: 'Country')
            at.save
            area_type = at
          end
        when /1/
          record    = GeographicArea.new(parent_id:  item[:ID_0],
                                         name:       item[:NAME_1],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0])
          area_type = GeographicAreaType.where(name: item[:TYPE_1])
          if area_type.nil?
            at = GeographicAreaType.new(name: item[:TYPE_1])
            at.save
            area_type = at
          end
        when /2/
          record    = GeographicArea.new(parent_id:  item[:ID_1],
                                         name:       item[:NAME_2],
                                         state_id:   item[:ID_1],
                                         country_id: item[:ID_0],
                                         county_id:  item[:ID_2])
          area_type = GeographicAreaType.where(name: item[:TYPE_2])
          if area_type.nil?
            at = GeographicAreaType.new(name: item[:TYPE_2])
            at.save
            area_type = at
          end
        else

      end
      record.geographic_area_type          = area_type
      record.geographic_item               = GeographicItem.new
      record.geographic_item.multi_polygon = item.geometry
      record.save
      count = record.geographic_item.multi_polygon.num_geometries
      ess   = (count == 1) ? '' : 's'
      puts "#{item.index + 1}:  #{record.name} (#{record.parent_id}:#{record.state_id} => #{count} polygon#{ess}.)"
    }
  }

end

def read_csv(file)

  # data = CSV.open(file)

  data = CSV.read(file, options = {headers: true})

  record    = GeographicArea.new
  area_type = GeographicAreaType.new
  data.each { |row|

    puts row

    case file
      when /0/
        record    = GeographicArea.new(parent_id:  0,
                                       name:       row.field('NAME_ENGLISH'),
                                       country_id: row.field('PID'))
        area_type = GeographicAreaType.where(name: 'Country')[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: 'Country')
          at.save
          area_type = at
        end
      when /1/
        record    = GeographicArea.new(parent_id:  row.field('ID_0'),
                                       name:       row.field('NAME_1'),
                                       state_id:   row.field('ID_1'),
                                       country_id: row.field('ID_0'))
        area_type = GeographicAreaType.where(name: row.field('TYPE_1'))[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: row.field('TYPE_1'))
          at.save
          area_type = at
        end
      when /2/
        record    = GeographicArea.new(parent_id:  row.field('ID_1'),
                                       name:       row.field('NAME_2'),
                                       state_id:   row.field('ID_1'),
                                       country_id: row.field('ID_0'),
                                       county_id:  row.field('ID_2'))
        area_type = GeographicAreaType.where(name: row.field('TYPE_2'))[0]
        if area_type.nil?
          at = GeographicAreaType.new(name: row.field('TYPE_2'))
          at.save
          area_type = at
        end
      else

    end
    record.geographic_area_type = area_type
    record.save
  }
end

def build_gat_table
  ['Continent',
   'Country',
   'State',
   'Federal District',
   'County',
   'Borough',
   'Census Area',
   'Municipality',
   'City And Borough',
   'City And County',
   'District',
   'Water body',
   'Parish',
   'Independent City',
   'Province',
   'Ward',
   'Prefecture'].each { |item|

    area_type = GeographicAreaType.where(name: item)[0]
    if area_type.nil?
      at = GeographicAreaType.new(name: item)
      at.save
    end
  }
end
