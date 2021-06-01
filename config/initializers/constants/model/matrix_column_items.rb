# Be sure to restart your server when you modify this file.
#
Rails.application.config.after_initialize do 
  MATRIX_COLUMN_ITEM_TYPES = 
    ObservationMatrixColumnItem::Dynamic.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }.merge(
    ObservationMatrixColumnItem::Single.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }).freeze
end

