class UpdateSqedDepictionsResultTextToJSON < ActiveRecord::Migration[4.2]
  def change
    remove_column :sqed_depictions, :result_text
    add_column :sqed_depictions, :result_ocr, :json
  end
end
