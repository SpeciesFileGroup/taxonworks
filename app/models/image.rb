class Image < ActiveRecord::Base

  include Housekeeping::Users
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable

  has_attached_file :image_file, :styles => { :medium => "300x300>", :thumb => "100x100>" } # , :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image_file, :content_type => /\Aimage\/.*\Z/
  validates_attachment_presence :image_file    
  validates_attachment_size :image_file,  greater_than: 1.kilobytes

  # TODO: this shouldn't be required
  before_destroy :delete_attached_file

  #TODO create :default_url => "/images/:style/missing.png"?
  #TODO is paperclip content-type the same as we mean for content type?
  #TODO create large version of image_file

  protected

  def delete_attached_file
    image_file.destroy 
  end

end
