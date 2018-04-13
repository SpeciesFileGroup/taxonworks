

case Rails.env

  when 'development'
    # see nested seeds 
  when 'production'
    raise Rainbow('Not so fast').red 
  when 'test'
    puts Rainbow("Test environment? You are very, very likely not doing it right.").yellow
end
