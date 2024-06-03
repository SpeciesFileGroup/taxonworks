# paperclip requires information on where ImageMagick is installed.
Paperclip.options[:command_path] = '/usr/local/bin/'

Paperclip.options[:content_type_mappings] = {
  ab1: %w(application/octet-stream),
  nex: %w(text/plain),
  nxs: %w(text/plain)
}
