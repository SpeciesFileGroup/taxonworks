require 'fileutils'

namespace :tw do
  namespace :project_import do
    namespace :ucd do 
      desc 'a default method to argmuments'
      task  :data_directory, [:data_directory] => :environment do |t, args| 
        @args = args.with_defaults(:data_directory => '/Users/matt/src/sf/import/ucd/csv/')
      end

      desc 'the full loop' 
      task :import_ucd => [:data_directory, :environment] do |t, args| 
        puts @args

        ActiveRecord::Base.transaction do 
          begin
            @project, @user = initiate_project_and_users
            @namespace = Namespace.new(name: 'UCD', short_name: 'UCD')
            @namespace.save!

            Rake::Task["tw:project_import:ucd:handle_keywords"].execute
            Rake::Task["tw:project_import:ucd:handle_refs"].execute

            puts "\n\n !! Success \n\n"
            raise
          rescue
            raise
          end
        end
      end

      def initiate_project_and_users
        @project = FactoryGirl.create(:valid_project, name: 'UCD') 
        @user = FactoryGirl.create(:user, email: 'john@bm.org', password: '3242341aas', password_confirmation: '3242341aas')
        $project_id = @project.id
        $user_id = @user.id
        return @project, @user
      end      

      desc 'reconcile colls'
      task :reconcile_colls => [:data_directory, :environment] do |t, args| 
        path = @args[:data_directory] + 'coll.csv'
        raise 'file not found' if not File.exists?(path)

        f = CSV.open(path, col_sep: "\t")
        f.each do |row|
          if r = Repository.where(acronym: row[0]).first
            # puts r.id
          else
            print "#{row[0]}\t#{row[1]}\n" if not  Repository.where(acronym: "#{row[0]}\<IH\>").first
          end
        end

        f.close
      end

      desc 'reconcile language'
      task :reconcile_languages => [:data_directory, :environment] do |t, args| 
        path = @args[:data_directory] + 'language.csv'
        raise 'file not found' if not File.exists?(path)

        f = CSV.open(path, col_sep: "\t")
        f.each do |row|
          if r = Language.where(alpha_2: row[0]).first
            # puts r.id
          else
            print "#{row[0]}\t#{row[1]}\n" 
          end
        end
        f.close
      end

      def fix_line(line)
        line.gsub(/\t\\N\t/, "\t\"NULL\"\t").gsub(/\\"/, '""') # .gsub(/\t/, '|')
      end

      def column_values(fixed_line)
        CSV.parse(fixed_line, col_sep: "\t").first
      end

      desc 'reconcile Refs::Chalcfam (look for unique values'
      task :reconcile_refs_chalcfam => [:data_directory, :environment] do |t, args| 
        path = @args[:data_directory] + 'refs.csv'

        raise 'file not found' if not File.exists?(path)

        # f = CSV.open(path, col_sep: "\t")
        families = {}

        # This pattern handles quotes/escaping crap MySQL export
        File.foreach(path) do |csv_line| 
          row = column_values(fix_line(csv_line))

          if row[12]
            v = row[12].strip
            r = nil             
            if v  =~ /\s/
              r = Regexp.new(/\s/)
            else
              r = Regexp.new(/(?=[A-Z])/)
            end

            row[12].split(r).inject(families){|hsh, v| hsh.merge!(v => nil)} 
          end
        end

        print families.keys.sort.join(", ")
        # f.close
      end


      desc 'handle_famtrib - rake tw:project_import:ucd:handle_famtrib[/Users/matt/src/sf/import/ucd/csv]'
      task :handle_keywords => [:data_directory, :environment] do |t, args| 
        # 1  TaxonCode  
        # 2  RefCode    
        # 3  PageRef    
        # 4  H_levelTax 
        # 5  Of_for_to  
        # 6  Status     
        # 7  CitGenus   
        # 8  CitAuthor  
        # 9  Code       
        # 10 Notes      
      end

      desc 'handle keywords - rake tw:project_import:ucd:handle_keyowrds[/Users/matt/src/sf/import/ucd/csv]'
      task :handle_keywords => [:data_directory, :environment] do |t, args| 
        # 0  Keywords
        # 1  Meaning
        # 2  Category

        path = @args[:data_directory] + 'keywords.csv'
        f = CSV.open(path, col_sep: "\t")
        keywords = []
        abbreviations = [] 
        tags = []

        meta_keywords = {
          '1' => Keyword.new(name: 'Taxonomic Keyword in UCD', definition: 'The Topic categorized by Noyes as being taxonomic (1 in UCD).'),
          '2' => Keyword.new(name: 'Biological Keyword in UCD', definition: 'The Topic categorized by Noyes as being biological (2 in UCD).'),
          '3' => Keyword.new(name: 'Economic Keyword in UCD Keyword', definition: 'The Topic categorized by Noyes as being economic (3 in UCD).')
        }
        f.each do |row|
          t = Keyword.new(name: row[1], definition: "The topic derived from the UCD keyword for #{row[1]}.") 
          keywords.push t
          abbreviations.push AlternateValue::Abbreviation.new(alternate_object: t, value: row[0], alternate_object_attribute: :name)
          tags.push Tag.new(keyword: meta_keywords[row[2]], tag_object: t) 
        end

        Topic.transaction do 
          [meta_keywords.values, keywords, abbreviations, tags].each do |objs|
            objs.each do |o|
              o.save!
            end
          end

          # puts keyowrds.map(&:valid?), abbreviations.map(&:valid?), tags.map(&:valid?), meta_keywords.values
        end 
      end

      desc 'handle refs - rake tw:project_import:ucd:handle_refs[/Users/matt/src/sf/import/ucd/csv]'
      task :handle_refs => [:data_directory, :environment, :handle_keywords] do |t, args| 
        # 0   RefCode   | varchar(15)  |
        # - 1   Author    | varchar(52)  |
        # - 2   Year      | varchar(4)   |
        # - 3   Letter    | varchar(2)   | # ?! key/value - if they want to maintain a manual system let them
        # - 4   PubDate   | date         |
        # - 5   Title     | varchar(188) |
        # - 6   JourBook  | varchar(110) |
        # - 7   Volume    | varchar(20)  |
        # - 8   Pages     | varchar(36)  |
        # - 9   Location  | varchar(27)  | # Attribute::Internal
        # - 10  Source    | varchar(28)  | # Attribute::Internal
        # - 11  Check     | varchar(11)  | # Attribute::Internal
        # 12  ChalcFam  | varchar(20)  | # Attribute::Internal a key/value (memory aid of john)
        # - 13  KeywordA  | varchar(2)   | # Tag 
        # - 14  KeywordB  | varchar(2)   | # Tag 
        # - 15  KeywordC  | varchar(2)   | # Tag 
        # - 16  LanguageA | varchar(2)   | Attribute::Internal & Language
        # - 17  LanguageB | varchar(2)   | Attribute::Internal
        # - 18  LanguageC | varchar(2)   | Attribute::Internal 
        # - 19  M_Y       | varchar(1)   | # Attribute::Internal fuzziness on month/day/year - an annotation
        # 20  PDF_file  | varchar(1)   | # [X or Y] TODO: NOT HANDLED

        # 0 RefCode   
        # - 1 Translate 
        # - 2 Notes     
        # - 3 Publisher 
        # 4 ExtAuthor 
        # 5 ExtTitle  
        # 6 ExtJournal
        # 7 Editor    

        path1 = @args[:data_directory] + 'refs.csv'
        path2 = @args[:data_directory] + 'refext.csv'
        raise 'file not found' if not File.exists?(path1)
        raise 'file not found' if not File.exists?(path2)

        f = CSV.open(path1, col_sep: "\t")
        # fext = CSV.open(path2, col_sep: "\t")

        fext_data = {}
        
        File.foreach(path2) do |csv_line| 
          r = column_values(fix_line(csv_line))
          fext_data.merge!(
            r[0] => { translate: r[1], notes: r[2], publisher: r[3], ext_author: r[4], ext_title: r[5], ext_journal: r[6], editor: r[7] }
          )
        end

        namespace = Namespace.new(name: 'UCD refCode', short_name: 'UCDabc')
        namespace.save!

        sources = []
        attributes = []
        tags = [] 
        identifiers = []
        notes = []

        keywords = {
          'Refs:Location' => Predicate.new(name: 'Refs::Location', definition: 'The verbatim value in Ref#location.'),
          'Refs:Source' => Predicate.new(name: 'Refs::Source', definition: 'The verbatim value in Ref#source.'),
          'Refs:Check' => Predicate.new(name: 'Refs::Check', definition: 'The verbatim value in Ref#check.'),

          'Refs:LanguageA' => Predicate.new(name: 'Refs::LanguageA', definition: 'The verbatim value in Refs#LanguageA'),
          'Refs:LanguageB' => Predicate.new(name: 'Refs::LanguageB', definition: 'The verbatim value in Refs#LanguageB'),
          'Refs:LanguageC' => Predicate.new(name: 'Refs::LanguageC', definition: 'The verbatim value in Refs#LanguageC'),

          'Refs:M_Y' => Predicate.new(name: 'Refs::M_Y', definition: 'The verbatim value in Refs#M_Y.'),
          'Refs:PDF_file' => Predicate.new(name: 'Refs::PDF_file', definition: 'The verbatim value in Refs#PDF_file.'),
          'RefsExt:Translate' => Predicate.new(name: 'RefsExt::Translate', definition: 'The verbatim value in RefsExt#Translate.'),
        }

        i = 0 

        File.foreach(path1) do |csv_line| 
          row = column_values(fix_line(csv_line))

          year, month, day = nil, nil, nil
          if row[4] != 'NULL'
            year, month, day = row[4].split('-', 3) 
            month = Utilities::Dates::SHORT_MONTH_FILTER[month]
            month = month.to_s if !month.nil?
          end

          stated_year = row[2]
          if year.nil?
            year = stated_year 
            stated_year = nil
          end

          author = [row[5], (fext_data )].compact.join

          b = Source::Bibtex.new(
            author: row[1],
            year: (year.nil? ? nil : year.to_i),
            month: month, 
            day: (day.nil? ? nil : day.to_i) ,
            stated_year: stated_year,
            year_suffix: row[3],           
            title: row[5],                      
            booktitle: row[6],                  
            volume: row[7],                     
            pages: row[8],                      
            bibtex_type: 'article',            
            language: (row[16] ? Language.where(alpha_2: row[16] ).first : nil),
            publisher: (fext_data[row[0]] ? fext_data[row[0]][:publisher] : nil),
            editor: (fext_data[row[0]] ? fext_data[row[0]][:editor] : nil),
          )
          sources.push b

          identifiers.push Identifier::LocalId.new(namespace: namespace, identifier: row[0], identified_object: b)

          attributes.push DataAttribute::InternalAttribute.new( attribute_subject: b, predicate: keywords['Refs:Location'], value: row[9]) if row[9]
          attributes.push DataAttribute::InternalAttribute.new( attribute_subject: b, predicate: keywords['Refs:Source'], value: row[10]) if row[10]
          attributes.push DataAttribute::InternalAttribute.new( attribute_subject: b, predicate: keywords['Refs:Check'], value: row[11]) if row[11]
          attributes.push DataAttribute::InternalAttribute.new( attribute_subject: b, predicate: keywords['Refs:LanguageA'], value: row[16]) if row[16]
          attributes.push DataAttribute::InternalAttribute.new( attribute_subject: b, predicate: keywords['Refs:LanguageB'], value: row[17]) if row[17]
          attributes.push DataAttribute::InternalAttribute.new( attribute_subject: b, predicate: keywords['Refs:LanguageB'], value: row[18]) if row[18]
          attributes.push DataAttribute::InternalAttribute.new( attribute_subject: b, predicate: keywords['Refs:M_Y:tilde'], value: row[19]) if row[19]

          if fext_data[row[0]]
            attributes.push(DataAttribute::InternalAttribute.new( attribute_subject: b, predicate: keywords['RefsExt:Translate'], value: fext_data[row[0]][:translate])) if fext_data[row[0]][:translate]
            notes.push(Note.new(note_object: b, text: fext_data[row[0]][:note])) if !fext_data[row[0]][:note].nil?
          end

          [13,14,15].each do |i| 
            k =  Keyword.with_alternate_value_on(:name, row[i]).first
            if k 
              tags.push Tag.new(tag_object: b, keyword: k)
            end
          end

          i+=1
          break if i > 200
        end

        [keywords.values, sources, identifiers, notes, tags].each do |objs|
          objs.each do |o|
            puts o
            o.save!
          end
        end
      end

      task :sql_dump_script do
        puts 'SET NAMES utf8;'
        %w{coll country dist famtrib fgnames genus h-fam hknew hostfam hosts journals keywords language master p-type refext refs relation reliable species status tran tstat wwwimaok}.each do |t|
          puts "SELECT * FROM `#{t}` INTO OUTFILE '/tmp/ucd/#{t}.csv' 
        FIELDS 
          TERMINATED BY '\\t'
          OPTIONALLY ENCLOSED BY '\"'        
          ESCAPED BY '\\\\'
        LINES 
          TERMINATED BY '\\n';"
          # ENCLOSED BY '|' # Ruby CSV is borked, to be fixed in 2.1
          # Ruby CSV wants "" (two quotes) as an escaped quote by default) - so we need to convert with rows
        end
      end

    end
  end
end



