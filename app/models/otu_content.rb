class OtuContent < Content

  include Housekeeping

  belongs_to :otu
  #belongs_to :topic
end
