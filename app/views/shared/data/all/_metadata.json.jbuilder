json.object_tag object_tag(object)
json.object_label label_for(object)
json.global_id object.persisted? ? object.to_global_id.to_s : nil
json.base_class object.class.base_class.name
json.url_for url_for(only_path: false, format: :json)

# Some objects can not metamorphosize to a valid url base, e.g. Roles.
# This allows us to provide an alternate default object_url.
# TODO: if restricted to roles consider refactoring that response.
url_base = false if url_base.nil?
if !url_base
  json.object_url url_for(metamorphosize_if(object))
else
  json.object_url send("#{url_base}_path", object)
end

# This allows us to prevent cascading extensions when we use `&extend[]`
extensions = true if extensions.nil?
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

          json.global_id object.origin_citation.source.to_global_id.to_s
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
      json.array! object.citations, partial: '/citations/attributes', as: :citation, extension: false
    end
  end
end
