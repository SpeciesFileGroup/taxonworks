# Questions for Heraty
#  - what is PTYGENUS in Genus table


require 'fileutils'

# /Users/matt/src/sf/import/eucharitid/data/original/eucharitid

# BA_ASSO.txt
# BA_CITS.txt
# BA_DIST.txt
# BA_GEN.txt
# BA_HOST.txt
# BA_KEYS.txt
# BA_NAMES.txt
# BA_REF.txt
# BA_REMK.txt
# BA_SPE.txt


# BA_ASSO: VGENUS, VSPECIES, VSUBSP, AVGENUS, AVSPECIES, AVSUBSP, AVAUTHOR, AORDER, AFAMILY, ARELATN, ARELTYPE, AACTIONAB, AACTIONBA, ASITE, AIDQUEST, VALIDATN, ANOTESP, ANOTESF, NEWRECORD, ACODENO
# BA_CITS: VGENUS, VSUBGN, VSPECIES, VSUBSP, CCITNO, CKEYWORDS, CPAGES, CCITOUT, CREFOUT, CNOTESF, CATTAG
# BA_DIST: VGENUS, VSPECIES, VSUBSP, DREGION, DCOUNTRY, DCTRYDEF, INTRO_CTRY, INTRO_STPR, DSTPROV, DSTPROVDEF, DISTFILED, VALIDATN, NEWRECORD
# BA_KEYS: VGENUS, VSUBGN, VSPECIES, VSUBSP, KYAUTHOR, KYYEAR, KYLETTER, KYAS, KYPAGES, KYSTAGE, KYCOVERAGE, KYMEMO
# BA_REMK: VGENUS, VSUBGN, VSPECIES, VSUBSP, REM_NOTES1, REM_NOTES2, REM_NOTES3, REM_NOTES4, REM_NOTES5

# BA_GEN: OGENUS, OSUBGN, GNAUTH, GNYEAR, GNLET, GNPAGE, GNSTATUS, HOMO_REPL, STAUTH, STYEAR, STLET, STPAGE, VGENUS, VSUBGN, SUBFAM, TRIBE, SUBTRIBE, PTYGEN, PTYSUBGN, PTYSP, PROPTYAUTH, JUNSYN, VTYGEN, VTYSP, VALTYAUTH, TYSPDE, DEAUTH, DEYEAR, DELET, DEPAGE, NOTESP, NOTESF
# BA_SPE: OGENUS, OSUBGN, OSPECIES, OSUBSP, SPAUTH, SPYEAR, SPLET, SPPAGE, TYPE, TYSEX, TYDES, SQAUTH, SQYEAR, SQLET, SQPAGE, TYLOCAL, TYCOLL, VGENUS, VSUBGN, VSPECIES, VSUBSP, SPSTATUS, HOMO_REPL, STAUTH, STYEAR, STLET, STPAGE, TYNO, TYSEEN, FORM_DESC, SPFIGS, OREF, NOTESP, NOTESF

