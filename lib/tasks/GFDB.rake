# creating a rake task out of the bundler, so that RM can run the debugger on it.

task  :dbgf do |t|

  pn = $PROGRAM_NAME
  if pn =~ /[A-Za-z]:[\/\\]/
    os = 'Windows'
  else
    os = 'Mac'
  end

  puts "Raking on #{os}."
end


