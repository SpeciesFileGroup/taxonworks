namespace :tw do
  namespace :import do
    namespace :serial do

      def set_serial_import_predicates
        @mx_t_serial_importID_name  = 'ID from MX & treehopper Serial  import'
        @mx_id_name     = 'MX ID'
        @tree_id_name   = 'Treehopper ID'
        @note_name      = 'Comments about this serial'
        @lang_note_name = 'Comments about the language of this serial'
        @sf_serial_importID_name = 'ID from SF Serial import'
        @sf_pubID_name = 'SF ID'
        @sf_pub_regID_name = 'SF publication registry ID'
      end


      desc 'run all serial processing tasks'
      task :all =>
      [
        :environment, 
        :data_directory,
        :user_id,
        :serials_1_build_MX,
        :serials_2_add_MX_duplicates,
        :serials_3_add_MX_chronologies,
        :serials_4_build_SF_serials,
        :serials_5_add_SF_IDs,
        :serials_6_add_SF_altnames
      ] do 
        puts "Success!".bold.yellow 
      end

      task :dump_all => [:environment, :data_directory] do
        database = ActiveRecord::Base.connection.current_database
        path = File.join(@args[:data_directory], 'serial_tables' + Time.now.utc.strftime("%Y-%m-%d_%H%M%S%Z") + '.dump')

        puts "Dumping data to #{path}" 

        # non-circular data FK data
        path = File.join(@args[:data_directory], 'serial_metadata_tables' + Time.now.utc.strftime("%Y-%m-%d_%H%M%S%Z") + '.dump')
        tables =  %w{serial_chronologies identifiers data_attributes alternate_values}.collect{|t| "-t #{t}"}.join(' ')
        puts(Benchmark.measure { `pg_dump --data-only -Fc #{database} -f #{path} #{tables}` }) 

        # circular fk data 
        path = File.join(@args[:data_directory], 'serial_table' + Time.now.utc.strftime("%Y-%m-%d_%H%M%S%Z") + '.dump')
        puts(Benchmark.measure { `pg_dump --data-only -Fc #{database} -f #{path} -t serials` }) 
      
      end

      desc 'call like "rake tw:import:serial:serials_1_build_MX data_directory=/Users/eef/src/data/serialdata/working_data/ user_id=1" '
      task :serials_1_build_MX => [:environment, :data_directory, :user_id] do |t|
        raise 'There are existing serials, doing nothing.' if Serial.all.count > 0

        raise 'Langauges have not yet been loaded.' if !Language.any?

        file = @args[:data_directory] + 'treeMXmerge-final.txt'

        # first file ./TreeMXmerge-final.txt
        $stdout.sync = true
        print ('Starting transaction ...')

        begin
          set_serial_import_predicates
          ActiveRecord::Base.transaction do # rm transaction

            CSV.foreach(file,
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
9 : Language : From treehopper, primary language <= modified to be english name of language (mapped to LangID - column can be ignored)
10 : LangNotes : From treehopper, usually a list of languages
11 : LangID : From MX ==> for now setting string "MX LangID <id>" <= Changed to be equal to the id from TW language file
        (See Rake task: lib/tasks/initialization/languages.rake)
12 : TreIssn: From treehopper ISSN
13 : MXISSNPrint: From MX ISSN of print version
14 : MXISSNDIg: From MX ISSN of digital version ==> make a copy of the serial and add a note that it is the digital version along with the different ISSN
15 : notes : general notes
16: URL : ==> identifier.uri

Note on ISSNs - only one ISSN is allowed per Serial, if there is a different ISSN it is considered a different Serial
=end
              tmpID = row[0].to_s.strip
              print ("      \r  tmpID #{tmpID} ")
              mxID        = row[1].to_s.strip
              treeID      = row[2].to_s.strip
#              treeMxID    = row[3].to_s.strip
              name        = row[4].to_s.strip
              publisher   = row[5].to_s.strip
              loc         = row[6].to_s.strip
              abbr        = row[7].to_s.strip
              alt_name    = row[8].to_s.strip
#              lang        = row[9].to_s.strip
              langNote    = row[10].to_s.strip
              langID      = row[11].to_s.strip
              treeIssn    = row[12].to_s.strip
              mxIssnPrint = row[13].to_s.strip
              mxIssnDig   = row[14].to_s.strip
              note        = row[15].to_s.strip
              url         = row[16].to_s.strip

              # !! languages not mached up at present
              langID = nil if langID.to_s == '0'

              r = Serial.new(
                name:                name,
                publisher:           publisher,
                place_published:     loc,
                primary_language_id: langID
              # first_year_of_issue:    row[6],              # not available from treehopper or MX data
              # last_year_of_issue:     row[7],             # not available from treehopper or MX data
              )
              if r.valid?
                r.save!

                unless note.blank?
                  r.data_attributes << ImportAttribute.new({import_predicate: @note_name, value: note})
                end
                if !(langNote.blank?)
                  r.data_attributes << ImportAttribute.new({import_predicate: @lang_note_name, value: langNote})
                end

# reference identifiers are now Import attributes
# Import ID - never empty
                r.data_attributes << ImportAttribute.new({import_predicate: @mx_t_serial_importID_name, value: tmpID})
# MX ID
                if !(mxID.blank?)
                  r.data_attributes << ImportAttribute.new({import_predicate: @mx_id_name, value: mxID})
                end
# Treehopper ID
                if !(treeID.blank?)
                  r.data_attributes << ImportAttribute.new({import_predicate: @tree_id_name, value: treeID})
                end

# ISSN  - Use treehopper first, then MX print ISSN, if there are both
# digital and print ISSNs, make the digital ISSN a second serial
                need2serials = FALSE
                if !(treeIssn.blank?)
                  r.identifiers << Identifier.new({type:       'Identifier::Global::Issn',
                                                   identifier: treeIssn
                                                  })
                else
                  if !(mxIssnPrint.blank?) # have MXprint ISSN
                    r.identifiers << Identifier.new({type:       'Identifier::Global::Issn',
                                                     identifier: mxIssnPrint})
                    if !(mxIssnDig.blank?) # have MXdigital ISSN
                      need2serials = TRUE
                    end
                  else # no MXprint ISSN
                    if !(mxIssnDig.blank?)
                      r.identifiers << Identifier.new({type:       'Identifier::Global::Issn',
                                                       identifier: mxIssnDig})
                    end
                  end
                end

                if !(url.blank?) # URL
                  r.identifiers << Identifier.new({type:       'Identifier::Global::Uri',
                                                   identifier: url
                                                  })
                end

                if !(abbr.blank?) # add abbreviation
                  r.alternate_values << AlternateValue.new({value:                            abbr,
                                                            alternate_value_object_attribute: 'name',
                                                            type:                             'AlternateValue::Abbreviation'
                                                           })
                end

                if !(alt_name.blank?) # add short name (alternate name)
                  r.alternate_values << AlternateValue.new({value:                            alt_name,
                                                            alternate_value_object_attribute: 'name',
                                                            type:                             'AlternateValue::Abbreviation'
                                                           })
                end

                if r.valid?
                  r.save!
                else
                  puts "error on second save (with annotations) tmpID #{tmpID}"
                  puts "invalid error #{ap(r.errors.messages)} \n skipping \n"
                  #puts "serial content #{ap(r)} - skipping "
                end


                if need2serials # had 2 different ISSNs for digital and print versions
                  r = Serial.new(
                    name:                name,
                    publisher:           publisher,
                    place_published:     loc,
                    primary_language_id: langID,
                  )
                  if r.valid?
                    r.save!

                    # Import ID - never empty
                    r.data_attributes << ImportAttribute.new({import_predicate: @mx_t_serial_importID_name,
                                                            value:tmpID + ' 2nd ISSN'})
                    # MX ID
                    if !(mxID.blank?)
                      r.data_attributes << ImportAttribute.new({import_predicate: @mx_id_name,
                                                              value: mxID + ' 2nd ISSN'})
                    end

                    r.identifiers << Identifier.new({type:       'Identifier::Global::Issn',
                                                     identifier: mxIssnDig})

                    if r.valid?
                      r.save!
                    else
                      puts "error on second save (with annotations) of second serial - tmpID #{tmpID}"
                      puts "invalid error message #{ap(r.errors.messages)}  \n skipping \n"
                      puts
                    end
                  else # else of 1st save of second serial object
                    puts "error saving second serial (with base object only) tmpID #{tmpID}"
                    puts "invalid error #{ap(r.errors.messages)} \n skipping \n"
                  end # end of 1st save of second serial
                end # end of need2serials
              else # else of 1st save of serial object
                puts "error on first save (serial object only) - tmpID #{tmpID}"
                puts "invalid error message #{ap(r.errors.messages)} \n skipping \n"
              end # end of 1st save of serial object
            end # read loop end
            puts
            puts 'Successful load of primary serial file'
            #raise # causes it to always fail and rollback the transaction
          end # transaction end
        rescue
          raise
        end
      end # task


      desc 'call like "rake tw:import:serial:serials_2_add_MX_duplicates data_directory=/Users/eef/src/etc user_id=1" '
      task :serials_2_add_MX_duplicates => [:environment, :data_directory, :user_id] do |t|
        file = @args[:data_directory] + 'treeMXduplicates.txt'

        raise 'There are no existing serials, doing nothing.' if Serial.all.count == 0

        # processing second file ./treeMXduplicates.txt - adding additional identifiers
        $stdout.sync = true
        print ('Starting transaction ...')

        begin
          ActiveRecord::Base.transaction do
            set_serial_import_predicates

            CSV.foreach(file,
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
              keep   = row[0].to_s.strip
              mxID   = row[3].to_s.strip
              treeID = row[4].to_s.strip
              name   = row[5].to_s.strip
              abbr   = row[6].to_s.strip

              s  = nil
              sr = Serial.joins(:data_attributes).where(data_attributes:
                                                          {value: keep, import_predicate: @mx_t_serial_importID_name})
              case sr.count # how many serials were found for this value?
                when 0
                  puts ["\n unable to find base serial ", @mx_t_serial_importID_name, keep].join(' : ')
                  puts "skipping\n"
                  next
                when 1 # found 1 and only 1 serial - we're good!
                  s = sr.first
                  print ("\r      SerialID #{s.id} : tmpID #{keep} : MXID #{mxID} : TreeID #{treeID} ")
                else
                  puts ["\n matched > 1 base serial ", @mx_t_serial_importID_name, keep].join(' : ')
                  puts "skipping\n"
                  next
              end
=begin
            Find by alternate value  - note from pair programming with Jim
            s = Source::Bibtex.new
            a = AlternateValue.where(:altvalue=>'value', :objecttype=>s.class.to_s, :objattr => 'title')
            s = a.objectID

        Identifier.where(:identifier => '8740')[0].identifier_object
        Serial.with_identifier('MX serial ID 8740')[0] <= returns an array of Serial objects
          where: Namespace = 'MX serial ID' and identifier = '8740'
=end
              unless mxID.blank? # MX_ID
                begin
                  i = s.data_attributes.where(import_predicate: @mx_id_name, value: mxID)
                  case i.count
                    when 0 # not found -> add it
                      s.data_attributes << ImportAttribute.new({import_predicate: @mx_id_name, value: mxID})
                    when 1 # found it  -> skip it
                      # puts "found an existing identifier #{ap(i.first)}"
                    else # found more than 1 -> error
                      puts "found multiple existing identifiers #{ap(i.first)}"
                  end
                end
              end

              unless treeID.blank? # Treehopper_ID
                begin
                  i = DataAttribute.where(import_predicate:       @tree_id_name,
                                          attribute_subject_type: 'Serial',
                                          attribute_subject_id:   s.id,
                                          value:                  treeID)
                  case i.count
                    when 0 # not found -> add it
                      s.data_attributes << ImportAttribute.new({import_predicate: @tree_id_name, value: treeID.to_s.strip})
                    when 1 # found it  -> skip it
                      # puts "found an existing identifier #{ap(i.first)}"
                    else # found more than 1 -> error
                      puts "found multiple existing identifiers #{ap(i.first)}"
                  end
                end
              end

              unless name.blank? # add names if they aren't already in the table
                begin
                  unless s.all_values_for(:name).include?(name)
                    begin
                      # printf('name does not match importID[%d] [%s] [%s] [%s]', keep, name, s.name,
                      #        s.all_values_for(:name))

                      s.alternate_values << AlternateValue.new(
                        value:                            name.to_s.strip,
                        alternate_value_object_attribute: 'name',
                        type:                             'AlternateValue::AlternateSpelling'
                      )
                      # else
                      # #found a match -> do nothing
                      # puts "primary name matched primary name #{s.name}" if s.name == name
                      # puts 'primary name matched alternate name' if s.all_values_for(:name).include?(name)
                    end
                  end
                end
              end

              unless abbr.blank? # add abbreviations if they aren't already in the table
                begin
                  unless s.all_values_for(:name).include?(abbr)
                    begin

                      # printf('abbreviation does not match importID[%d] [%s] [%s] [%s]', keep, abbr, s.name,
                      #        s.all_values_for(:name))

                      s.alternate_values << AlternateValue.new(
                        value:                            abbr.to_s.strip,
                        alternate_value_object_attribute: 'name',
                        type:                             'AlternateValue::Abbreviation'
                      )
                    end
                    # else
                    #   puts "alt name matched a name #{s.name}"
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


      desc 'call like "rake tw:import:serial:serials_3_add_MX_chronologies data_directory=/Users/eef/src/data/serialdata/working_data/ user_id=1" '
      task :serials_3_add_MX_chronologies => [:environment, :data_directory, :user_id] do |t| # , :project_id

        raise 'There are no existing serials, doing nothing.' if Serial.all.count == 0

        file = @args[:data_directory] + 'treeMX_SerSeq.txt'

        # Now add additional identifiers - filename is treeMXduplicates
        $stdout.sync = true
        print ('Starting transaction ...')

        begin
          ActiveRecord::Base.transaction do
            set_serial_import_predicates

            CSV.foreach(file,
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

              prefID = row[0].to_s.strip
              secID  = row[1].to_s.strip

              print ("\r  previous ID #{prefID} : succeeding ID #{secID} ")

              s1 = nil
              # find 1st serial
              sr = Serial.joins(:data_attributes).where(data_attributes:
                                                          {value: prefID, import_predicate: @mx_t_serial_importID_name})
              case sr.count # how many serials were found for this value?
                when 0
                  puts ['[', 'skipping - unable to find 1st base serial ', @mx_t_serial_importID_name, prefID, ']'].join(" : ")
                  next
                when 1 # found 1 and only 1 serial - we're good!
                  s1 = sr.first
                # if s1.name != treeID
                #   puts "#{s1.name} (Serial ID #{s1.id}) != #{treeID} (tmpid #{prefID})"
                # end
                else
                  puts ['skipping - match > 1 base serial (1st) ', @mx_t_serial_importID_name, prefID].join(" : ")
                  next
              end

              s2 = nil
              # find 2nd serial
              sr = Serial.joins(:data_attributes).where(data_attributes:
                                                          {value: secID, import_predicate: @mx_t_serial_importID_name})
              case sr.count # how many serials were found for this value?
                when 0
                  puts ['skipping - unable to find 2nd base serial ', @mx_t_serial_importID_name, secID].join(" : ")
                  next
                when 1 # found 1 and only 1 serial - we're good!
                  s2 = sr.first
                # if s2.name != row[3]
                #   puts "#{s2.name} (Serial ID #{s2.id}) != #{row[3]} (tmpid #{secfID})"
                # end
                else
                  puts ['skipping - match > 1 base serial (2nd) ', @mx_t_serial_importID_name, secID].join(" : ")
                  next
              end

              SerialChronology::SerialSequence.create!(preceding_serial: s1, succeeding_serial: s2)
            end
            puts "\nSuccessful load of MX & treehopper serial chronologies"
            # raise 'causes it to always fail and rollback the transaction'
          end # end of transaction
        rescue
          raise
        end
      end #end task
    end
  end
end
