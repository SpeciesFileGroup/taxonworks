json.extract! container, :id, :type, :name, :disposition,
:size_x,
:size_y,
:size_z,
:print_label,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.is_full container.is_full?
json.available_space container.available_space
json.size container.size

json.partial! '/shared/data/all/metadata', object: container

json.container_label label_for_container_container(container)

if container.container_items.any?
  json.container_items do
    json.array! container.container_items do |ci|
      json.partial! '/container_items/attributes', container_item: ci
      json.contained_object do
        json.partial! '/shared/data/all/metadata', object: ci.contained_object
        json.container_label container_item_container_label(ci)
      end
    end
  end
end
