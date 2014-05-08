namespace :tw do
  namespace :development do
    namespace :data do
      namespace :geo do

        # INIT tasks for RGeo, PostGIS, shape files (GADM, TDWG, and NE)

        # TODO: Problems with GADM V2
        #   28758: Not a valid geometry.
        #   200655: Side location conflict at 33.489303588867358, 0.087361000478210826

        SFG          = 'SpeciesFile Group'

        # ISO Country Codes:
        # See http://www.iso.org/iso/home/standards/country_codes.htm

        ISO_3166_1_2 = 'ISO 3166-1-alpha-2' # ISO 3166-1:2006 two-letter country abbreviations
        ISO_3166_1_3 = 'ISO 3166-1-alpha-3' # ISO 3166-1:2006 three-letter country abbreviations

        # Other current choices are:
        ISO_3166_3   = 'ISO 3166-3:1999' # Country names which have been deleted from -1 since 1974
        ISO_3166_2   = 'ISO 3166-2:2007' # State or Province level for country codes in 3166-1

        TDWG2_L1 = 'TDWG2 Level 1'
        TDWG2_L2 = 'TDWG2 Level 2'
        TDWG2_L3 = 'TDWG2 Level 3'
        TDWG2_L4 = 'TDWG2 Level 4'

        GADM2_0 = 'GADM2 Level 0'
        GADM2_1 = 'GADM2 Level 1'
        GADM2_2 = 'GADM2 Level 2'

        NE0_10 = 'NaturalEarth-0 (10m)'
        NE1_10 = 'NaturalEarth-1 (10m)'
        NE_50  = 'NaturalEarth (50m)'
        NE_110 = 'NaturalEarth (110m)'

        EXTRA = 'Extra'

        task :geo_dev_init do
          Raise 'Can not be run in production' if Rails.env == 'production'
        end

      end
    end
  end
end
