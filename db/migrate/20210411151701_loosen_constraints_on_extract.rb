class LoosenConstraintsOnExtract < ActiveRecord::Migration[6.0]
  def change
    change_column_null :extracts, :year_made, true 
    change_column_null :extracts, :month_made, true 
    change_column_null :extracts, :day_made, true 
  end
end
