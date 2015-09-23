module SqedToTaxonworks

  class Result

    SMALL_WIDTH = 100
    LARGE_WIDTH = 400

    TEXT_MAP = {
      stage: :buffered_collecting_event,
      annotated_specimen: :buffered_collecting_event,
      identifier: :buffered_other_labels,
      specimen: :buffered_collecting_event,
      determination_labels: :buffered_determination_labels,
      labels: :buffered_collecting_event,
      image_registration: nil,
      curator_metadata: :buffered_other_labels,
      nothing: nil
    }

    attr_accessor :depiction

    attr_accessor :depiction_id 

    attr_accessor :namespace_id

    attr_accessor :sqed_depiction

    attr_accessor :sqed
   
    attr_accessor :sqed_result

    attr_accessor :original_image
    
    attr_accessor :width_ratio, :height_ratio

    def initialize(depiction_id: nil, namespace_id: nil)
      @depiction_id = depiction_id
      @namespace_id = namespace_id
    end

    def namespace_locked?
      !namespace_id.nil?
    end

    def depiction
      if @depiction
        @depiction
      else
        begin
          @depiction = Depiction.find(depiction_id)
          @depiction.depiction_object.taxon_determinations.build() 
          @depiction.depiction_object.identifiers.build(
            type: 'Identifier::Local::CatalogNumber',
            namespace: (namespace_locked? ? Namespace.find(namespace_id) : nil) 
          )
        rescue ActiveRecord::RecordNotFound
          return false
        end
      end
      @depiction
    end

    def sqed_depiction
      @sqed_depiction ||= depiction.sqed_depiction
    end

    def sqed
      @sqed ||= Sqed.new( sqed_depiction.extraction_metadata.merge(image: original_image) )
    end

    def sqed_result
      @sqed_result ||= sqed.result
    end

    def original_image
      @original_image ||= Magick::Image.read(depiction.image.image_file.path(:original)).first
    end

    # instance methods

    def coords_for(layout_section_type)
      sqed.boundaries.for(
        sqed_depiction.extraction_metadata[:metadata_map].key(layout_section_type)
      )
    end

    def image_path_for(layout_section_type)
      c = coords_for(layout_section_type) 
      "/images/#{depiction.image.id}/extract/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}"
    end

    def image_path_for_large_image(layout_section_type)
      c = coords_for(layout_section_type) 
#      height = (c[3].to_f / (c[2].to_f / 400)).to_i

      "/images/#{depiction.image.id}/scale_to_box/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}/400/400"
    end

    def image_path_for_small_image(layout_section_type)
      c = coords_for(layout_section_type) 
      "/images/#{depiction.image.id}/scale_to_box/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}/150/150"
    end

    def ocr_path_for(layout_section_type)
      c = coords_for(layout_section_type) 
      "/images/#{depiction.image.id}/ocr/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}"
    end

    # @return [Array]
    def image_sections
      (sqed_depiction.extraction_metadata[:metadata_map].values - [:image_registration])
    end

    # @return [Symbol]
    def primary_image 
      (image_sections & [:labels, :annotated_specimen]).first
    end

    # @return [Array]
    def secondary_sections
      image_sections - [primary_image] 
    end

    def small_dimensions_for(layout_section_type)
      c = coords_for(layout_section_type) 
      "0, 0, #{SMALL_WIDTH}, #{ (c[3].to_f / (c[2].to_f / SMALL_WIDTH)).to_i }"
    end

    def small_height_width(layout_section_type)
      c = coords_for(layout_section_type) 
      "#{SMALL_WIDTH}, #{small_height_for(layout_section_type)}"
    end

    def large_height_width(layout_section_type)
      c = coords_for(layout_section_type) 
      "#{LARGE_WIDTH}, #{large_height_for(layout_section_type)}"
    end

    def larger_height_width(layout_section_type)
      c = coords_for(layout_section_type) 
      "#{LARGE_WIDTH + 100}, #{large_height_for(layout_section_type).to_i + 100}"
    end

    def small_height_for(layout_section_type)
      c = coords_for(layout_section_type) 
     "#{(c[3].to_f / (c[2].to_f / SMALL_WIDTH)).to_i}"
    end

    def large_height_for(layout_section_type)
      c = coords_for(layout_section_type) 
     "#{(c[3].to_f / (c[2].to_f / LARGE_WIDTH)).to_i}"
    end

    def large_dimensions_for(layout_section_type)
      c = coords_for(layout_section_type) 
      "0, 0, 400, #{ (c[3].to_f / (c[2].to_f / 400)).to_i }"
    end


  end

end
