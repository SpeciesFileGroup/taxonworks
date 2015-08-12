# Methods to resolve a group columns and their values to 
# an instance in TW, columns should be a Hash of legal
# values at this point
# 
module BatchLoad::ColumnResolver
  class << self
    def otu(columns)
      otus = []
      if columns['otu_id']
        begin
          otus.push Otu.find(columns['otu_id'])
        rescue ActiveRecord::RecordNotFound
        end
      elsif columns['otu_name']
        otus = Otu.where(name: columns['otu_name'], project_id: columns['project_id'])
      elsif columns['taxon_name']
        otus = Otu.joins(:taxon_names).where(taxon_names: {cached: columns['taxon_name']}, project_id: columns['project_id'])
      else
      end
      otus.size == 1 ? otus.first : nil
    end

    def source(columns)
      sources = []
      if columns['source_id']
        begin
          sources.push Source.find(columns['source_id'])
        rescue ActiveRecord::RecordNotFound
        end
      elsif columns['doi']
        sources = Source.where(doi: columns['doi']) # identifier is cached here, so we don't have to join Identifers
      elsif columns['citation']
        sources = Source.where(cached: columns['citation'])
      end
      sources.size == 1 ? sources.first : nil
    end

    def geographic_area(columns)
      geographic_areas = []
      if columns['geographic_area_id']
        begin
          geographic_areas.push GeographicArea.find(columns['geographic_area_id'])
        rescue ActiveRecord::RecordNotFound
        end
      elsif columns['geographic_area_name']
        geographic_areas = GeographicArea.where(name: columns['geographic_area_name'])
      elsif columns['country'] || columns['state'] || columns['county']
        geographic_areas = GeographicArea.with_name_and_parent_names([columns['country'], columns['state'], columns['county']].compact)
      end

      geographic_areas.size == 1 ? geographic_areas.first : nil
    end
  end

end
