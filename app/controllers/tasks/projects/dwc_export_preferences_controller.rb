class Tasks::Projects::DwcExportPreferencesController < ApplicationController
  include TaskControllerConfiguration

  def index
    @project = Project.find(sessions_current_project_id)
    @preferences = @project.preferences

    if request.post?
      @dataset_errors, @additional_metadata_errors =
        xml_errors(params[:dataset], params[:additional_metadata])

      if @dataset_errors.count + @additional_metadata_errors.count == 0
        rv = save_to_preferences(params[:dataset], params[:additional_metadata])
        if rv == false
          # TODO
        else
          flash[:notice] = 'Preferences saved'
          redirect_to @project
        end
      else
        @dataset = params[:dataset]
        @additional_metadata = params[:additional_metadata]
        render :index, status: :unprocessable_entity
      end
    elsif request.get?
      # check for preferences
      @dataset = default_dataset
      @additional_metadata = default_additional_metadata
    end
  end

  private

  def save_to_preferences(dataset, additional_metadata)
    project = Project.find(sessions_current_project_id)
    preferences = project.preferences
    xml = eml_template
    xml = xml.sub('@dataset', dataset)
    # TODO: need to insert <dateStamp>2025-08-24T23:42:58-05:00</dateStamp>
    xml = xml.sub('@additional_metadata', additional_metadata)
    eml_xml = Nokogiri::XML::Document.parse(xml)
    return false if eml_xml.errors.present?

    preferences[:eml] = xml
    return project.save
  end

  def xml_errors(dataset, additional_metadata)
    # TODO: currently fails on namespaced prefixes like 'dc:replaces'
    dataset_xml = Nokogiri::XML::DocumentFragment.parse(dataset)

    additional_metadata_xml = Nokogiri::XML::DocumentFragment.parse(additional_metadata)

    [dataset_xml.errors, additional_metadata_xml.errors]
  end

  def eml_template
    <<~TEXT
    <eml:eml xmlns:eml="eml://ecoinformatics.org/eml-2.1.1" xmlns:dc="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="eml://ecoinformatics.org/eml-2.1.1 http://rs.gbif.org/schema/eml-gbif-profile/1.1/eml-gbif-profile.xsd" packageId="38e02a70-9aa2-41dd-8729-ebc395ccd5ef" system="https://taxonworks.org" scope="system" xml:lang="en">
      <dataset>
        @dataset
      </dataset>
      <additionalMetadata>
        @additional_metadata
      </additionalMetadata>
    </eml:eml>
TEXT
  end

  def default_dataset
    <<~TEXT
      <alternateIdentifier>38e02a70-9aa2-41dd-8729-ebc395ccd5ef</alternateIdentifier>
      <title xmlns:lang="en">STUB YOUR TITLE HERE</title>
      <creator>
        <individualName>
          <givenName>STUB</givenName>
          <surName>STUB</surName>
        </individualName>
        <organizationName>STUB</organizationName>
        <electronicMailAddress>EMAIL@EXAMPLE.COM</electronicMailAddress>
      </creator>
      <metadataProvider>
        <organizationName>STUB</organizationName>
        <electronicMailAddress>EMAIL@EXAMPLE.COM</electronicMailAddress>
        <onlineUrl>STUB</onlineUrl>
      </metadataProvider>
      <associatedParty>
        <organizationName>STUB</organizationName>
        <address>
          <deliveryPoint>SEE address above for other fields</deliveryPoint>
        </address>
        <role>distributor</role>
      </associatedParty>
      <pubDate>2025-08-24</pubDate>
      <language>eng</language>
      <abstract>
        <para>Abstract text here.</para>
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
        <electronicMailAddress>EMAIL@EXAMPLE.COM</electronicMailAddress>
        <onlineUrl>STUB</onlineUrl>
      </contact>
TEXT
  end

  def default_additional_metadata
    <<~TEXT
    <hierarchyLevel>dataset</hierarchyLevel>
    <citation identifier="Identifier STUB">STUB DATASET</citation>
    <resourceLogoUrl>SOME RESOURCE LOGO URL</resourceLogoUrl>
    <formationPeriod>SOME FORMATION PERIOD</formationPeriod>
    <livingTimePeriod>SOME LIVING TIME PERIOD</livingTimePeriod>
    <dc:replaces>PRIOR IDENTIFIER</dc:replaces>
TEXT
  end
end