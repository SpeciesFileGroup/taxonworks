# Be sure to restart your server (or console) when you modify this file.

Rails.application.config.after_initialize do

  FILE_EXTENSIONS_DATA = [
    {
      group: '',
      content_type: '',
      extensions: [
        {
          extension: 'Any extension',
          content_type: ''
        }
      ]
    },

    {
      group: 'pdf',
      extensions: [
        {
          extension: '.pdf',
          content_type: 'application/pdf',
        }
      ]
    },

    {
      group: 'nexus',
      extensions: [
        {
          extension: '.nex',
          content_type: 'text/plain'
        },
        {
          extension: '.nxs',
          content_type: 'text/plain'
        }
      ]
    }
  ].freeze

end
