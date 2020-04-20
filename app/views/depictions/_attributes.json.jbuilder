json.extract! depiction, :id, :depiction_object_id, :depiction_object_type, 
:image_id,
:caption, :figure_label, :is_metadata_depiction,
:sled_image_id, :sled_image_x_position, :sled_image_y_position, 
:svg_view_box,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: depiction 

json.figures do
  json.medium depiction_tag(depiction, size: :medium)
  json.thumb depiction_tag(depiction, size: :thumb)
end

json.image do
  json.partial! '/images/attributes', image: depiction.image
end

if depiction.sqed_depiction
  json.sqed_depiction do
    json.extract! depiction.sqed_depiction, :id, :boundary_color, :boundary_finder, :has_border, :layout, :metadata_map, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

    r = depiction.sqed_depiction.result

    # Index of the image that contains the primary label data
    json.primary_image r.primary_image

    if r.coordinates_valid?
      json.image_sections do
        r.image_sections.each_with_index do |section, i|
          json.set! i do
            json.image_path r.image_path_for(section)
            json.large_image r.image_path_for_large_image(section)
            json.small_image r.image_path_for_small_image(section)
            json.large_height_width r.large_height_width(section)
            json.small_height_width r.small_height_width(section)

            json.ocr_path r.ocr_path_for(section)
          end
        end
      end
    end


  end
end
