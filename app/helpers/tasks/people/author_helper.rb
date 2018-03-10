module Tasks::People::AuthorHelper


  def letter_color(letter)
    style = ''
    if select_author_count(letter) == 0
      style =  " style='color:lightgrey;'"
    end
    "<h3#{style}>#{letter}</h3>"
  end

  def select_author_count(letter)
    select_authors(letter).count
  end

  def select_authors(letter)  # TODO: @mjy
    Person.with_role('SourceAuthor').where('last_name ilike ?', letter).order(:last_name).select(:last_name)
  end

  def cite_count(source)
    source.citations.where(project_id: sessions_current_project_id).count
  end

  def source_color(source)
    style = ' style="color:lightgrey:" '
    unless cite_count(source) == 0
      style = ''
    end
    "<span#{style}>#{source.cached}</span>"
  end
end
