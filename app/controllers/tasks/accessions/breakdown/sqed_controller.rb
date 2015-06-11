require 'tempfile'
class Tasks::Accessions::Breakdown::SqedController < ApplicationController
  include TaskControllerConfiguration

  after_filter :clean_tempfiles, only: [:index]

  def clean_tempfiles
     @tempfile.close
    #  @tempfile.unlink
  end

  def index
    @depiction = Depiction.find(params[:depiction_id])
    @sqed = Sqed.new(image: Magick::Image.read(@depiction.image.image_file.path(:thumb)).first, pattern: :cross, has_border: false)
    @sqed_result = @sqed.result
    
    width_ratio =  @depiction.image.image_file.width(:original).to_f /  @depiction.image.image_file.width(:thumb).to_f
    height_ratio =  @depiction.image.image_file.height(:original).to_f /  @depiction.image.image_file.height(:thumb).to_f

    coords = @sqed_result.boundary_coordinates[:annotated_specimen]

    w = coords[2].to_f * width_ratio.to_f
    h = coords[3].to_f * height_ratio.to_f
    
    original = Magick::Image.read(@depiction.image.image_file.path(:original)).first

    zoomed = original.crop(   
                           coords[0].to_f * width_ratio.to_f,
                           coords[1].to_f * height_ratio.to_f,
                           w,
                           h,
                           true
                          )

    @tempfile = Tempfile.new(['foo', '.jpg'], "#{Rails.root.to_s}/public/images/tmp", encoding: 'ASCII-8BIT' ) 
    @tempfile.write(zoomed.to_blob)

    @filename = 'tmp/' + @tempfile.path.split('/').last
  end

  # def material_params
  #   # params.require(:identifier) , :locks, :repository, :collection_object, :note, :collection_objects).permit(:note, :collection_object, :identifier, :repository, :locks)
  # end

end

