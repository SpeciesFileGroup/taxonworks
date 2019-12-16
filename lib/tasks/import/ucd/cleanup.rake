require 'fileutils'
require 'awesome_print'

# COLL.txt          Done
# COUNTRY.txt       Done
# DIST.txt          Most of the areas do not match TW areas
# FAMTRIB.txt       Done
# FGNAMES.txt       Done
# GENUS.txt         Done
# H-FAM.txt         Done
# HKNEW.txt         Done
# HOSTFAM.txt       Done
# HOSTS.txt         Done
# JOURNALS.txt      not needed
# KEYWORDS.txt      Done
# LANGUAGE.txt      Done
# MASTER.txt        Done
# P-TYPE.txt        Done
# REFEXT.txt        Done
# RELATION.txt      Done
# RELIABLE.txt      Done
# SPECIES.txt       Done
# STATUS.txt        Done
# TRAN.txt          not needed
# TSTAT.txt         Done
# WWWIMAOK.txt      image related

namespace :tw do
  namespace :project_import do
    namespace :ucd do

      # https://github.com/chalcid/jncdb/issues/18
      task cleanup_identifiers: [:environment, :user_id, :project_id ] do
        begin
          j = 0
          n = nil
          errors = []
          Identifier::Local::Import.where(identifier_object_type: 'Source', project_id: Current.project_id).each do |i|
            o = i.identifier_object
            s = o.year_suffix
            l = s.length if s

            if l  
              n = i.identifier[0..((l + 1) * -1)]
            end 

            case o.year_suffix
            when nil
              next 
            when 'a'
              if i.identifier =~ /a$/ 
                puts Rainbow( o.year_suffix + ' - ' + i.identifier + ' : ' + n).purple
                # i.update!(identifier: n)
              end
            else
              if i.identifier =~ /#{s[0]}{#{l}}$/ 
                n = i.identifier[0..-2]
                t = o.year_suffix + ' - ' + i.identifier + ' : ' + n
                if s.length > 1 
                  puts Rainbow(t ).yellow
                  errors << n # i.identifier
                else
                  puts Rainbow(t ).purple
                end
                # i.update!(identifier: n)
              end
            end

            j += 1
          end
        rescue ActiveRecord::RecordInvalid
          puts Rainbow("failed to save #{n}").red
        end
        puts '----'
        puts errors.collect{|e| "* [ ] #{e}"}.join("\n")
      end

      # https://github.com/chalcid/jncdb/issues/9
      task cleanup_italics_in_source_titles: [:data_directory, :environment, :user_id, :project_id ] do
      end

      task cleanup_host_based_otus: [:data_directory, :environment, :user_id, :project_id ] do
      end

      task cleanup_geographic_area_based_otus: [:data_directory, :environment, :user_id, :project_id ] do
      end

      task add_pdfs: [:data_directory, :environment, :user_id, :project_id ] do
        i = 0
        @user = User.find(Current.user_id)
        begin
          Dir["#{@args[:data_directory]}/*.*"].each do |f|
            n = f.split('/').last.split('.').first
            if s = Identifier::Local::Import.where(namespace_id: 35, identifier: n).first
              if o = s.identifier_object
                if o.type == 'Source::Bibtex' 
                  if o.type == 'Source::Bibtex' && o.documents.size > 0
                    puts Rainbow("#{n} has pdf").yellow 
                  else
                    d = Documentation.new(
                      by: Current.user_id,
                      project: Current.project_id,
                      document_attributes: {
                        by: @user,
                        project: project_id,
                        document_file: File.open(f) 
                      }, documentation_object: o
                    )

                    d.save!
                    puts "Wrote #{n}"
                  end
                else
                  puts Rainbow("#{n} identifier is not a Source!!").red
                  next  
                end
              end
            else
              puts Rainbow("#{n} NOT FOUND").red
            end

            i +=1
            break if i > 19
          end

        rescue ActiveRecord::RecordInvalid
          puts "died at #{i}"
          raise
        end
      end

    end
  end
end
