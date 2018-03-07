json.array!(@biocuration_classifications) do |biocuration_classification|
  json.partial! 'attributes', biocuration_classification: biocuration_classification  
end
