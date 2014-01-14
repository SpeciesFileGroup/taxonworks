require 'fileutils'

namespace :tw do
  namespace :project_import do
    namespace :ucd do 

      desc 'the full loop' 
      task :import_ucd => [:data_directory, :environment] do |t, args| 
        puts @args
      end

      desc 'a default method to argmuments'
      task  :data_directory, [:data_directory] => :environment do |t, args| 
        @args = args.with_defaults(:data_directory => '/Users/matt/src/sf/import/ucd/csv/')
      end

      desc 'reconcile colls'
      task :reconcile_colls => [:data_directory, :environment] do |t, args| 
        path = @args[:data_directory] + 'coll.csv'
        raise 'file not found' if not File.exists?(path)

        f = CSV.open(path, col_sep: "\t", quote_char: "|")
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

      desc 'handle refs - rake tw:project_import:ucd:handle_refs[/Users/matt/src/sf/import/ucd/csv]'
      task :handle_refs => [:data_directory, :environment] do |t, args| 
        # 0   RefCode   | varchar(15)  |
        # 1   Author    | varchar(52)  |
        # 2   Year      | varchar(4)   |
        # 3   Letter    | varchar(2)   | # key/value - if they want to maintain a manual system let them
        # 4   PubDate   | date         |
        # 5   Title     | varchar(188) |
        # 6   JourBook  | varchar(110) |
        # 7   Volume    | varchar(20)  |
        # 8   Pages     | varchar(36)  |
        # 9   Location  | varchar(27)  | # Attribute::Internal
        # 10  Source    | varchar(28)  | # Attribute::Internal
        # 11  Check     | varchar(11)  | # Attribute::Internal
        # 12  ChalcFam  | varchar(20)  | # Attribute::Internal a key/value (memory aid of john)
        # 13  KeywordA  | varchar(2)   | # Citation 
        # 14  KeywordB  | varchar(2)   | # Citation 
        # 15  KeywordC  | varchar(2)   | # Citation 
        # 16  LanguageA | varchar(2)   | 
        # 17  LanguageB | varchar(2)   |
        # 18  LanguageC | varchar(2)   |  
        # 19  M_Y       | varchar(1)   | # Attribute::Internal fuzziness on month/day/year - an annotation
        # 20  PDF_file  | varchar(1)   | # location
  
        path1 = @args[:data_directory] + 'refs.csv'
        path2 = @args[:data_directory] + 'refext.csv'
        raise 'file not found' if not File.exists?(path1)
        raise 'file not found' if not File.exists?(path2)
    
        f = CSV.open(path1, col_sep: "\t")
        fext = CSV.open(path2, col_sep: "\t")

        keywords = { }

        i = 0 
        f.each do |row|

          year, month, day = row[4].split('-') 
          
          

          b = Source::Bibtex.new(
            author: row[1],
            year: year ? year.to_i : row[2],
            stated_year: row[4], # TODO: Verify
            title: row[5],
            booktitle: row[6],   # TODO: Should also be journal (?)
            volume: row[7],
            pages: row[8],
            bibtex_type: 'article',    # TODO
          )
          puts row
          i+=1
          break if i > 10
        end
      end

      task :sql_dump_script do
        %w{coll country dist famtrib fgnames genus h-fam hknew hostfam hosts journals keywords language master p-type refext refs relation reliable species status tran tstat wwwimaok}.each do |t|
          puts "SELECT * FROM `#{t}` INTO OUTFILE '/tmp/ucd/#{t}.csv' 
        FIELDS TERMINATED BY '\\t'
        LINES TERMINATED BY '\\n';"
          # ENCLOSED BY '|' # Ruby CSV is borked, to be fixed in 2.1
        end
      end

    end
  end
end



