module BiologicalAssociations
  # Finds an existing BiologicalAssociation whose subject and/or object sides
  # match the submitted anatomical part identity and origin_relationship origin.
  #
  # Returns the matching BA with the lowest id, or nil if none found.
  class FindMatchingAnatomicalPartAssociation
    def initialize(params, project_id:)
      @params = params
      @project_id = project_id
    end

    def find
      return nil if subject_anatomical_part_attributes.blank? && object_anatomical_part_attributes.blank?

      subject_identity = identity_from(subject_anatomical_part_attributes) if subject_anatomical_part_attributes.present?
      object_identity  = identity_from(object_anatomical_part_attributes)  if object_anatomical_part_attributes.present?

      return nil if subject_anatomical_part_attributes.present? && subject_identity.nil?
      return nil if object_anatomical_part_attributes.present?  && object_identity.nil?

      scope = BiologicalAssociation
        .where(project_id: @project_id)
        .where(biological_relationship_id: @params[:biological_relationship_id])

      scope = apply_side(scope, :subject, subject_anatomical_part_attributes, subject_identity)
      scope = apply_side(scope, :object,  object_anatomical_part_attributes,  object_identity)

      scope.order(:id).first
    end

    private

    def subject_anatomical_part_attributes
      @params[:subject_anatomical_part_attributes]
    end

    def object_anatomical_part_attributes
      @params[:object_anatomical_part_attributes]
    end

    def apply_side(scope, side, anatomical_part_attrs, identity)
      origin_id = @params[:"biological_association_#{side}_id"].to_i
      origin_type = @params[:"biological_association_#{side}_type"]

      if anatomical_part_attrs.present?
        ap_alias = "#{side}_ap"
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
      name = attributes[:name].to_s.strip
      uri = attributes[:uri].to_s.strip
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
