# A AlternateValue::Translation is a (complete) language translation of a attribute/field.  You must supply the language of the translation.
class AlternateValue::Translation < AlternateValue
  validates :language, presence: true
  validates :alternate_value_object_attribute, presence: true
end
