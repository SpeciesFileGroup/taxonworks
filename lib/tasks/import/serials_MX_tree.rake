namespace :tw do
  namespace :import do

    desc 'call like "rake tw:import:build_MXserials[/Users/eef/src/data/serialdata/working_data/treeMXmerge-final.txt] user_id=1 project_id=1" '
    task :build_MXserials, [:data_directory1] => [:environment, :user_id, :project_id] do |t, args|
      args.with_defaults(:data_directory1 => './treeMXmerge-final.txt')

      # TODO: check checksums of incoming files?

      raise 'There are existing serials, doing nothing.' if Serial.all.count > 0

      # first file ./TreeMXmerge-final.txt
      begin
        $stdout.sync = true
        print ("Starting transaction ...")

        ActiveRecord::Base.transaction do     # rm transaction
          IMPORT_SERIAL_NAMESPACE     =
            Namespace.find_or_create_by(name: 'MX-Treehopper serial import ID', short_name: 'MX_T importID')
          MX_SERIAL_NAMESPACE         = Namespace.find_or_create_by(name: 'MX serial ID', short_name: 'MX_ID')
          TREEHOPPER_SERIAL_NAMESPACE = Namespace.find_or_create_by(name: 'Treehopper serial ID', short_name: 'TreeID')

          #SF_PUB_NAMESPACE = Namespace.find_or_create_by(name: 'SF Pub ID')
          #SF_PUB_REG_NAMESPACE = Namespace.find_or_create_by(name: 'SF Pub Registry ID')

          # create needed controlled vocabulary keywords for Serials (needed for data attribute)
          SERIAL_NOTE  = Predicate.new(name: 'Serial Note', definition: 'Comments about this serial')
          SERIAL_NOTE.save!
          SERIAL_LANG_NOTE = Predicate.new(name: 'Serial Language Note', definition: 'Comments specifically about the language of this serial.')
          SERIAL_LANG_NOTE.save!
          # I think I can use find or create for this - need to test

          CSV.foreach(args[:data_directory1],
                      headers:        true,
                      return_headers: false,
                      encoding:       'UTF-16LE:UTF-8',
                      col_sep:        "\t",
                      quote_char:     '|'
          ) do |row|
            begin
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
            $stdout.sync = true
            print ("tmpID #{row[0]} starting ...")
            # moved notes to dataAttribute, but couldn't get the [] format to work, so moved to after the
            # base serial was created.
            # add note
            data_attr = []
            if !(row[15].to_s.strip.blank?) # test for empty note!
              # notes.push({text: row[15].to_s.strip})
              data_attr.push({predicate: SERIAL_NOTE, value: row[15].to_s.strip, type: 'InternalAttribute'})
            end
            if !(row[10].to_s.strip.blank?) # language notes  - data attributes are associated with the whole object and can't be assigned to an object attribute like notes.
              data_attr.push({predicate: SERIAL_LANG_NOTE, value: row[10].to_s.strip, type: 'InternalAttribute'})
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
              identifiers.push({type:       'Identifier::Global::Issn',
                                identifier: row[12].to_s.strip
                               })
            else
              if !(row[13].to_s.strip.blank?) # have MXprint ISSN
                identifiers.push({type:       'Identifier::Global::Issn',
                                  identifier: row[13].to_s.strip})
                if !(row[14].to_s.strip.blank?) # have MXdigital ISSN
                  need2serials = TRUE
                end
              else # no MXprint ISSN
                if !(row[14].to_s.strip.blank?)
                  identifiers.push({type:       'Identifier::Global::Issn',
                                    identifier: row[14].to_s.strip})
                end
              end
            end

            # URL
            if !(row[16].to_s.strip.blank?)
              identifiers.push({type:       'Identifier::Global::Uri',
                                identifier: row[16].to_s.strip
                               })
            end

            r = Serial.new(
              name:                   row[4].to_s.strip,
              publisher:              row[5].to_s.strip,
              place_published:        row[6].to_s.strip,
              primary_language_id:    row[11].to_s.strip,
              # first_year_of_issue:    row[6],              # not available from treehopper or MX data
              # last_year_of_issue:     row[7],             # not available from treehopper or MX data
              identifiers_attributes: identifiers, # TODO identifiers require project even on non-project objects
              data_attributes_attributes:       data_attr
            )

            # add abbreviation
            if !(row[7].to_s.strip.blank?)
              abbr                            = AlternateValue.new # or should this be an abbreviation?
              abbr.value                      = row[7].to_s.strip
              abbr.alternate_value_object_attribute = 'name'
              abbr.type                       = 'AlternateValue::Abbreviation'
              r.alternate_values << abbr
            end

            # add short name (alternate name)
            if !(row[8].to_s.strip.blank?)
              alt_name                            = AlternateValue.new
              alt_name.value                      = row[8].to_s.strip
              alt_name.alternate_value_object_attribute = 'name'
              alt_name.type                       = 'AlternateValue::Abbreviation'
              r.alternate_values << alt_name
            end

            r.identifiers.each do |ident|
              if !ident.valid?
                str = 'A place for me to break'
                # current problem - TreeID 100 claims to be used more than once; but can't find another use in TreeMX_merge
              end
            end
            r.save!

            if need2serials # had 2 different ISSNs for digital and print versions
              identifiers=[]
              # Import ID - never empty
              identifiers.push({type:       'Identifier::Local::Import',
                                namespace:  IMPORT_SERIAL_NAMESPACE,
                                identifier: row[0].to_s.strip + ' 2nd ISSN'
                               })
              # MX ID
              if !(row[1].to_s.strip.blank?)
                identifiers.push({type:       'Identifier::Local::Import',
                                  namespace:  MX_SERIAL_NAMESPACE,
                                  identifier: row[1].to_s.strip + ' 2nd ISSN'
                                 })
              end
              identifiers.push({type:       'Identifier::Global::Issn',
                                identifier: row[14].to_s.strip})

              r = Serial.new(
                name:                   row[4].to_s.strip,
                publisher:              row[5].to_s.strip,
                place_published:        row[6].to_s.strip,
                primary_language_id:    row[11].to_s.strip,
                identifiers_attributes: identifiers,
                data_attributes_attributes:       data_attr
              )

              r.save!
              if data_attr.count > 0
                z = 1 # here so I can check the results of the save
              end
              end

            print("Ending | ")
          end
          puts 'Successful load of primary serial file'
          #raise # causes it to always fail and rollback the transaction
        end # transaction end

      rescue => e
        #raise              #comment out to here to remove transaction
        puts(e)
        break
      end

    end # task

    desc 'call like "rake tw:import:add_duplicate_MXserials[/Users/eef/src/data/serialdata/working_data/treeMXduplicates.txt] user_id=1" '
    task :add_duplicate_MXserials, [:data_directory] => [:environment, :user_id] do |t, args|
      args.with_defaults(:data_directory => './treeMXduplicates.txt')

      # Now add additional identifiers - filename is treeMXduplicates
      begin
        Activerecord::Base.transaction do
          CSV.foreach(args[:data_directory],
                      headers:        true,
                      return_headers: false,
                      encoding:       'UTF-16LE:UTF-8',
                      col_sep:        "\t",
                      quote_char:     '|'
          ) do
