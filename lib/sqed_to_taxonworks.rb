module SqedToTaxonworks

  class Result

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

    def image_path_for(layout_section_type)
      c = sqed.boundaries.for(image_sections.index(layout_section_type))
      "/images/#{depiction.image.id}/extract/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}"
    end

    def ocr_path_for(layout_section_type)
      c = sqed.boundaries.for(image_sections.index(layout_section_type))
      "/images/#{depiction.image.id}/ocr/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}"
    end

    # @return [Array]
    def image_sections
      sqed_depiction.extraction_metadata[:metadata_map].values - [:image_registration]
    end

    # @return [Symbol]
    def primary_image 
      (image_sections & [:labels, :annotated_specimen]).first
    end

    # @return [Array]
    def secondary_sections
      image_sections - [primary_image] 
    end

  end

end
