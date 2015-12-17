module Tasks::People::AuthorHelper

  def a_range
    ('A'...'Z')
  end

  def select_authors(letter)
    Person.with_role('LoanRecipient').where("last_name ilike '#{letter}%'")
  end
end
