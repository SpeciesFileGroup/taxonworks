json.extract! @results, :num_records, :num_gzs_created, :aborted

json.error_ids @results[:error_ids]
json.error_messages @results[:error_messages]

