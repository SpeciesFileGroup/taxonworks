# An extract is something that was taken out of another thing and quantified

class Extract < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  validates_presence_of :quantity_value 
  validates_presence_of :quantity_unit
  validates_presence_of :verbatim_anatomical_origin 
  validates :year_made,
            allow_nil: false,
            numericality: {
              only_integer: true,
              greater_than: 1000,
              less_than: Time.now.year + 5,
              message: 'must be an integer greater than 1000, and no more than 5 years in the future'
            }
                  
  validates :month_made,
            allow_nil: false,
            numericality: {
              only_integer: true,
              greater_than: 0,
              less_than: 13,
              message: 'must be an integer greater than 0 and less than 13'
            }
  validates :day_made,
           allow_nil: false,
           numericality: {
             only_integer: true,
             greater_than: 0,
             less_than: 32,
             message: 'must be an integer greater than 0 and less than 32'
           }
end
