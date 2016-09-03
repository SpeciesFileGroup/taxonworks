module BatchFileLoad
  class Import::Sequences::GenbankInterpreter < BatchFileLoad::Import
    def initialize(**args)
      super(args)
    end

=begin
    Sequences
    &v = begginning file name
    g, ,f, p, a, n, follow _& 

    V = voucher number ex DRMDNA1408: LINK To Extract with matching CollectionObject identifier namespace DRMDNA
    G = gene code name
    F = gene fragement: ignore 
    P = publication within internal: ignore
    A = accession number, genbank code, IDENTIFIER: ATTACH Sequence identifier namespace GenBank
    N = human readable name: ignore 

    ex
    &vDRMDNA1299_&gCOI_&fCOIBC_&pPUB019_&aKJ624355_&nBembidion obliquulum

    Things to be done with each file
      - Link Sequence to Extract with matching CollectionObject identifier in namespace DRMDNA with OriginRelationship
      - Attach identifier Sequence in namespace GenBank with value of the accession number

      nested attributes!
=end
    def build
      return if !valid?
      @processed = true

      # GenBank GBK
      namespace_genbank = Namespace.find_by(name: 'GenBank')

      @filenames.each_with_index do |name, file_index|
        objects_in_file = {}
        objects_in_file[:sequence] = []

        # Sequence attributes
        sequence_attributes = { name: nil, sequence_type: nil, sequence: nil, identifiers_attributes: [] }
        file_content = @file_contents[file_index]

        new_line_index = file_content.index("\n") # Double quotes are needed to properly interpret new line character
        #sequence_attributes[:name] = file_content[1...file_content.index(' ')]
        sequence_attributes[:sequence_type] = "DNA"
        sequence_attributes[:sequence] = file_content[(new_line_index + 1)...(file_content.length - 1)]

        # Identifiers 
        sequence_identifier_genbank_text = get_genbank_text(name)
        

        sequence_identifier_genbank = { namespace: namespace_genbank,
                                       type: 'Identifier::Local::Sequence',
                                       identifier: sequence_identifier_genbank_text }

        sequence_attributes[:identifiers_attributes].push(sequence_identifier_genbank) if !sequence_identifier_genbank_text.blank?
        ap sequence_identifier_genbank
        sequence = Sequence.new(sequence_attributes)
        objects_in_file[:sequence].push(sequence)

        @processed_files[:names].push(name)
        @processed_files[:objects].push(objects_in_file)
      end
    end

    private

    def get_genbank_text(filename)
      # _&aKJ624355_&
      genbank_pattern = "_&a"
      beg_genbank_text_index = filename.index(genbank_pattern)
      
      if beg_genbank_text_index
        beg_genbank_text_index += genbank_pattern.length
        end_genbank_text_index = filename.index("_&", beg_genbank_text_index)
        return filename[beg_genbank_text_index...end_genbank_text_index]
      end

      return ""
    end
  end
end