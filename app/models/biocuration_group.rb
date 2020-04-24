# A Tag that groups (classifies) BiocurationClasses
class BiocurationGroup < Keyword 

  # This could ultimately be SQL'ed out 
  def biocuration_classes
    tagged_objects
  end

  def can_tag
    %w{BiocurationClass}
  end

end
