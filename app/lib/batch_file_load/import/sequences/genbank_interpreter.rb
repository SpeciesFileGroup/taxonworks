module BatchFileLoad
  class Import::Sequences::GenbankInterpreter < BatchFileLoad::Import
    include BatchLoad::Helpers::Sequences

    # @param [Array] args
    def initialize(**args)
      super(**args)
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
    &vDRMDNA1299_&gCOI_&fCOIBC_&pPUB019_&aKJ624355_&nBembidion obliquulum.fas

    Things to be done with each file
      - Link Sequence to Extract with matching CollectionObject identifier in namespace DRMDNA with OriginRelationship
      - Attach identifier Sequence in namespace GenBank with value of the accession number

      nested attributes!
=end
    # @return [Array]
    def build
      return if !valid?
      @processed = true

      @filenames.each_with_index do |filename, file_index|
        objects_in_file = {}
        objects_in_file[:sequence] = []
        objects_in_file[:origin_relationship] = []

        sequence = create_sequence(filename, @file_contents[file_index])
        objects_in_file[:sequence].push(sequence)

        origin_relationship = create_origin_relationship(filename, sequence)
        objects_in_file[:origin_relationship].push(origin_relationship) if origin_relationship

        @processed_files[:names].push(filename)
        @processed_files[:objects].push(objects_in_file)
      end
    end
  end
end
