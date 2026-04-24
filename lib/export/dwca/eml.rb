# Terminology: there are some eml fields, like pubDate, that get populated at
# dwca creation time.
# * eml with those fields populated is 'actualized', otherwise it's
#   'unactualized'
# * Do *not* mark such fields with 'STUB'; that way we can tell which
#   non-auto-populated fields the user hasn't provided a value for.
module Export::Dwca::Eml

  # Nodes/values whose data must be filled in or deleted before public use.
  # !! You must also update .actualize_*_stub when you add a node here.
  EML_PARAMETERS = ['packageId'].freeze
  DATASET_PARAMETERS = ['alternateIdentifier', 'pubDate'].freeze
  ADDITIONAL_METADATA_PARAMETERS = ['dateStamp'].freeze

  def self.eml_template
    Nokogiri::XML::Builder.new(encoding: 'utf-8', namespace_inheritance: false) do |xml|
      xml['eml'].eml(
        'xmlns:eml' => 'eml://ecoinformatics.org/eml-2.1.1',
        'xmlns:dc' => 'http://purl.org/dc/terms/',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation' => 'eml://ecoinformatics.org/eml-2.1.1 http://rs.gbif.org/schema/eml-gbif-profile/1.1/eml-gbif-profile.xsd',
        'packageId' => 'STUB',
        'system' => 'https://taxonworks.org',
        'scope' => 'system',
        'xml:lang' => 'en'
      ) {
        xml.dataset
        xml.additionalMetadata
      }
    end
  end

  def self.actualized_eml_for(dataset, additional_metadata)
    doc = self.eml_for(dataset, additional_metadata)
    self.actualized_eml(doc)
  end

  def self.actualized_stub_eml
    self.actualized_eml(self.eml_stubbed)
  end

  def self.actualized_eml(doc)
    uuid = SecureRandom.uuid

    eml_node = doc.at_xpath(
      '//eml:eml', 'eml' => 'eml://ecoinformatics.org/eml-2.1.1'
    )
    EML_PARAMETERS.each do |p|
      eml_node[p] = self.actualize_eml_stub(p, uuid)
    end

    DATASET_PARAMETERS.each do |p|
      fragment = doc.at_xpath("//#{p}")
      if fragment # user may have deleted this parameter
        fragment.content = self.actualize_dataset_stub(p, uuid)
      end
    end

    ADDITIONAL_METADATA_PARAMETERS.each do |p|
      fragment = doc.at_xpath("//#{p}")
      if fragment # user may have deleted this parameter
        fragment.content = self.actualize_additional_metadata_stub(p, uuid)
      end
    end

    doc.to_xml
  end

  def self.actualize_eml_stub(parameter, uuid)
    case parameter
    when 'packageId'
      uuid
    else
      raise TaxonWorks::Error, "Unrecognized eml stub node '#{parameter}'!"
    end
  end

  def self.actualize_dataset_stub(parameter, uuid)
    case parameter
    when 'alternateIdentifier'
      uuid
    when 'pubDate'
      Time.new.strftime("%Y-%m-%d")
    else
      raise TaxonWorks::Error, "Unrecognized dataset stub node '#{parameter}'!"
    end
  end

  def self.actualize_additional_metadata_stub(parameter, uuid)
    case parameter
    when 'dateStamp'
      DateTime.parse(Time.now.to_s).to_s
    else
      raise TaxonWorks::Error, "Unrecognized additionalMetadata stub node '#{parameter}'!"
    end
  end

  def self.eml_stubbed
    self.eml_for(self.dataset_stub, self.additional_metadata_stub)
  end

  # !! dataset and additional_metadata should be valid xml, otherwise the result
  # may not be what you expect.
  def self.eml_for(dataset, additional_metadata)
    dataset ||= ''
    additional_metadata ||= ''
    builder = self.eml_template

    doc = builder.doc

    # DocumentFragment basically never leaves xml errors, it just 'fixes' things.
    dataset_fragment =
      Nokogiri::XML::DocumentFragment.parse(dataset)
    additional_metadata_fragment =
      Nokogiri::XML::DocumentFragment.parse(additional_metadata)

    doc.at_xpath('//dataset') << dataset_fragment
    doc.at_xpath('//additionalMetadata') << additional_metadata_fragment

    doc
  end

  def self.validate_fragments(dataset, additional_metadata)
    # Embed the fragments in eml_template so that:
    # * they get namespace definitions
    # * Nokogiri catches syntax errors (DocumentFragment generally just fixes
    #   things)
    eml_template_one_line = self.eml_template.to_xml(
      save_with: Nokogiri::XML::Node::SaveOptions::AS_XML | # single line
        Nokogiri::XML::Node::SaveOptions::NO_DECLARATION # skip <xml></xml>
    )

    dataset_xml = Nokogiri::XML::Document.parse(
      eml_template_one_line.sub(
        '<dataset/>',
          "<dataset>#{dataset}</dataset>"
      )
    )

    additional_metadata_xml = Nokogiri::XML::Document.parse(
      eml_template_one_line.sub(
        '<additionalMetadata/>',
          "<additionalMetadata>#{additional_metadata}</additionalMetadata>"
      )
    )

    [dataset_xml.errors, additional_metadata_xml.errors]
  end

  def self.still_stubbed?(dataset, additional_metadata)
    dataset.include?('STUB') || additional_metadata.include?('STUB')
  end

  def self.dataset_stub
    # Do NOT mark fields populated at DWCA create time as STUB; mark all other
    # fields the user needs to fill in with 'STUB'.
    <<~TEXT
      <alternateIdentifier></alternateIdentifier>
      <title xmlns:lang="en">STUB YOUR TITLE HERE</title>
      <creator>
        <individualName>
          <givenName>STUB</givenName>
          <surName>STUB</surName>
        </individualName>
        <organizationName>STUB</organizationName>
        <electronicMailAddress>STUB_EMAIL@EXAMPLE.COM</electronicMailAddress>
      </creator>
      <metadataProvider>
        <organizationName>STUB</organizationName>
        <electronicMailAddress>STUB_EMAIL@EXAMPLE.COM</electronicMailAddress>
        <onlineUrl>STUB</onlineUrl>
      </metadataProvider>
      <associatedParty>
        <organizationName>STUB</organizationName>
        <address>
          <deliveryPoint>STUB - SEE address above for other fields</deliveryPoint>
        </address>
        <role>distributor</role>
      </associatedParty>
      <pubDate>STUB</pubDate>
      <language>eng</language>
      <abstract>
        <para>STUB. Abstract text here.</para>
      </abstract>
      <intellectualRights>
        <para>STUB. License here.</para>
      </intellectualRights>
      <contact>
        <organizationName>STUB</organizationName>
        <address>
          <deliveryPoint>STUB</deliveryPoint>
          <city>STUB</city>
          <administrativeArea>STUB</administrativeArea>
          <postalCode>STUB</postalCode>
          <country>STUB</country>
        </address>
        <electronicMailAddress>STUB_EMAIL@EXAMPLE.COM</electronicMailAddress>
        <onlineUrl>STUB</onlineUrl>
      </contact>
TEXT
  end

  def self.additional_metadata_stub
    # Do NOT mark fields populated at DWCA create time as STUB; mark all other
    # fields the user needs to fill in with 'STUB'.
    <<~TEXT
      <metadata>
        <gbif>
          <dateStamp></dateStamp>
          <hierarchyLevel>dataset</hierarchyLevel>
          <citation identifier="Identifier STUB">STUB DATASET</citation>
          <resourceLogoUrl>STUB. SOME RESOURCE LOGO URL</resourceLogoUrl>
          <formationPeriod>STUB. SOME FORMATION PERIOD</formationPeriod>
          <livingTimePeriod>STUB. SOME LIVING TIME PERIOD</livingTimePeriod>
          <dc:replaces>STUB. PRIOR IDENTIFIER</dc:replaces>
        </gbif>
      </metadata>
TEXT
  end
end
