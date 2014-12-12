namespace :tw do
  namespace :import do
    namespace :serial do

      def get_namespaces
        @import_serial_ID = Predicate.find_or_create_by(name:       'SF_SerialImportID',
                                                        definition: 'ID indicating which row from the SF serial import table (SF_serial_export.txt) generated this object')

        @sf_pub_id     = Predicate.find_or_create_by(name: 'SF_ID', definition: 'ID for this object used in SF')
        @sf_pub_reg_id = Predicate.find_or_create_by(name:       'SF_pub_reg_ID',
                                                     definition: 'ID for this object used in the SF publication registry.')

        # create needed controlled vocabulary keywords for Serials (needed for data attribute)
        @serial_note   = Predicate.find_or_create_by(name: 'Serial Note', definition: 'Comments about this serial')
        # @serial_lang_note = Predicate.find_or_create_by(name: 'Serial Language Note', definition: 'Comments specifically about the language of this serial.')
      end

      desc 'call like "rake tw:import:serial:build_SF_serials[/Users/eef/src/taxonworks/tmp/eef/SFSerialExport.txt] user_id=1 project_id=1" '
      task :build_SF_serials, [:data_directory] => [:environment, :user_id, :project_id] do |t, args|
        args.with_defaults(:data_directory => './SF_serial_export.txt')

        # can/should? be run after MXserial import

        # First file SF_serial_export.txt
        $stdout.sync = true
        print ('Starting transaction ...')

        begin
          ActiveRecord::Base.transaction do
            get_namespaces

            CSV.foreach(args[:data_directory],
                        headers:        true,
                        return_headers: false,
                        encoding:       'UTF-16LE:UTF-8',
                        col_sep:        "\t",
                        quote_char:     '|'
            ) do |row|

              # TODO convert row to a hash & reference by column name not order to make it more generic
=begin
Column : SQL column name :  data desc
0 : ImportID : file specific import ID
1 : FullName  : Full name of Serial
2 : ShortName  : SF abbreviation
3 : Publisher : Name of the publisher
4 : PlacePublished : Location of the publisher
5 : StartYear : First year serial was published
6 : EndYear : Last year serial was published
7 : Note : general notes
8 : ISSN : ISSN for the serial

Note on ISSNs - an ISSN can be used once and only once for a serial => if it's already been used for an MXserial,
need to confirm that the 2 serials are the same and add the SF data as AlternateValue::AlternateSpelling
=end

              print ("\r  tmpID #{row[0]} ")
              data_attr = []

              # add note
              if !(row[7].to_s.strip.blank?) # test for empty note!
                # notes.push({text: row[15].to_s.strip})
                data_attr.push({predicate: @serial_note, value: row[15].to_s.strip, type: 'InternalAttribute'})
              end

              # Import ID - never empty
              data_attr.push({type:             'ImportAttribute',
                              import_predicate: @import_serial_ID.name,
                              value:            row[0].to_s.strip
                             })

              identifiers =[]

              # TODO add test for existing ISSN here
              identifiers.push(
                {type:       'Identifier::Global::Issn',
                 identifier: row[8].to_s.strip}
              ) if !row[8].to_s.strip.blank?

              r = Serial.new(
                name:                       row[1].to_s.strip,
                publisher:                  row[3].to_s.strip,
                place_published:            row[4].to_s.strip,
                first_year_of_issue:        row[5],
                last_year_of_issue:         row[6],
                identifiers_attributes:     identifiers,
                data_attributes_attributes: data_attr
              )

              if row[1] != row[2] # (SF requires both a short & long name so they may be the same)
                # add short name (alternate name)
                abbr = AlternateValue.new(
                  value:                            row[2].to_s.strip,
                  alternate_value_object_attribute: 'name',
                  type:                             'AlternateValue::Abbreviation'
                )
                r.alternate_values << abbr
              end

              if r.valid? && r.name.length < 256 && r.place_published.length < 256
                r.save!
              else
                #  puts "serial content #{ap(r)} - skipping "
                # puts
                puts "error on primary save tmpID #{row[0]} -- skipping"
                if r.name.length >= 256
                  puts 'name too long'
                else
                  if r.place_published.length >= 256
                    puts 'place_published too long'
                  else
                    puts "invalid error #{ap(r.errors.messages)} "
                  end
                end

              end


            end # transaction end
            puts
            puts 'Successful load of primary serial file'
            raise 'preventing load of transaction' # causes it to always fail and rollback the transaction
          end
        rescue
          raise
        end

      end # task
    end
  end
end
