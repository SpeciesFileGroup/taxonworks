namespace :tw do
  namespace :import do
    namespace :serial do

      def get_SF_namespaces
        @import_serial_ID = Predicate.find_or_create_by(name:       'SF_SerialImportID',
                                                        definition: 'ID indicating which row from the SF serial import table (SF_serial_export.txt) generated this object')

        @sf_pub_id     = Predicate.find_or_create_by(name: 'SF_ID', definition: 'ID for this object used in SF')
        @sf_pub_reg_id = Predicate.find_or_create_by(name:       'SF_pub_reg_ID',
                                                     definition: 'ID for this object used in the SF publication registry.')

        # create needed controlled vocabulary keywords for Serials (needed for data attribute)
        @serial_note   = Predicate.find_or_create_by(name: 'Serial Note', definition: 'Comments about this serial')
        # @serial_lang_note = Predicate.find_or_create_by(name: 'Serial Language Note', definition: 'Comments specifically about the language of this serial.')
      end

      desc 'call like "rake tw:import:serial:build_SF_serials[/Users/eef/src/data/serialdata/working_data/SFSerialExport.txt] user_id=1 project_id=1" '
      task :build_SF_serials, [:data_directory] => [:environment, :user_id, :project_id] do |t, args|
        args.with_defaults(:data_directory => './SFSerialExport.txt')

        # can/should? be run after MXserial import

        # First file SF_serial_export.txt
        $stdout.sync = true
        print ('Starting transaction ...')

        begin
          ActiveRecord::Base.transaction do
            get_SF_namespaces

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

              # TODO check if there is a match to an existing serial


              data_attr = []

              # add note
              unless (row[7].to_s.strip.blank?) # test for empty note!
                # notes.push({text: row[7].to_s.strip})
                data_attr.push({predicate: @serial_note, value: row[7].to_s.strip, type: 'InternalAttribute'})
              end

              # Import ID - never empty
              data_attr.push({type:             'ImportAttribute',
                              import_predicate: @import_serial_ID.name,
                              value:            row[0].to_s.strip
                             })

              identifiers =[]

              # TODO add test for existing ISSN here
              unless row[8].to_s.strip.blank?
                identifiers.push(
                  {type:       'Identifier::Global::Issn',
                   identifier: row[8].to_s.strip}
                )
              end

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
                a=1 # here to allow for break point
              else
                #  puts "serial content #{ap(r)} - skipping "
                # puts
                puts "error on primary save tmpID #{row[0]} -- skipping"
                if r.name.length >= 256
                  puts 'name too long'
                else
                  if r.errors.messages[:"identifiers.identifier"].include?("has already been taken")
                    ns = Serial.with_identifier(row[8].strip).first
                  end
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

# following are not correctly coded yet!
      desc 'call like "rake tw:import:serial:add_SF_serial_IDs[/Users/eef/src/data/serialdata/working_data/treeMXduplicates.txt] user_id=1 project_id=1" '
      task :add_SF_serial_IDs, [:data_directory] => [:environment, :user_id, :project_id] do |t, args|
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
                        type:                             'AlternateValue::AlternateSpelling'
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

=begin
SFImportIDMap.txt
  Column : SQL column name :  data desc
  0 : ImportID : file specific import ID
  1 : SFID  : SF publication ID
  2 : SFregID  : SF publication registry ID
=end
=begin
SFaltnames.txt
Column : SQL column name :  data desc
0 : ImportID : file specific import ID
1 : ShortName  : SF abbreviation
2 : SFID  : SF publication ID - check if already applied to serial
3 : SFregID  : SF publication registry ID - check if already applied to serial
=end
=begin
  SFSerialSeq.txt
  Column : SQL column name :  data desc
  0 : ImportID1 : file specific import ID  of preceding serial
  1 : ImportID2 : file specific import ID  of succeeding serial
  2 : SFregID  : SF publication registry ID of the record that created this relationship
=end
