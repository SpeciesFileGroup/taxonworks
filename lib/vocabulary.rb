module Vocabulary

  def self.words(model: nil, attribute: nil, min: 0, max: nil, limit: nil, begins_with: nil, contains: nil, project_id: [])
    begin
      klass = ::ApplicationController.new().whitelist_constantize(model)
    rescue KeyError
      return {}
    end 

    c = "COUNT(#{attribute})"

    words = klass.where(project_id:)

    # TODO: sanitize 
    # ActiveRecord::Base.send( :sanitize_sql_array, [])

    words = words.where( "#{attribute} like '#{begins_with}%'") if begins_with
    words = words.where("#{attribute} like '%#{contains}%'") if contains
    words = words.having("#{c} > ?", min) if min
    words = words.having("#{c} < ?", max) if max
    words = words.limit(limit) if limit
    words.group(attribute).order(c + ' DESC').count
  end



end