namespace :tw do
  namespace :project_import do
    namespace :eucharitid do

      desc 'the full import for eucharitids' 
      # rake tw:project_import:eucharitid:import_eucharitid data_directory=/Users/matt/src/sf/import/eucharitid/data/original/eucharitid/ 
      task :import_eucharitid => [:data_directory, :environment] do |t, args| 
        puts @args

        ActiveRecord::Base.transaction do 
          begin
            @project, @user = initiate_project_and_users('eucharitid', 'John Heraty')
            #           @namespace = Namespace.new(name: 'eucharitid', short_name: 'eucharitid')
            #           @namespace.save!

            #        Rake::Task["tw:project_import:eucharitid:inspect_original_files"].execute

            @ref_index = {} 
            Rake::Task["tw:project_import:eucharitid:build_sources"].execute

            puts ap(@ref_index)


            Rake::Task["tw:project_import:eucharitid:build_higher_classification"].execute
            Rake::Task["tw:project_import:eucharitid:handle_genera"].execute

            puts "\n\n !! Success \n\n"
            raise
          rescue
            raise
          end
        end
      end

      desc 'inspecting original data'
      task :inspect_original_files => [:data_directory, :environment] do |t, args| 
        files = %w{
          BA_ASSO
          BA_CITS
          BA_DIST
          BA_GEN
          BA_HOST
          BA_KEYS
          BA_NAMES
          BA_REF
          BA_REMK
          BA_SPE
        }

        files.each do |file|
          path = @args[:data_directory] + file  + '.txt'
          raise "file #{path} not found" if not File.exists?(path)

          f = CSV.open(path,  :encoding => 'utf-16', col_sep: "\t", headers: true ) # was le

          if f.count > 1
            puts (file + ": " + f.headers.join(", ") + "\n") 
          end

          #f.each do |row|
          #  puts row.to_s
          #end
          f.close
        end
      end

      task :build_sources => [:data_directory, :environment] do |t, args| 
        index = {
        }

        path = @args[:data_directory] + 'BA_REF.txt'
        raise "file #{path} not found" if not File.exists?(path)

        # BA_REF: RFBOOKPP, RFSUMMARY, RFREPRINT, ENTERED, RFNOTESP, RFNOTESF 

        # TODO: add as import_attributes
        #   RFDATE  => not worth parsing the differences in this mixed bag

        # add as identifier
        # RFCITNO (already indexed)

        # RFBOOK 
        # RFTIT
        #
        # RFVOLPG
        # RFLET*
        # RFPP*
        # RFAUTH
        # RFEDITOR
        # RFTYPE
        # RFEDITION
        # RFJOUR
        # RFPUBLISHR
        # RFLANGUAGE
        # RFCITY
        # RFYRPUBL
        # RFYRPRINT

        f = CSV.open(path, :encoding => 'utf-16', col_sep: "\t", headers: true ) # was le
        invalid = []
        all = []
        volp = []
        book = []
        dates = []
        book_pp = []

        f.each do |row|
          puts row['RFCITNO']
          dates.push([row['RFYRPUBL'], row['RFDATE'], row['RFYRPRINT']    ])
          book.push row['RFBOOK']
          book_pp.push [ row['RFBOOKPP'], row['RFPP']]

          # Swap years if there is a print/publish difference
          year = row['RFYRPUBL']
          state_year = nil
          if row['RFYRPRINT']
            stated_year = year
            year =  row['RFYRPRINT']
          end

          # Handle volumes/pages
          if row['RFVOLPG'] =~ /(\d+)\s*:(\s+\d+\-\d+)\./
            volume = $1
            pages = $2
          else
            pages = row['RFVOLPG']
          end 
          pages ||= row['RFPP']
          pages.gsub(/\./, '') if !pages.nil? # strip the .

          volp.push([ pages, row['RFVOLPG'] ] ) if row['RFPP']

          # handle bibtex type
          type = nil
          case row['RFTYPE']
          when '1'
            type = 'article'
          when '2'
            type = 'book'
          else
            raise row['RFTYPE']
          end

         s = Source::Bibtex.create(
                                   address: row['RFCITY'], 
                                   pages: pages,
                                   bibtex_type: type,
                                   title: row['RFTIT'],
                                   author: row['RFAUTH'],
                                   year: year,
                                   stated_year: stated_year,
                                   volume: volume,
                                   year_suffix: row['RFLET'],
                                   editor: row['RFEDITOR'],
                                   booktitle: row['RFBOOK'],
                                   edition: row['RFEDITION'],
                                   journal: row['RFJOUR'],
                                   publisher: row['RFPUBLISHR'],
                                   language: row['RFLANGUAGE'],
                                  )
         if s.invalid?
           push invalid s  
         else
           all.push s
           @ref_index.merge!(row['RFCITNO'] => s)
         end

        end
      #  ap volp.compact.uniq
      #  ap invalid
      #  ap book.compact.uniq

       #puts "DATES"
       #ap dates
        
       # puts 'BOOK PP'
       # ap book_pp
        f.close
      end

      task :build_higher_classification => [:data_directory, :environment] do |t, args|
        path = @args[:data_directory] + 'BA_GEN.txt'
        raise "file #{path} not found" if not File.exists?(path)
        root = TaxonName.create(name: 'Root', parent_id: nil, rank_class: 'NomenclaturalRank')
        eucharitidae = TaxonName.create(name: 'Eucharitidae', parent: root, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family')

        eurytomidae = TaxonName.create(name: 'Eurytomidae', parent: root, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family')

        f = CSV.open(path,  :encoding => 'utf-16', col_sep: "\t", headers: true ) 
        higher = []
        subfams = []
        tribes = []
        f.each do |row|
          higher.push([row['SUBFAM'], row['TRIBE'], row['SUBTRIBE']])
          higher.uniq!
          subfams.push(row['SUBFAM'])
          tribes.push(row['TRIBE'])
        end 

        higher.each do |subfam, tribe, subtribe|
          s = TaxonName.find_or_create_by(name: subfam, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Subfamily', parent_id: eucharitidae.to_param)
#         byebug if !subfam.valid?
          t = TaxonName.find_or_create_by(name: tribe, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Tribe', parent_id: s.id) if !s.nil? && !tribe.nil?
          # there are no tribes! 
        end

        puts TaxonName.all

        ap higher
        ap subfams.uniq
        ap tribes.uniq 
      end

      task :handle_genera => [:data_directory, :environment] do |t, args|
        path = @args[:data_directory] + 'BA_GEN.txt'
        raise "file #{path} not found" if not File.exists?(path)

        codes = {} 

        aa_records = []

        f = CSV.open(path,  :encoding => 'utf-16', col_sep: "\t", headers: true ) 

        invalid = []

        av_rels = {
          "EU" => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation', 
          "HJ" => 'TaxonNameRelationship::Iczn::Invalidating::Homonym',
        }
        av_stats_2_classifications = {
          "AV" => nil, # - accepted valid name (nothing to add)
          "IS" => nil,
          "LC" => nil,
          "MG" => nil,
          "MI" => nil,
          "PR" => nil,
          "RH" => nil 
          "RN" => nil,
          "SD" => nil,
          "SH" => nil,
          "SJ" => nil,
          "SN" => nil,
          "SU" => nil,
          "TR" => nil,
        }

        f.each do |row|

          codes.merge!(row['GNSTATUS'] => nil)

          authors = row['GNAUTH'].gsub(/\sand\s|&|,/, "!").split('!')
          citation_code = authors[0][0..5].strip
          authors[1..authors.length].each do |a|
            a.strip!
            citation_code += a[0..1]
          end 

          citation_code += (row['GNYEAR'].to_s + row['GNLET'].to_s )
          citation_code.gsub!(/[\[\]]/, '')

          puts citation_code
          puts "!! not found" if !@ref_index[citation_code]

          # Handle valid genera
          if !(row['VGENUS'] =~ /Aa/i) 

            if row['GNSTATUS'] == "AV"
              parent_name = [ row['TRIBE'], row['SUBTRIBE'], row['SUBFAM'] ].compact.first
              parent = TaxonName.where(name: parent_name).first

              t = TaxonName.create(
                name: row['OGENUS'],
                parent: parent,  # make more explicit to get this right
                year_of_publication: row['GNYEAR'],
                verbatim_author: row['GNAUTH'],
                rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus'
              )

              invalid.push [t.valid?, row['OGENUS'], parent_name] if !t.valid?
            end
          end 

         #  aa_records.push([row['OGENUS'], row['VGENUS']]) if 
        end

        puts "INVALID AV GENUS RECORDS:"
        ap invalid

        ap codes

        # ap aa_records.uniq!
      end 

    end
  end
end



