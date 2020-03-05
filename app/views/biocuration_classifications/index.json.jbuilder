json.array!(@biocuration_classifications) do |biocuration_classification|
  json.partial! '/biocuration_classifications/attributes', biocuration_classification: biocuration_classification
end
