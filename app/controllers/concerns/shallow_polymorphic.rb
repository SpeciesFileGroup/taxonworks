# Turn the shallow resource into a global_object_id for use in filters.
module ShallowPolymorphic

  extend ActiveSupport::Concern

  included do

    # @return hash
    def shallow_object_global_param
      u = request.fullpath
      n = self.class.controller_name

      if u =~ /\/\d+\/#{n}(\..+)?(\.json)?$/ && params.permit(:object_global_id).to_h.empty?

        s = u.split('/')
        k = s[1].singularize.camelize
        id = s[2]

        { object_global_id: 'gid://taxon-works/' + k + '/' + id }

      else
        {}
      end
    end

  end

end
