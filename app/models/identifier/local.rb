class Identifier::Local < Identifier 

  belongs_to :namespace
  validates  :namespace, presence: true

end
