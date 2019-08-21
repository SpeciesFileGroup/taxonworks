# A middle-layer wrapper between Sqed and TaxonWorks
module GlobalIdHelper 

  # @return [Array of Strings]
  #  the ids of strings from mixed 
  def self.ids_by_class_name(global_ids, class_name)
    global_ids.select{|i| i.model_class.base_class.name == class_name}.map(&:model_id)
  end

end
