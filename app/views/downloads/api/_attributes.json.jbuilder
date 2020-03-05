json.extract! download, :id, :is_public, :name, :description, :filename, :request, :expires, :times_downloaded, :created_at, :updated_at, :project_id 

#  id               | bigint                      |           | not null | nextval('downloads_id_seq'::regclass)
#  name             | character varying           |           | not null | 
#  description      | character varying           |           |          | 
#  filename         | character varying           |           | not null | 
#  request          | character varying           |           |          | 
#  expires          | timestamp without time zone |           | not null | 
#  times_downloaded | integer                     |           | not null | 0
#  created_at       | timestamp without time zone |           | not null | 
#  updated_at       | timestamp without time zone |           | not null | 
#  created_by_id    | integer                     |           | not null | 
#  updated_by_id    | integer                     |           | not null | 
#  project_id       | bigint                      |           |          | 
#  is_public        | boolean                     |           |          | 

