namespace :tw do
  namespace :import do
    namespace :serial do

      def get_namespaces
        @import_serial_ID     = Predicate.find_or_create_by(name:       'MX_T_SerialImportID',
                                                            definition: 'ID indicating which row from the MX/Treehopper serial import table (treeMXmerge-final.txt) generated this object')
        @mx_serial_id         = Predicate.find_or_create_by(name: 'MX_ID', definition: 'ID for this object used in MX')
        @treehopper_serial_id = Predicate.find_or_create_by(name: 'Tree_ID', definition: 'ID for this object used in the Treehopper data')

        #SF_PUB_NAMESPACE = Namespace.find_or_create_by(name: 'SF Pub ID')
        #SF_PUB_REG_NAMESPACE = Namespace.find_or_create_by(name: 'SF Pub Registry ID')

        # create needed controlled vocabulary keywords for Serials (needed for data attribute)
        @serial_note          = Predicate.find_or_create_by(name: 'Serial Note', definition: 'Comments about this serial')
        @serial_lang_note     = Predicate.find_or_create_by(name: 'Serial Language Note', definition: 'Comments specifically about the language of this serial.')
      end

      desc 'call like "rake tw:import:serial:build_MXserials[/Users/eef/src/data/serialdata/working_data/treeMXmerge-final.txt] user_id=1 project_id=1" '
      task :build_MXserials, [:data_directory1] => [:environment, :user_id, :project_id] do |t, args|
        args.with_defaults(:data_directory1 => './treeMXmerge-final.txt')

        # TODO: check checksums of incoming files?

        raise 'There are existing serials, doing nothing.' if Serial.all.count > 0

        # first file ./TreeMXmerge-final.txt
        $stdout.sync = true
        print ('Starting transaction ...')

        begin
          ActiveRecord::Base.transaction do # rm transaction
            get_namespaces

            CSV.foreach(args[:data_directory1],
                        headers:        true,
                        return_headers: false,
                        encoding:       'UTF-16LE:UTF-8',
                        col_sep:        "\t",
                        quote_char:     '|'
            ) do |row|

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

              print ("\r  tmpID #{row[0]} ")
              # add note
              data_attr = []
              if !(row[15].to_s.strip.blank?) # test for empty note!
                # notes.push({text: row[15].to_s.strip})
                data_attr.push({predicate: @serial_note, value: row[15].to_s.strip, type: 'InternalAttribute'})
              end
              if !(row[10].to_s.strip.blank?)
                # language notes  - data attributes are associated with the whole object and can't be assigned to an object attribute like notes.
                data_attr.push({predicate: @serial_lang_note, value: row[10].to_s.strip, type: 'InternalAttribute'})
              end

              # Import ID - never empty
              data_attr.push({type:             'ImportAttribute',
                              import_predicate: @import_serial_ID.name,
                              value:            row[0].to_s.strip
                             })
              # reference identifiers are now Import attributes
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
                data_attr.push({import_predicate: @mx_serial_id.name, value: row[1].to_s.strip, type: 'ImportAttribute'})

                # identifiers.push({type:       'Identifier::Local::Import',
                #                   namespace:  @mx_serial_namespace,
                #                   identifier: row[1].to_s.strip
                # })
              end

              # Treehopper ID
              if !(row[2].to_s.strip.blank?)
                data_attr.push({import_predicate: @treehopper_serial_id.name, value: row[2].to_s.strip, type: 'ImportAttribute'})

                # identifiers.push({type:       'Identifier::Local::Import',
                #                   namespace:  @treehopper_serial_namespace,
                #                   identifier: row[2].to_s.strip
                # })
              end

              identifiers  =[]
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
                name:                       row[4].to_s.strip,
                publisher:                  row[5].to_s.strip,
                place_published:            row[6].to_s.strip,
                primary_language_id:        row[11].to_s.strip,
                # first_year_of_issue:    row[6],              # not available from treehopper or MX data
                # last_year_of_issue:     row[7],             # not available from treehopper or MX data
                identifiers_attributes:     identifiers, # TODO identifiers & data_attributes require project_id even on non-project objects
                data_attributes_attributes: data_attr
              )

              # add abbreviation
              if !(row[7].to_s.strip.blank?)
                abbr                                  = AlternateValue.new # or should this be an abbreviation?
                abbr.value                            = row[7].to_s.strip
                abbr.alternate_value_object_attribute = 'name'
                abbr.type                             = 'AlternateValue::Abbreviation'
                r.alternate_values << abbr
              end

              # add short name (alternate name)
              if !(row[8].to_s.strip.blank?)
                alt_name                                  = AlternateValue.new
                alt_name.value                            = row[8].to_s.strip
                alt_name.alternate_value_object_attribute = 'name'
                alt_name.type                             = 'AlternateValue::Abbreviation'
                r.alternate_values << alt_name
              end

              # r.identifiers.each do |ident|
              #   if !ident.valid?
              #     puts "invalid identifier #{ap(ident)}"
              #   end
              # end

              if r.valid? && r.name.length < 256
                r.save!
              else
                puts "error on primary save tmpID #{row[0]}"
                if r.name.length >= 256
                  puts 'name too long'
                else
                  puts "invalid error #{ap(r.errors.messages)} "
                end
                puts "serial content #{ap(r)} - skipping "
                puts
              end


              if need2serials # had 2 different ISSNs for digital and print versions
                data_attr = []
                # Import ID - never empty
                data_attr.push({type:             'ImportAttribute',
                                import_predicate: @import_serial_ID.name,
                                value:            row[0].to_s.strip + ' 2nd ISSN'
                               })
                # MX ID
                if !(row[1].to_s.strip.blank?)
                  data_attr.push({import_predicate: @mx_serial_id.name,
                                  value:            row[10].to_s.strip + ' 2nd ISSN',
                                  type:             'ImportAttribute'})
                end

                identifiers=[]
                identifiers.push({type:       'Identifier::Global::Issn',
                                  identifier: row[14].to_s.strip})

                # r.identifiers.each do |ident|
                #   if !ident.valid?
                #     puts "invalid identifier #{ap(ident)}"
                #   end
                # end


                r = Serial.new(
                  name:                       row[4].to_s.strip,
                  publisher:                  row[5].to_s.strip,
                  place_published:            row[6].to_s.strip,
                  primary_language_id:        row[11].to_s.strip,
                  identifiers_attributes:     identifiers,
                  data_attributes_attributes: data_attr
                )

                if r.valid? && r.name.length < 256
                  r.save!
                  # if data_attr.count > 0
                  #   z = 1 # here so I can check the results of the save
                  # end
                else
                  puts "error saving second serial - tmpID #{row[0]}"
                  if r.name.length >= 256
                    puts '  name too long'
                  else
                    puts "invalid error message #{ap(r.errors.messages)} "
                  end
                  puts "serial #{ap(r)} - skipping "
                  puts

                  # puts " error #{ap(r.errors)} with #{ap(r)}, skipping"
                end


              end
            end
            puts
            puts 'Successful load of primary serial file'
            #raise # causes it to always fail and rollback the transaction
            #                    rescue Exception => e
            #                      #raise              #comment out to here to remove transaction
            #                      puts(e)
            #                      break
            #                    end

          end # transaction end
        rescue
          raise

        end


      end # task


      desc 'call like "rake tw:import:serial:add_duplicate_MXserials[/Users/eef/src/data/serialdata/working_data/treeMXduplicates.txt] user_id=1 project_id=1" '
      task :add_duplicate_MXserials, [:data_directory] => [:environment, :user_id, :project_id] do |t, args|
        args.with_defaults(:data_directory => './treeMXduplicates.txt')

        raise 'There are no existing serials, doing nothing.' if Serial.all.count == 0

        # processing second file ./reeMXduplicates.txt - adding additional identifiers
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

              # s = Serial.with_namespaced_identifier(@import_serial_ID.name, row[0]).first
              s  = nil
              sr = Serial.joins(:data_attributes).where(data_attributes: {value: row[0], import_predicate: @import_serial_ID.name})
              # no longer a namespace identifier, now a data attribute
              case sr.count # how many serials were found for this value?
                when 0
                  puts ['skipping - unable to find base serial ', @import_serial_ID.name, row[0]].join(" : ")
                  next
                when 1 # found 1 and only 1 serial - we're good!
                  s = sr.first
                  print ("\r SerialID #{s.id} : tmpID #{row[0]} : MXID #{row[3]} : TreeID #{row[4]} ")
                else
                  puts ['skipping - match > 1 base serial ', @import_serial_ID.name, row[0]].join(" : ")
                  next
              end
