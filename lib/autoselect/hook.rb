# lib/autoselect/hook.rb
#
# Base class for multi-step levels that chain autoselects across models.
# The canonical example is OTU's catalog_of_life level, which hooks into
# TaxonName's catalog_of_life level to create a TaxonName first, then
# uses the resulting taxon_name_id to create the OTU.
#
# Hook execution is internal (Ruby, not HTTP). The hook calls the sub-autoselect
# level directly, collects the yielded attributes, and passes them back to the
# parent level's record creation logic.
#
class Autoselect::Hook

  # @return [Symbol] the attribute this hook yields, e.g. :taxon_name_id
  def yields
    raise NotImplementedError, "#{self.class} must implement #yields"
  end

  # @return [Class] the autoselect class to delegate to for the sub-request
  def hooked_autoselect_class
    raise NotImplementedError, "#{self.class} must implement #hooked_autoselect_class"
  end

  # @return [Symbol] the level key on the hooked autoselect to invoke
  def hooked_level
    raise NotImplementedError, "#{self.class} must implement #hooked_level"
  end

  # Execute the hook.
  # @param term [String]
  # @param project_id [Integer, nil]
  # @param user_id [Integer, nil]
  # @param kwargs [Hash]
  # @return [Array<Hash>] items with extension: { mode: 'hook_confirmation', ... }
  def call(term:, project_id: nil, user_id: nil, **kwargs)
    raise NotImplementedError, "#{self.class} must implement #call"
  end

end
