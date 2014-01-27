class Identifier::LocalId < Identifier 
  belongs_to :namespace
  validates :namespace, presence: true
end
