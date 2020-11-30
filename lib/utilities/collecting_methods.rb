module Utilities::CollectingMethods

  METHODS = {'malaise trap' => 'Malaise trap',
             'malaise' => 'Malaise trap',
             'sweeping' => 'sweep net',
             'sweep netting' => 'sweep net',
             'sweep net' => 'sweep net',
             'sweepnet' => 'sweep net',

             'uv light trap' => 'UV light trap',
             'uv trap' => 'UV light trap',
             'uv light' => 'UV light',
             'u.v. light' => 'UV light',
             'blacklight trap' => 'black light trap',
             'black light trap' => 'black light trap',
             'hg light trap' => 'mercury vapor light trap',
             'blacklight' => 'black light',
             'light trap' => 'light trap',
             'mercury vapor' => 'mercury vapor light',
             'hg. vapor' => 'mercury vapor light',
             'hg vapor' => 'mercury vapor light',
             'mv light' => 'mercury vapor light',
             'm.v. light' => 'mercury vapor light',
             'mercury vapour' => 'mercury vapor light',
             'merc. vapor' => 'mercury vapor light',
             'at light' => 'at light',
             'light' => 'at light',

             'hand collecting' => 'hand collecting',
             'hand collect' => 'hand collecting',
             'handpick' => 'hand collecting',
             'hand pick' => 'hand collecting',
             'hand collection' => 'hand collecting',

             'suction trap' => 'suction trap',
             'd-vac' => 'D-vac',
             'aspirator' => 'aspirator',
             'vacuum' => 'vacuum',

             'dip net' => 'dip net',
             'dipnet' => 'dip net',
             'aerial net' => 'aerial net',
             'berlese' => 'Berlese funnel',
             'interception net' => 'interception net',

             'pan trap, yellow' => 'pan trap, yellow',
             'yellow pan trap' => 'pan trap, yellow',
             'blue pan trap' => 'pan trap, blue',
             'pan trap, blue' => 'pan trap, blue',
             'red pan trap' => 'pan trap, red',
             'pan trap, red' => 'pan trap, red',
             'pan trap' => 'pan trap',

             'pitfall' => 'pitfall trap',

             'beating sheet' => 'beating sheet',
             'beat sheet' => 'beating sheet',
             'beating' => 'beating sheet',
             'flight trap' => 'flight trap',
             'aerial sweep net' => 'flight trap',
             'bait trap' => 'bait trap',
             'fogging' => 'fogging',
              }.freeze

  class MethodFromLabel
    attr_reader(:verbatim_label, :date)

    # @param [String] label
    def initialize(label)
      @verbatim_label = label
      @collecting_method = Utilities::CollectingMethods.method_regex_from_verbatim_label(label)
    end
  end

  def self.method_regex_from_verbatim_label(text)
    text = ' ' + text.downcase + ' '
    METHODS.each do |k, v|
      if text =~ /[\s,.;:\/|\(\)-]#{k}[\s,.;:\/|\(\)-]/
        return {verbatim_method: v}
      end
    end
    return {}
  end
end