json.set! :keywords do
  keywords_on_addable_row_items.each do |kw|
    json.set! kw.to_global_id.to_s do
      json.set! :object do
        json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: kw
      end
      json.set! :totals do
        t = 0
        [Otu, CollectionObject, Sound].each do |k|
          c = k.joins(:tags).where(tags: {keyword: kw}).count
          json.set! k, c
          t = t + c
        end
        json.total t
      end 
    end
  end
end

json.set! :pinboard do
  json.set! :totals do
    [Otu, CollectionObject, Sound].each do |k|
      json.set! k.name, PinboardItem.where(user_id: sessions_current_user_id, project_id: sessions_current_project_id, pinned_object_type: k.to_s).count
    end 
  end
end
