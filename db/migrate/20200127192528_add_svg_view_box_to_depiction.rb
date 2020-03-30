class AddSvgViewBoxToDepiction < ActiveRecord::Migration[6.0]
  def change
    add_column :depictions, :svg_view_box, :string
  end
end
