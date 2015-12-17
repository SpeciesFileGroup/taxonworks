module Tasks::People::AuthorHelper

  def a_range
    ('A'..'Z')
  end

  def letter_color(letter)
    if select_author_count(letter) == 0
      "<h3 style='color:lightgrey;'>#{letter}</h3>"
    else
      "<h3>#{letter}</h3>"
    end
  end

  def select_author_count(letter)
    Person.with_role('SourceAuthor').where("last_name ilike '#{letter}%'").pluck(:id).count
  end

  def select_authors(letter)
    Person.with_role('SourceAuthor').where("last_name ilike '#{letter}%'")
  end
end
