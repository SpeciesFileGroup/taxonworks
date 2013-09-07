# creating a rake task out of the bundler, so that RM can run the debugger on it.

task  :dbgf do |t|

  pn = $LOAD_PATH[0]
  if pn =~ /[A-Za-z]:[\/\\]/
    os = 'Windows'
  else
    os = 'Mac'
  end

  puts "Raking on #{os}."
end


