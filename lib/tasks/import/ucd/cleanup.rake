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

          Identifier::Local::Import.where(identifier_object_type: 'Source', project_id: Current.project_id).find_each do |i|
            o = i.identifier_object
            
            next if o.year_suffix.nil?

            stripped_identifier = nil
            parts = i.identifier.split(/\d+/)
            year = i.identifier.match(/\d+/).to_s

            stripped_identifier = parts[0] + year
            current_suffix = parts.size == 2 ? parts[1] : '' 

            print Rainbow( o.year_suffix + ' / ' + current_suffix +  ' : ').purple
            print Rainbow(i.identifier).red
            print ' : ' 
            print Rainbow(stripped_identifier).yellow
            print ' : '   

            new_identifier = stripped_identifier + o.year_suffix

            if ((current_suffix == o.year_suffix) && (current_suffix != 'a')) || ( (o.year_suffix == 'a') && (stripped_identifier == i.identifier))
              e = "#{i.identifier} is current"
              puts Rainbow(e).gray
              
              # First pass uncomment
              # errors.push e + ' (may be an error)'
              next
            end

            case o.year_suffix
            when 'a'
              new_identifier = stripped_identifier
            else
              new_identifier = stripped_identifier + o.year_suffix
            end

            print Rainbow(new_identifier).green
            print "\n"

            i.update(identifier: new_identifier)

            # Second pass uncomment
            # errors.push "* [] odd format #{i.identifier}"
            j += 1
          end
        rescue ActiveRecord::RecordInvalid => e
          a = "failed to save #{i.id} - #{e.error}"
          errors.push a
          puts Rainbow(a).red
        end
      
        t = Identifier::Local::Import.where(identifier_object_type: 'Source', project_id: Current.project_id).all.count 
        puts Rainbow("Done. Updated #{j} of #{t} records.").gold

        puts '----'
        puts errors.collect{|e| "* [ ] #{e}"}.join("\n")
      end

      def pipes_to_i(string)
        s = ''
        open = true
        string.scan(/./).each do |l|
          if l == '|'
            s << (open ? '<i>' : '</i>')
            open = !open
          else
            s << l
          end
        end
        s
      end

      # https://github.com/chalcid/jncdb/issues/9 + 
      #  rake tw:project_import:ucd:cleanup_italics_in_source_titles project_id=16 user_id=1 
      task cleanup_italics_in_source_titles: [:environment, :user_id, :project_id ] do
        errors = []
        begin
          Source.joins(:project_sources).where(project_sources: {project_id: Current.project_id}).where("title ilike '%|%'").find_each do |s|
            errors.push("#{s.id} : #{s.title}") if (s.title.scan('|').count % 2) != 0
            # puts Rainbow(s.title).red
            a = pipes_to_i(s.title)
            # puts Rainbow(a).green

            s.update(title: a)
          end
        rescue ActiveRecord::RecordInvalid => e
          errors.push "#{s.id} - invalid title after translate"
        end

        puts
        print "----\n* [ ] "
        puts errors.join("\n* [ ] ")
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
