namespace :tw do
  namespace :import do
    namespace :serial do

  def get_namespaces
      @import_serial_namespace     =
        Namespace.find_or_create_by(name: 'SF serial import ID', short_name: 'SF importID')

      @sf_pub_namespace = Namespace.find_or_create_by(name: 'SF Pub ID')
      @sf_pub_reg_namespace = Namespace.find_or_create_by(name: 'SF Pub Registry ID')

      # create needed controlled vocabulary keywords for Serials (needed for data attribute)
      @serial_note  = Predicate.find_or_create_by(name: 'Serial Note', definition: 'Comments about this serial')
      @serial_lang_note = Predicate.find_or_create_by(name: 'Serial Language Note', definition: 'Comments specifically about the language of this serial.')
    end

  desc 'call like "rake tw:import:serial:build_serials[/Users/eef/src/taxonworks/tmp/eef/SFSerialExport.txt] user_id=1 project_id=1" '
    task :build_serials, [:data_directory] => [:environment, :user_id, :project_id] do |t, args|
      args.with_defaults(:data_directory => './SFSerialExport.txt')

      begin
        ActiveRecord::Base.transaction do
          get_namespaces

          CSV.foreach(args[:data_directory],
                      headers: true,
                      return_headers: false,
                      encoding: 'UTF-16LE:UTF-8',
                      col_sep: "\t",
                      quote_char: '|'
          ) do |row|

            # TODO convert row to a hash & reference by column name not order to make it more generic

            data_attr = []
            if !(row[7].to_s.strip.blank?) # test for empty note!
              # notes.push({text: row[15].to_s.strip})
              data_attr.push({predicate: @serial_note, value: row[15].to_s.strip, type: 'InternalAttribute'})
            end

            identifiers=[]
            # Import ID - never empty
            identifiers.push({type: 'Identifier::Local::Import',
                              namespace: @import_serial_namespace,
                              identifier: row[0].to_s.strip
            })

            identifiers.push(
              {type: 'Identifier::Global::Issn',
               identifier: row[8].to_s.strip}
            ) if !row[8].to_s.strip.blank?

            r = Serial.new(
              name: row[1].to_s.strip,
              publisher: row[3].to_s.strip,
              place_published: row[4].to_s.strip,
              first_year_of_issue: row[5],
              last_year_of_issue: row[6],
              identifiers_attributes: identifiers,
              data_attributes_attributes: data_attr
            )

            if r.valid?
              r.save!
            else
              puts ['error:', ap(r)].join(" : ")
              puts ap(r.identifiers)
              next
            end

            if row[1] != row[2]
              # add short name (alternate name)
              r.alternate_values << AlternateValue.new(
                value: row[2].to_s.strip,
                alternate_value_object_attribute: 'name',
                type: 'AlternateValue::Abbreviation'
              )
            end

            r.save! 

          end  # transaction end
          puts 'Success'
          raise # causes it to always fail and rollback the transaction
        end
      rescue
        raise
      end

    end # task
  end
end
end
