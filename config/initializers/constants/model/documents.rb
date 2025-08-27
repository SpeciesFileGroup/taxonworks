# Be sure to restart your server (or console) when you modify this file.

Rails.application.config.after_initialize do

  FILE_EXTENSIONS_DATA = [
    {
      group: '',
      content_type: '',
      extensions_data: [
        {
          extension: 'Any extension',
          content_type: ''
        }
      ]
    },

    {
      group: 'pdf',
      extensions_data: [
        {
          extension: '.pdf',
          content_type: 'application/pdf',
        }
      ]
    },

    {
      group: 'nexus',
      extensions_data: [
        {
          extension: '.nex',
          content_type: 'text/plain'
        },
        {
          extension: '.nxs',
          content_type: 'text/plain'
        }
      ]
    },

    {
      group: 'shapefile',
      extensions_data: [
        {
          extension: '.shp',
          content_type: 'application/x-shapefile'
        },
        {
          extension: '.shx',
          content_type: 'application/x-shapefile'
        },
        {
          extension: '.dbf',
          content_type: 'application/x-dbf'
        },
        {
          extension: '.prj',
          content_type: 'text/plain'
        },
        {
          extension: '.cpg',
          content_type: 'text/plain'
        }
      ]
    },

    {
      group: 'shp',
      extensions_data: [
        {
          extension: '.shp',
          content_type: 'application/x-shapefile'
        }
      ]
    },

    {
      group: 'shx',
      extensions_data: [
        {
          extension: '.shx',
          content_type: 'application/x-shapefile'
        }
      ]
    },

    {
      group: 'dbf',
      extensions_data: [
        {
          extension: '.dbf',
          content_type: 'application/x-dbf'
        }
      ]
    },

    {
      group: 'prj',
      extensions_data: [
        {
          extension: '.prj',
          content_type: 'text/plain'
        }
      ]
    },

    {
      group: 'cpg',
      extensions_data: [
        {
          extension: '.cpg',
          content_type: 'text/plain'
        }
      ]
    }

  ].freeze

end
