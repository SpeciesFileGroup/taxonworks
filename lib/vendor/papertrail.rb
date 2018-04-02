module TaxonWorks
  module Vendor

    # Functions for Papertrail
    module Papertrail 

      # @Return [Hash, false] a summary of the differences in two versions of the object
      # @param object [Obect] any instance of an IsData class
      # @param verstion_a [String|Integer] papertrail index of a version to compare
      # @param verstion_b [String|Integer] papertrail index of a version to compare
      def self.compare(object, opts = {} )
        r = {
          object: object,
          comparing_current: false,
          version_a: opts[:version_a].to_i,
          version_b: opts[:version_b].to_i,
          attributes_new: {},
          attributes_old: {},
          user_new: nil,
          user_old: nil
        }

        version_index_a = r[:version_a] # version_a.to_i #params.require(:version_a).to_i
        version_index_b = r[:version_b] # version_b.to_i #params.require(:version_b).to_i

        # The version at index 0 is the version created before something is made,
        # as in the state of the obj before it was created, aka all attributes null
        # thus why index of 1 (when it actually has attributes) is the smallest
        # an index can be for a proper version
        if version_index_a < 0 || version_index_a >= object.versions.length
          return false
        end

        # If version_b index is outside the range treat it as if it means that
        # we should compare the current version to an older version, thus set it
        # equal to version_a index for simplicity for later on
        if version_index_b <= 0 || version_index_b >= object.versions.length
          version_index_b = version_index_a;
        end

        # Make version_index_a be an index to the newer version
        # thus if version_index_b is greater than version_index_a
        # we must swap the two values to make version_index_a
        # an index to the newer version
        if version_index_b > version_index_a
          tmp_version_index = version_index_b
          version_index_b = version_index_a
          version_index_a = tmp_version_index
        end

        # version_a will point to the newer version
        # version_b will pointvto the older version
        version_a = object.versions[version_index_a]
        version_b = object.versions[version_index_b]

        r[:attributes_new] = version_a.reify.attributes
        r[:attributes_old] = version_b.reify.attributes
        r[:comparing_current] = false

        # If the index for version_a and version_b match it means
        # we're comparing the current version against an older one
        if(version_index_a == version_index_b)
#         r[:user_new] = User.find(object['updated_by_id']).name  # wrong!
#         r[:user_old] = User.find(r[:attributes_old]['updated_by_id']).name  # wrong!
          r[:attributes_new] = object.attributes
          r[:comparing_current] = true
        end

        r[:user_new] = User.find(version_a.whodunnit).name
        r[:user_old] = User.find(version_b.whodunnit).name

        r[:index_old] = version_index_a
        r[:index_new] = version_index_b

    #   r[:attributes_new] = view_context.filter_out_attributes(r[:attributes_new])
    #   r[:attributes_old] = view_context.filter_out_attributes(r[:attributes_old])

        r


      end

    end
  end
end

