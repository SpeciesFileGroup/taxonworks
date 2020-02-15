class AddSvgClipToDepiction < ActiveRecord::Migration[5.2]
  def change
    add_column :depictions, :svg_clip, :xml
  end
end
