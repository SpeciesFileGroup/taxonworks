module SqedToTaxonworks

  class Result

    attr_accessor :depiction

    attr_accessor :depiction_id 

    attr_accessor :thumb_sqed
   
    attr_accessor :thumb_sqed_result

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

    def thumb_sqed
      @thumb_sqed ||= Sqed.new(image: Magick::Image.read(depiction.image.image_file.path(:thumb)).first, pattern: pattern, has_border: false)
    end

    def thumb_sqed_result
      @thumb_sqed_result ||= thumb_sqed.result
    end

    def width_ratio
      @width_ratio ||= depiction.image.image_file.width(:original).to_f / depiction.image.image_file.width(:thumb).to_f
    end

    def height_ratio
      @height_ratio ||= depiction.image.image_file.height(:original).to_f /  depiction.image.image_file.height(:thumb).to_f
    end

    def original_image
      @original_image ||= Magick::Image.read(depiction.image.image_file.path(:original)).first
    end


    # Temporary image handling support

    def thumb_coordinates(layout_section_type)
       thumb_sqed_result.boundary_coordinates[layout_section_type]
    end

    def zoomed_coordinates(layout_section_type)
      x = (thumb_coordinates(layout_section_type)[0].to_f * width_ratio.to_f).to_i
      y = (thumb_coordinates(layout_section_type)[1].to_f * height_ratio.to_f).to_i
      w = (thumb_coordinates(layout_section_type)[2].to_f * width_ratio.to_f).to_i
      h = (thumb_coordinates(layout_section_type)[3].to_f * height_ratio.to_f).to_i
      [ x, y, w, h ]
    end

    # instance methods

    def image_path_for(layout_section_type)
      c = zoomed_coordinates(layout_section_type)
      "/images/#{depiction.image.id}/extract/#{c[0]}/#{c[1]}/#{c[2]}/#{c[3]}"
    end

    def image_sections
      SqedConfig::EXTRACTION_PATTERNS[pattern][:metadata_map].values
    end
 
  end

end
