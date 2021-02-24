require 'zip' # Because it is not autoloaded early enough when building docker image
::Zip.write_zip64_support = true
