class Descriptor::Qualitative < Descriptor 

  has_many :character_states, foreign_key: :descriptor_id
  
end