=begin
Column : SQL column name : data desc
0 : Keep : The tmpID of the primary source
1 : Delete : The tmpID of the duplicated source (was never loaded)
2 : Type : <ignore> in this case always equals "Tree" for MXtreehopper file
3 : MXID  : add as an additional identifier if not already there
4 : TreeID  : add as an additional identifier   if not already there
5 : Name    : only add if it doesn't match primary or alt name   if not already there
6 : Abbr    : only add if it doesn't match primary or alt name   if not already there

=end
            s = Serial.with_namespaced_identifier('IMPORT_SERIAL_NAMESPACE ', row[0])
=begin
            Find by alternate value  - note from pair programming with Jim
            s = Source::Bibtex.new
            a = AlternateValue.where(:altvalue=>'value', :objecttype=>s.class.to_s, :objattr => 'title')
            s = a.objectID

to save without raising
      a = AlternateValue.new(:altvalue=>'value', :objecttype=>s.class.to_s, :objattr => 'title')
      if a.valid? then save else continue the loop

        Identifier.where(:identifier => '8740')[0].identified_object
        Serial.with_identifier('MX serial ID 8740')[0] <= returns an array of Serial objects
          where: Namespace = 'MX serial ID' and identifier = '8740'
=end
            identifiers =[]
            # add MXID if it doesn't match
            # add TreeID if it doesn't match

            # add names if they aren't already in the table
            # if !(s.title = row[5]) || !(s.with_alternate_value_on(:title, row[5]).count > 0)
            #   printf('name does not match importID[%d] [%s] [%s] [%s]', row[0], row[5], s.title,
            #          s.title.alternate_values)
            # end


          end
          puts 'Successful load of MX & treehopper duplicate IDs'
          raise # causes it to always fail and rollback the transaction
        end
      rescue
        raise
      end

    end #end task
    desc 'call like "rake tw:import:add_chronologies_MXserials[/Users/eef/src/data/serialdata/working_data/treeMX_SerialSeq.txt] user_id=1, project_id=1" '
    task :add_duplicate_MXserials, [:data_directory] => [:environment, :user_id] do |t, args|
      args.with_defaults(:data_directory => './treeMX_SerialSeq.txt')

      # Now add additional identifiers - filename is treeMXduplicates
      begin
        Activerecord::Base.transaction do
          CSV.foreach(args[:data_directory],
                      headers:        true,
                      return_headers: false,
                      encoding:       'UTF-16LE:UTF-8',
                      col_sep:        "\t",
                      quote_char:     '|'
          ) do
=begin
Column : SQL column name : data desc
0 : PrefID: The tmpID of the first serial
1 : SecID : The tmpID of the second serial
2 : PrevName: <ignore> Fullname of the first serial
3 : SucName  : <ignore> Fullname of the Second serial
=end
            # i = Identifer.with_identifier('IMPORT_SERIAL_NAMESPACE ' + Row[0])
            s           = Serial.with_namespaced_identifier('IMPORT_SERIAL_NAMESPACE ', row[0])
            identifiers =[]
            if !(s.title = row[5]) || !(s.with_alternate_value_on(:title, row[5]).count > 0)
              printf('name does not match importID[%d] [%s] [%s] [%s]', row[0], row[5], s.title,
                     s.title.alternate_values)
            end
=begin
            Find by alternate value  - note from pair programming with Jim
            s = Source::Bibtex.new
            a = AlternateValue.where(:altvalue=>'value', :objecttype=>s.class.to_s, :objattr => 'title')
            s = a.objectID

to save without raising
      a = AlternateValue.new(:altvalue=>'value', :objecttype=>s.class.to_s, :objattr => 'title')
      if a.valid? then save else continue the loop

        Identifier.where(:identifier => '8740')[0].identified_object
        Serial.with_identifier('MX serial ID 8740')[0] <= returns an array of Serial objects
          where: Namespace = 'MX serial ID' and identifier = '8740'
=end
          end
          puts 'Successful load of MX & treehopper duplicate IDs'
          raise # causes it to always fail and rollback the transaction
        end
      rescue
        raise
      end

    end #end task

  end
end


