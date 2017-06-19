# Be sure to restart your server when you modify this file.
MATRIX_ROW_ITEM_TYPES = ObservationMatrixRowItem.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }.freeze

