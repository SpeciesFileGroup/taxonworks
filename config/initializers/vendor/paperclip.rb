# paperclip requires information on where ImageMagick is installed.
Paperclip.options[:command_path] = '/usr/local/bin/'

Paperclip.options[:content_type_mappings] = {
  ab1: %w(application/octet-stream),
  nex: %w(text/plain),
  nxs: %w(text/plain),
  # Five shapefile formats:
  shp: %w(application/octet-stream),
  dbf: %w(application/x-dbf),
  shx: %w(application/octet-stream),
  prj: %w(text/plain),
  cpg: %w(text/plain)
}
