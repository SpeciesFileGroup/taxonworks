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

      @filenames.each_with_index do |name, file_index|
        objects_in_file = {}
        objects_in_file[:sequence] = []

        sequence_attributes = { name: nil, sequence_type: nil, sequence: nil }
        file_content = @file_contents[file_index]

        new_line_index = file_content.index("\n") # Double quotes are needed to properly interpret new line character
        #sequence_attributes[:name] = file_content[1...file_content.index(' ')]
        sequence_attributes[:sequence_type] = "DNA"
        sequence_attributes[:sequence] = file_content[(new_line_index + 1)...(file_content.length - 1)]

        # ap file_content
        # ap sequence_attributes

        sequence = Sequence.new(sequence_attributes)
        objects_in_file[:sequence].push(sequence)

        @processed_files[:names].push(name)
        @processed_files[:objects].push(objects_in_file)
      end
    end
  end
end