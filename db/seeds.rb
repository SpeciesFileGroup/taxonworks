case Rails.env

  when 'development'
    load 'db/seeds/development/user.seeds.rb'
    load 'db/seeds/development/matrix.seeds.rb'
  when 'production'
    raise Rainbow('Not so fast').red 
  when 'test'
    puts Rainbow("Test environment? You are very, very likely not doing it right.").yellow
end
