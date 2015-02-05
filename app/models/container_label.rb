class ContainerLabel < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 
end
