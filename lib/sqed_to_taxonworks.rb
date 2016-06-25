module SqedToTaxonworks

  class Result

    SMALL_WIDTH = 100
    LARGE_WIDTH = 400

    TEXT_MAP = {
      annotated_specimen: :buffered_collecting_event,
      collecting_event_labels: :buffered_collecting_event,
      curator_metadata: :buffered_other_labels,
      determination_labels: :buffered_determination_labels,
      identifier: :buffered_other_labels,
      image_registration: nil,
      other_labels: :buffered_other_labels,
      labels: :buffered_collecting_event,
      nothing: nil,
      specimen: nil,
      stage: :buffered_collecting_event,
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

    def depiction
      if @depiction
        @depiction
      else
        begin
          @depiction = Depiction.find(depiction_id)
          @depiction.depiction_object.taxon_determinations.build() 
          @depiction.depiction_object.notes.build() 
          @depiction.depiction_object.tags.build() 
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
      @sqed ||= Sqed.new( sqed_depiction.extraction_metadata.merge(target_image: original_image) )
    end

    # Minimize use of this if possible, depend on the cached values when possible.
    def sqed_result
      @sqed_result ||= sqed.result
    end

    def original_image
      @original_image ||= Magick::Image.read(depiction.image.image_file.path(:original)).first
    end

    # instance methods

    def namespace_locked?
      !namespace_id.nil?
    end

    def boundaries_cached?
      !sqed_depiction.result_boundary_coordinates.nil? 
    end

    def ocr_cached?
      !sqed_depiction.result_ocr.nil? 
    end

    def cache_boundaries
      sqed_depiction.update_column(:result_boundary_coordinates, ActiveSupport::JSON.encode(sqed.boundaries.coordinates))
      sqed_depiction.reload # get the json version of the attribute back
    end

    def cache_ocr
      sqed_depiction.update_column(:result_ocr, ActiveSupport::JSON.encode(sqed_result.text))
      sqed_depiction.reload # get the json version of the attribute back
    end

    def cache_all
      cache_ocr
      cache_boundaries
    end

    def ocr_for(layout_section_type)
      index = sqed_depiction.extraction_metadata[:metadata_map].key(layout_section_type)
      if ocr_cached?
        sqed_depiction.result_ocr[layout_section_type.to_s] &&sqed_depiction.result_ocr[layout_section_type.to_s]['text']
      else
        sqed_result 
        cache_all 
        sqed_result.text_for(layout_section_type.to_sym)
      end
    end

    def coords_for(layout_section_type)
      index = sqed_depiction.extraction_metadata[:metadata_map].key(layout_section_type)
      if boundaries_cached?
        sqed_depiction.result_boundary_coordinates[index.to_s].to_a # TODO- hmm, why the to_s needed here
      else # do not do the OCR if only coords asked for
        sqed_result 
        cache_boundaries
        sqed.boundaries.for(index)
      end
    end

    def image_path_for(layout_section_type)
      c = coords_for(layout_section_type) 
      "/images/#{depiction.image.id}/extract/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}"
    end

    def image_path_for_large_image(layout_section_type)
      c = coords_for(layout_section_type) 
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
      (sqed_depiction.extraction_metadata[:metadata_map].values - [:image_registration, :specimen])
    end

    # @return [Symbol]
    def primary_image 
      (image_sections & [:labels, :collecting_event_labels, :annotated_specimen]).first
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
