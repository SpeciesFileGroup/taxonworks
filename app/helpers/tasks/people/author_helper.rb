module Tasks::People::AuthorHelper

  def a_range
    ('A'..'Z')
  end

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

  def select_authors(letter)
    Person.with_role('SourceAuthor').where("last_name ilike '#{letter}%'").order(:last_name).select(:last_name)
  end
end
