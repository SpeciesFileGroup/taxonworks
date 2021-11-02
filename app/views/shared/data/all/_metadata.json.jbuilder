json.object_tag object_tag(object)
json.object_label label_for(object)
json.global_id object.persisted? ? object.to_global_id.to_s : nil
json.base_class object.class.base_class.name
json.url_for url_for(only_path: false, format: :json)
json.object_url url_for(metamorphosize_if(object))

extensions = true if extensions.nil?

# This allows us to prevent cascading extensions when we use `&extend[]`
if extensions

  if extend_response_with('pinboard_item')
    json.partial! '/pinboard_items/pinned', object: object
  end

  if extend_response_with('origin_citation')
    if object.respond_to?(:origin_citation) && object.origin_citation
      json.origin_citation do
        json.extract! object.origin_citation, :id, :pages

        json.partial! '/shared/data/all/metadata', object: object.origin_citation, extensions: false

        json.source do
          json.partial! '/sources/base_attributes', source: object.origin_citation.source

          # Note: we may need to be more specific, this carries in from other role requests.
          if extend_response_with('roles')
            json.partial! '/sources/roles_attributes', source: object.origin_citation.source
          end
        end

      end
    end
  end

  if extend_response_with('citations')
    json.citations do
      json.array! object.citations, partial: '/citations/attributes', as: :citation # .reload removed
    end
  end
end
