namespace :tw do
  namespace :import do

    desc 'call like "rake tw:initialization:build_serials[/Users/eef/src/taxonworks/tmp/eef/SerialSubset2.txt] user_id=1" '
    task :build_serials, [:data_directory] => [:environment, :user_id] do |t, args|
      args.with_defaults(:data_directory => './SerialExport.txt')

      # TODO: check checksums of incoming files?

      raise 'There are existing serials, doing nothing.' if Serial.all.count > 0

      begin
        ActiveRecord::Base.transaction do
          MX_SERIAL_NAMESPACE = Namespace.find_or_create_by(name: 'MX serial ID')
          SF_PUB_NAMESPACE = Namespace.find_or_create_by(name: 'SF Pub ID')
          SF_PUB_REG_NAMESPACE = Namespace.find_or_create_by(name: 'SF Pub Registry ID')
          TREEHOPPER_SERIAL_NAMESPACE = Namespace.find_or_create_by(name: 'Treehopper Serial ID')

          CSV.foreach(args[:data_directory],
                      headers: true,
                      return_headers: false,
                      encoding: 'UTF-16LE:UTF-8',
                      col_sep: "\t",
                      quote_char: '|'
          ) do |row|
            # TODO convert row to a hash & reference by column name not order to make it more generic

            # add note
            # test for empty note!
            notes = []
            if !(row[7].to_s.strip.blank?)
              notes.push({text: row[7].to_s.strip})
            end

            identifiers=[]
            # SF Publication
            p_ary = row[8].to_s.split(';')
            p_ary.each {|sfid|
              identifiers.push({type: 'Identifier::Local::Import',
                namespace: SF_PUB_NAMESPACE,
                  identifier: sfid.to_s.strip

              } )
            }
            r = Serial.new(
              name: row[1].to_s.strip,
              publisher: row[3].to_s.strip,
              place_published: row[4].to_s.strip,
              first_year_of_issue: row[6],
              last_year_of_issue: row[7],
              identifiers_attributes: identifiers,
              notes_attributes: notes
            )
            # add short name (alternate name)
            alt_name = AlternateValue.new    # or should this be an abbreviation
            alt_name.value = row[2].to_s.strip
            alt_name.alternate_object_attribute = 'name'
            alt_name.type = 'AlternateValue::Abbreviation'
            r.alternate_values << alt_name

            # add identifiers
            # # MX id
            # i = Identifer.new
            # i.type = :import
            # i.identifier = row[10].to_s.strip
            # # not sure how to assign identifiers




            # # SF PubRegistry
            # p_ary = row[9].to_s.split(';').uniq
            # p_ary.each {|sfid|
            #   i= Identifier.new
            #   i.type = :import
            #   i.identifier = sfid.to_s.strip
            # }




            r.save!
          end  # transaction end
          puts 'Sucess'
          #raise # causes it to always fail and rollback the transaction
        end
      rescue
        raise
      end

    end # task
  end
end
