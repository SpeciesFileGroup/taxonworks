# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do 
  MATRIX_COLUMN_ITEM_TYPES = ObservationMatrixColumnItem.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }.freeze
end

