class UpdateLocalIdentifiersCachedNumeric < ActiveRecord::Migration[7.2]
  def change
    Identifier::Local
      .joins(:namespace)
      .where(namespace: {is_virtual: true})
      .find_each do |i|
        cached_numeric = i.send(:build_cached_numeric_identifier)
        i.update_column(:cached_numeric_identifier, cached_numeric)
    end
  end
end
