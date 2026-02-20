module BiologicalAssociations
  # Finds an existing BiologicalAssociation whose subject and/or object sides
  # match the submitted anatomical part identity and origin.
  #
  # Matching is one-step only (direct origin_relationship from the AP to the
  # submitted origin object), consistent with how CreateWithAnatomicalParts
  # creates APs.
  #
  # Returns the matching BA with the lowest id, or nil if none found.
  class FindMatchingAnatomicalPartAssociation
    def initialize(params, project_id:)
      @params = params
      @project_id = project_id
    end

    def find
      return nil if subject_ap_attrs.blank? && object_ap_attrs.blank?

      subject_identity = identity_from(subject_ap_attrs) if subject_ap_attrs.present?
      object_identity  = identity_from(object_ap_attrs)  if object_ap_attrs.present?

      return nil if subject_ap_attrs.present? && subject_identity.nil?
      return nil if object_ap_attrs.present?  && object_identity.nil?

      scope = BiologicalAssociation
        .where(project_id: @project_id)
        .where(biological_relationship_id: @params[:biological_relationship_id])

      scope = apply_side(scope, :subject, subject_ap_attrs, subject_identity)
      scope = apply_side(scope, :object,  object_ap_attrs,  object_identity)

      scope.order(:id).first
    end

    def self.ap_attributes_present?(params)
      params[:subject_anatomical_part_attributes].present? ||
        params[:object_anatomical_part_attributes].present? ||
        params[:subject_taxon_determination_attributes].present? ||
        params[:object_taxon_determination_attributes].present?
    end

    def self.deduplication_params(params)
      params.except(
        :subject_anatomical_part_attributes,
        :object_anatomical_part_attributes,
        :subject_taxon_determination_attributes,
        :object_taxon_determination_attributes
      )
    end

    private

    def subject_ap_attrs
      @params[:subject_anatomical_part_attributes]
    end

    def object_ap_attrs
      @params[:object_anatomical_part_attributes]
    end

    def apply_side(scope, side, ap_attrs, identity)
      origin_id   = @params[:"biological_association_#{side}_id"].to_i
      origin_type = @params[:"biological_association_#{side}_type"]

      if ap_attrs.present?
        ap_alias     = "#{side}_ap"
        origin_alias = "#{side}_origin"

        scope
          .where("biological_association_#{side}_type" => 'AnatomicalPart')
          .joins("INNER JOIN anatomical_parts AS #{ap_alias} ON #{ap_alias}.id = biological_associations.biological_association_#{side}_id")
          .joins("INNER JOIN origin_relationships AS #{origin_alias} ON #{origin_alias}.new_object_id = biological_associations.biological_association_#{side}_id AND #{origin_alias}.new_object_type = 'AnatomicalPart'")
          .where("#{origin_alias}.old_object_id = ? AND #{origin_alias}.old_object_type = ?", origin_id, origin_type)
          .where(identity_sql_condition(ap_alias, identity))
      else
        scope.where(
          "biological_association_#{side}_id"   => origin_id,
          "biological_association_#{side}_type" => origin_type
        )
      end
    end

    def identity_from(attributes)
      name      = attributes[:name].to_s.strip
      uri       = attributes[:uri].to_s.strip
      uri_label = attributes[:uri_label].to_s.strip

      if name.present? && uri.blank? && uri_label.blank?
        return { type: :name, name: }
      end

      if name.blank? && uri.present? && uri_label.present?
        return { type: :uri, uri:, uri_label: }
      end

      nil
    end

    def identity_sql_condition(table_alias, identity)
      if identity[:type] == :name
        ["TRIM(#{table_alias}.name) = ?", identity[:name]]
      else
        ["TRIM(#{table_alias}.uri) = ? AND TRIM(#{table_alias}.uri_label) = ?", identity[:uri], identity[:uri_label]]
      end
    end
  end
end
