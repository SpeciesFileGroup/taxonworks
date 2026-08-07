# app/helpers/otus/catalog_helper.rb
# http://127.0.0.1:3000/api/v1/otus/579887/inventory/content?embed[]=depictions&extend[]=image
json.array! @public_content do |c|
  json.content_id c.content.id
  json.public_content_id c.id
  json.name c.topic.name
  json.text public_content_renderer(c, params[:mode])

  if embed_response_with('depictions')
    json.depictions do
      json.array! c.content.depictions do |d|
        json.partial! '/depictions/api/v1/attributes', depiction: d
      end
    end
  end
end
