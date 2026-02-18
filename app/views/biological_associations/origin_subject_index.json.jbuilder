json.array!(@biological_associations) do |biological_association|
  json.partial! '/biological_associations/attributes', biological_association: biological_association

  subject = biological_association.biological_association_subject

  if subject&.class&.base_class&.name == 'AnatomicalPart'
    json.subject_anatomical_part do
      json.extract! subject, :name, :uri, :uri_label
    end
  end
end
