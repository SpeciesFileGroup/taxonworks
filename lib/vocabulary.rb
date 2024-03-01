module Vocabulary

  def self.words(model: nil, attribute: nil, min: 0, max: nil, limit: nil, begins_with: nil, contains: nil, project_id: [])

    # TODO: Check for project id

    klass = get_model(model)
    return {} if klass == {}

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

  def self.attributes(model)
    klass = get_model(model)
    ApplicationEnumeration.attributes(klass)
  end

  def self.get_model(name)
    begin
      klass = ::ApplicationController.new().whitelist_constantize(name)
    rescue KeyError
      return {}
    end 
  end

end