=begin
            Find by alternate value  - note from pair programming with Jim
            s = Source::Bibtex.new
            a = AlternateValue.where(:altvalue=>'value', :objecttype=>s.class.to_s, :objattr => 'title')
            s = a.objectID

to save without raising
      a = AlternateValue.new(:altvalue=>'value', :objecttype=>s.class.to_s, :objattr => 'title')
      if a.valid? then save else continue the loop

        Identifier.where(:identifier => '8740')[0].identifier_object
        Serial.with_identifier('MX serial ID 8740')[0] <= returns an array of Serial objects
          where: Namespace = 'MX serial ID' and identifier = '8740'
=end
              unless row[3].blank? # MX_ID
                begin
                  i = DataAttribute.where(import_predicate:     @mx_serial_id.name, attribute_subject_type: 'Serial',
                                          attribute_subject_id: s.id, value: row[3])
                  case i.count
                    when 0 # not found -> add it
                      s.data_attributes << DataAttribute.new({import_predicate: @mx_serial_id.name, value: row[3].to_s.strip, type: 'ImportAttribute'})
                    when 1 # found it  -> skip it
                      # puts "found an existing identifier #{ap(i.first)}"
                    else # found more than 1 -> error
                      puts "found multiple existing identifiers #{ap(i.first)}"
                  end
                end
              end

              unless row[4].blank? # Treehopper_ID
                begin
                  i = DataAttribute.where(import_predicate:       @treehopper_serial_id.name,
                                          attribute_subject_type: 'Serial',
                                          attribute_subject_id:   s.id, value: row[4])
                  case i.count
                    when 0 # not found -> add it
                      s.data_attributes << DataAttribute.new({import_predicate: @mx_serial_id.name,
                                                              value:            row[4].to_s.strip, type: 'ImportAttribute'})
                    when 1 # found it  -> skip it
                      # puts "found an existing identifier #{ap(i.first)}"
                    else # found more than 1 -> error
                      puts "found multiple existing identifiers #{ap(i.first)}"
                  end
                end
              end

              unless row[5].blank? # add names if they aren't already in the table
                begin
                  unless s.all_values_for(:name).include?(row[5])
                    begin
                      # printf('name does not match importID[%d] [%s] [%s] [%s]', row[0], row[5], s.name,
                      #        s.all_values_for(:name))

                      s.alternate_values << AlternateValue.new(
                        value:                            row[5].to_s.strip,
                        alternate_value_object_attribute: 'name',
                        type:                             'AlternateValue::Synonym'
                      )
                      # else
                      #found a match -> do nothing
                      # puts "primary name matched primary name #{s.name}" if s.name == row[5]
                      # puts 'primary name matched alternate name' if s.all_values_for(:name).include?(row[5])
                    end
                  end
                end
              end

              unless row[6].blank? # add abbreviations if they aren't already in the table
                begin
                  unless s.all_values_for(:name).include?(row[6])
                    begin

                      # printf('abbreviation does not match importID[%d] [%s] [%s] [%s]', row[0], row[6], s.name,
                      #        s.all_values_for(:name))

                      s.alternate_values << AlternateValue.new(
                        value:                            row[6].to_s.strip,
                        alternate_value_object_attribute: 'name',
                        type:                             'AlternateValue::Abbreviation'
                      )
                      # else
                      #   puts 'alt name matched alternate name'
                    end
                    # else
                    #   puts "alt name matched primary name #{s.name}"
                    # end
                  end
                end
              end
              if s.valid?
                s.save
              else
                raise 's not valid'
              end
            end # end of row
            puts
            puts 'Successful load of MX & treehopper duplicate IDs'
            # raise 'to prevent saving to db while testing rake'
          end # end transaction
        rescue
          raise
        end
      end #end task


      desc 'call like "rake tw:import:serial:add_chronologies_MXserials[/Users/eef/src/data/serialdata/working_data/treeMX_SerialSeq.txt] user_id=1, project_id=1" '
      task :add_chronologies_MXserials, [:data_directory] => [:environment, :user_id, :project_id] do |t, args|
        args.with_defaults(:data_directory => './treeMX_SerialSeq.txt')

        raise 'There are no existing serials, doing nothing.' if Serial.all.count == 0

        # Now add additional identifiers - filename is treeMXduplicates
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
=begin
Column : SQL column name : data desc
0 : PrefID: The tmpID of the first serial
1 : SecID : The tmpID of the second serial
2 : PrevName: <ignore> Fullname of the first serial
3 : SucName  : <ignore> Fullname of the Second serial
=end

              print ("\r  previous ID #{row[0]} : succeeding ID #{row[1]} ")

              s1 = nil
              # find 1st serial
              sr = Serial.joins(:data_attributes).where(data_attributes: {value: row[0], import_predicate: @import_serial_ID.name})
              case sr.count # how many serials were found for this value?
                when 0
                  puts ['[', 'skipping - unable to find base serial ', @import_serial_ID.name, row[0], ']'].join(" : ")
                  next
                when 1 # found 1 and only 1 serial - we're good!
                  s1 = sr.first
                # if s1.name != row[2]
                #   puts "#{s1.name} (Serial ID #{s1.id}) != #{row[2]} (tmpid #{row[0]})"
                # end
                else
                  puts ['skipping - match > 1 base serial ', @import_serial_ID.name, row[0]].join(" : ")
                  next
              end

              s2 = nil
              # find 2nd serial
              sr = Serial.joins(:data_attributes).where(data_attributes: {value: row[1], import_predicate: @import_serial_ID.name})
              case sr.count # how many serials were found for this value?
                when 0
                  puts ['skipping - unable to find base serial ', @import_serial_ID.name, row[1]].join(" : ")
                  next
                when 1 # found 1 and only 1 serial - we're good!
                  s2 = sr.first
                # if s2.name != row[3]
                #   puts "#{s2.name} (Serial ID #{s2.id}) != #{row[3]} (tmpid #{row[1]})"
                # end
                else
                  puts ['skipping - match > 1 base serial ', @import_serial_ID.name, row[1]].join(" : ")
                  next
              end
              SerialChronology.create!(preceding_serial: s1, succeeding_serial: s2)
            end
            puts
            puts 'Successful load of MX & treehopper serial chronologies'
            # raise 'causes it to always fail and rollback the transaction'
          end # end of transaction
        rescue
          raise
        end
      end #end task
    end
  end
end
