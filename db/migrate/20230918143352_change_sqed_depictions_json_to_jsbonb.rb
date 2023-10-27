class ChangeSqedDepictionsJsonToJsbonb < ActiveRecord::Migration[6.1]
  def change  
    change_column :sqed_depictions, :result_ocr, :jsonb, using: 'result_ocr::jsonb'
    change_column :sqed_depictions, :result_boundary_coordinates, :jsonb, using: 'result_boundary_coordinates::jsonb'
  end
end
