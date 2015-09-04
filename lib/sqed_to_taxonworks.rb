module SqedToTaxonworks

  class Result

    attr_accessor :depiction

    attr_accessor :depiction_id 

    attr_accessor :sqed
   
    attr_accessor :sqed_result

    attr_accessor :width_ratio, :height_ratio

    attr_accessor :original_image

    attr_accessor :user_id, :project_id

    attr_accessor :pattern 

    def initialize(depiction_id: nil, user_id: nil, project_id: nil, pattern: :cross)
      @depiction_id = depiction_id
      @pattern = pattern
      @user_id = user_id
      @project_Id = project_id 
    end

    def depiction
      if @depiction
        @depiction
      else
        begin
          @depiction ||= Depiction.find(depiction_id)
         # @depiction.depiction_object.otus.build() 
         # @depiction.depiction_object.identifiers.build()
        rescue ActiveRecord::RecordNotFound
          return false
        end
      end
    end

    def sqed
      @sqed ||= Sqed.new(image: original_image, pattern: pattern, has_border: false)
    end

    def sqed_result
      @sqed_result ||= sqed.result
    end

    def original_image
      @original_image ||= Magick::Image.read(depiction.image.image_file.path(:original)).first
    end

    # instance methods

    def image_path_for(layout_section_type)
      c = sqed.boundaries.for(layout_section_type)
      "/images/#{depiction.image.id}/extract/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}"
    end

    def image_sections
      SqedConfig::EXTRACTION_PATTERNS[pattern][:metadata_map].values
    end
 
  end

end
