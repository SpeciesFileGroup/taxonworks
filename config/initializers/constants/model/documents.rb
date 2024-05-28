# Be sure to restart your server (or console) when you modify this file.

Rails.application.config.after_initialize do

  FILE_EXTENSIONS_DATA = [
    {
      group: '',
      content_type: '',
      extensions: ['Any extension']
    },
    {
      group: 'pdf',
      content_type: 'application/pdf',
      extensions: ['.pdf']
    },
    {
      group: 'nexus',
      content_type: 'text/plain',
      extensions: ['.nex', '.nxs']
    }
  ].freeze

end
