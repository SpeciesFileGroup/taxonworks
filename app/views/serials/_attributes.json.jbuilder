json.extract! serial, :id, :created_by_id, :updated_by_id, :created_at, :updated_at,
:place_published, :primary_language_id, :first_year_of_issue, :last_year_of_issue, :translated_from_serial_id, :publisher, :name, :electronic_only

json.partial! '/shared/data/all/metadata', object: serial 

