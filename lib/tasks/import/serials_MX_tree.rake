namespace :tw do
  namespace :import do

    desc 'call like "rake tw:initialization:upload_MX_tree_serials[/Users/eef/src/data/serialdata/serialdata/working_data/treeMXmerge-final.txt] user_id=1" '
    task :build_MXserials, [:data_directory] => [:environment, :user_id] do |t, args|
      args.with_defaults(:data_directory => './SerialExport.txt')

      # TODO: check checksums of incoming files?

      raise 'There are existing serials, doing nothing.' if Serial.all.count > 0

      begin
        ActiveRecord::Base.transaction do
          MX_SERIAL_NAMESPACE         = Namespace.find_or_create_by(name: 'MX serial ID')
          #SF_PUB_NAMESPACE = Namespace.find_or_create_by(name: 'SF Pub ID')
          #SF_PUB_REG_NAMESPACE = Namespace.find_or_create_by(name: 'SF Pub Registry ID')
          TREEHOPPER_SERIAL_NAMESPACE = Namespace.find_or_create_by(name: 'Treehopper serial ID')
          IMPORT_SERIAL_NAMESPACE     = Namespace.find_or_create_by(name: 'MX_T import serial ID')

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
0 : tmpID : file specific import ID
1 : MXID  : MX id from import file
2 : TreeID  : Treehopper ID - Note that this is a STRING
3 : TreeMXID : MX ids from the treehopper data - ; delimited string (note that duplicate MX IDs have already
    been deleted so this row can be ignored)
4 : Name : Full name of Serial
5 : Publisher : Name of the publisher
6 : Location : Location of the publisher
7 : Abbr : serial abbreviation ==> alt name type abbr
8 : Altname : alternate name for the serial
9 : Language : From treehopper, primary language <= modified to be english name of language
10 : LangNotes : From treehopper, usually a list of languages
11 : LangID : From MX ==> for now setting sting "MX LangID <id>" <= Changed to be equal to the id from TW language file
        (See Rake task: lib/tasks/initialization/languages.rake)
12 : TreIssn: From treehopper ISSN
13 : MXISSNPrint: From MX ISSN of print version
14 : MXISSNDIg: From MX ISSN of digital version ==> make a copy of the serial and add a note that it is the digital version along with the different ISSN
15 : notes : general notes
16: URL : ==> identifier.uri

Note on ISSNs - only one ISSN is allowed per Serial, if there is a different ISSN it is considered a different Serial
=end

            # add note
            notes = []
            if !(row[15].to_s.strip.blank?) # test for empty note!
              notes.push({text: row[15].to_s.strip})
            end
            if !(row[10].to_s.strip.blank?) # language notes
              notes.push({text: row[10].to_s.strip, note_object_attribute: 'language'})
            end

            identifiers=[]
            # Import ID - never empty
            identifiers.push({type:       'Identifier::Local::Import',
                              namespace:  IMPORT_SERIAL_NAMESPACE,
                              identifier: row[0].to_s.strip
                             })
            # # SF Publication       This file only contains MX & Treehopper data
            # p_ary = row[8].to_s.split(';')
            # p_ary.each {|sfid|
            #   identifiers.push({type: 'Identifier::Local::Import',
            #                     namespace: SF_PUB_NAMESPACE,
            #                     identifier: sfid.to_s.strip
            #
            #                    } )
            # }

            # MX ID
            if !(row[1].to_s.strip.blank?)
              identifiers.push({type:       'Identifier::Local::Import',
                                namespace:  MX_SERIAL_NAMESPACE,
                                identifier: row[1].to_s.strip
                               })
            end

            # Treehopper ID
            if !(row[2].to_s.strip.blank?)
              identifiers.push({type:       'Identifier::Local::Import',
                                namespace:  TREEHOPPER_SERIAL_NAMESPACE,
                                identifier: row[2].to_s.strip
                               })
            end

            # ISSN  - Use treehopper first, then MX print ISSN, if there are both
            # digital and print ISSNs, make the digital ISSN a second serial
            need2serials = FALSE
            if !(row[12].to_s.strip.blank?)
              identifiers.push({type:       'Identifier::global::issn',
                                identifier: row[12].to_s.strip
                               })
            else
              if !(row[13].to_s.strip.blank?) # have MXprint ISSN
                identifiers.push({type:       'Identifier::global::issn',
                                  identifier: row[13].to_s.strip})
                if !(row[14].to_s.strip.blank?) # have MXdigital ISSN
                  need2serials = TRUE
                end
              else # no MXprint ISSN
                if !(row[14].to_s.strip.blank?)
                  identifiers.push({type:       'Identifier::global::issn',
                                    identifier: row[14].to_s.strip})
                end
              end
            end

            # URL
            f !(row[16].to_s.strip.blank?)
            identifiers.push({type:       'Identifier::global::uri',
                              identifier: row[16].to_s.strip
                             })
          end


          r                               = Serial.new(
            name:                   row[4].to_s.strip,
            publisher:              row[5].to_s.strip,
            place_published:        row[6].to_s.strip,
            primary_language_id:    row[11].to_s.strip,
            # first_year_of_issue:    row[6],              # not available from treehopper or MX data
            # last_year_of_issue:     row[7],
            identifiers_attributes: identifiers,
            notes_attributes:       notes
          )

          # add abbreviation
          abbr                            = AlternateValue.new # or should this be an abbreviation?
          abbr.value                      = row[7].to_s.strip
          abbr.alternate_object_attribute = 'name'
          abbr.type                       = 'AlternateValue::Abbreviation'
          r.alternate_values << abbr

          # add short name (alternate name)
          alt_name                            = AlternateValue.new
          alt_name.value                      = row[8].to_s.strip
          alt_name.alternate_object_attribute = 'name'
          alt_name.type                       = 'AlternateValue::Abbreviation'
          r.alternate_values << alt_name

          r.save!

          if need2serials # had 2 different ISSNs for digital and print versions
            identifiers=[]
            # Import ID - never empty
            identifiers.push({type:       'Identifier::Local::Import',
                              namespace:  IMPORT_SERIAL_NAMESPACE,
                              identifier: row[0].to_s.strip
                             })
            # MX ID
            if !(row[1].to_s.strip.blank?)
              identifiers.push({type:       'Identifier::Local::Import',
                                namespace:  MX_SERIAL_NAMESPACE,
                                identifier: row[1].to_s.strip
                               })
            end
            identifiers.push({type:       'Identifier::global::issn',
                              identifier: row[14].to_s.strip})

            r = Serial.new(
              name:                   row[4].to_s.strip,
              publisher:              row[5].to_s.strip,
              place_published:        row[6].to_s.strip,
              primary_language_id:    row[11].to_s.strip,
              identifiers_attributes: identifiers,
              notes_attributes:       notes
            )

            r.save!

          end
        end # transaction end
        puts 'Success'
        raise # causes it to always fail and rollback the transaction

      rescue
        raise
      end

    end # task
  end
end
