class DataRefineGeographicAreas1 < ActiveRecord::Migration[6.0]
  def change
    Rake::Task['tw:maintenance:geo:refine_geographic_areas_1'].invoke
  end
end
