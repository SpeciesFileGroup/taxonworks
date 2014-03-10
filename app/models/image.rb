class Image < ActiveRecord::Base

  include Housekeeping::Users
  include Shared::Identifiable
  include Shared::Notable
  #include Shared::AlternateValues # can an image have alternate values?
  #include Shared::DataAttributes # can an image have attributes?
  include Shared::Taggable


  # attr_accessible :image_file
  has_attached_file :image_file, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image_file, :content_type => /\Aimage\/.*\Z/
  # validates_attachment_presence :image_file     # can't have this and call 'delete_attached_file'
  validates_attachment_size :image_file,  greater_than: 1.kilobytes

  # before_destroy :delete_attached_file

  #TODO create :default_url => "/images/:style/missing.png"?
  #TODO is paperclip content-type the same as we mean for content type?
  #TODO create large version of image_file

  def delete_attached_file
    # This call is needed until we figure out why paperclip isn't deleting the files on destroy
    image_file = nil
    self.save
  end

end
