# Helpers and facets for queries that reference Conveyances/Sounds
#
module Queries::Concerns::Conveyances
  extend ActiveSupport::Concern

  def self.params
    [
      :sound_id,
      :sounds,
      :conveyances,
      sound_id: []
    ]
  end

  included do
    # @return [Array]
    # @params sound_id
    attr_accessor :sound_id

    # @return [Boolean, nil]
    #  true - has sounds
    #  false - doesn't have sounds
    attr_accessor :sounds

    # @return [Boolean, nil]
    # Alias/identical to sounds
    #  true - has sounds
    #  false - doesn't have sounds
    attr_accessor :conveyances

    def sound_id
      [@sound_id].flatten.compact.uniq
    end
  end

  def set_conveyance_params(params)
    @sound_id = params[:sound_id]
    @sounds = boolean_param(params, :sounds)
    @conveyances = boolean_param(params, :conveyances)
  end

  def sound_id_facet
    return nil if sound_id.empty?
    referenced_klass.joins(:conveyances).where(conveyances: {sound_id:})
  end

  # !! Duplicate with sounds
  def conveyances_facet
    return nil if conveyances.nil?

    if conveyances
      referenced_klass.joins(:conveyances).distinct
    else
      referenced_klass.where.missing(:conveyances)
    end
  end

  def sounds_facet
    return nil if sounds.nil?
    if sounds
      referenced_klass.joins(:conveyances).distinct
    else
      referenced_klass.where.missing(:conveyances)
    end
  end

  def self.merge_clauses
    [
      :conveyances_facet,
      :sound_id_facet,
      :sounds_facet
    ]
  end

end
