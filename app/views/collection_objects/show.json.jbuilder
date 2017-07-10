json.success true
json.partial! "/collection_objects/attributes", collection_object: @collection_object

# curl 'http://localhost:3000/api/v1/collection_objects/3?token=FindYourOwnToken&project_id=1&include=geo_json'
# wget "http://localhost:3000/api/v1/collection_objects/3?token=FindYourOwnToken&project_id=1&include=geo_json" -O tmp/test.json

