class SerialChronology < ActiveRecord::Base
  include Housekeeping::Users

  belongs_to :preceding_serial, class_name: "Serial", foreign_key: :preceding_serial_id
  belongs_to :succeeding_serial, class_name: "Serial", foreign_key: :succeeding_serial_id

  validates :preceding_serial, presence: true
  validates :succeeding_serial, presence: true

=begin
  @prime_id
  @a_pre = []

  # TODO validates  relationship is succeeding, or translation
  # Note that the former (preceding is just the reverse of succeeding so any preceding
  #   relationship can be reflected and stored as succeeding. )

  # hashes are previous: and succeeding: represent a sequential chronology\
  # arrays are merges and splits.


  def preceding_rel(prime)
    # return an array of preceding serials
    if prime.class = integer
      @prime_id = prime
      prime     = Serial.find(prime_id)
    else
      @prime_id = prime.id
    end

    prime_chron = preceding1_chron_hash(prime) # how do I tell it that this is chronologyhash_time?
    return nil if prime_chron.nil?

    # for each previous value(know it has at lease one) in the chron hash => loop
    prime_chron.chronology_hash('pre').each do |val|
      previous = preceding1_chron_hash(val)
      {# found one or more

      } unless previous.nil? # we're done with current hash

    end


  end

  private
  def recurse_prev(current_chi)
    # returns ?
    return nil if current_chi.nil? # done

    #         previous_chi = preceding1_chron_hash(current_chi?) # returns ChronologyHash_item

    if previous_chi.chronology_hash['pre]'.class == Serial # have single found single previous serial
      return [previous_chi, current_chi] # not correct return
    else
      if previous_chi.chronology_hash['pre'].class == Array # have multiple previous serials => loop
        previous_chi.chronology_hash.each do |curr_s|

        end
      end
    end

  end

  def preceding1_chron_hash(prime)
    # select all records where succeeding_serial_id = prime_id
    @a_pre = [] # array of all previous serials
    SerialChronology.find_by succeeding_serial_id: prime_id do |pre|
      @a_pre <= Serial.find(pre.to_i)
    end
    return nil if @a_pre.empty? # no preceding serials

    if @a_pre.count == 1
      prime_chron = ChronologyHashItem.new(chronology_hash: {'pre' => @a_pre[0], 'suc' => prime})
    else
      prime_chron = ChronologyHashItem.new(chronology_hash: {'pre' => @a_pre, 'suc' => prime})
    end

    # find translations
    prime_chron.concurrent_hash = {}
    trans_chron                 = SerialChronology.where("relationship = '?' and succeeding_serial_id=?",
                                                         'translation', prime.id)
    if trans_chron.nil? #check reverse
      trans_chron = SerialChronology.where("relationship = '?' and preceding_serial_id = ?",
                                           'translation', prime.id, prime.id)
      prime_chron.concurrent_hash <= {'suc' => Serial.find(trans_chron.succeeding_serial_id)} unless trans_chron.nil?
    else
      prime_chron.concurrent_hash <= {'suc' => Serial.find(trans_chron.preceding_serial_id)}
    end

    if @a_pre.count == 1 # only look for translations if there is only one preceding serial
      trans_chron = SerialChronology.where("relationship = '?' and preceding_serial_id=?",
                                           'translation', @a_pre[0])
      if trans_chron.nil? #check reverse
        trans_chron = SerialChronology.where("relationship = '?' and preceding_serial_id = ?",
                                             'translation', prime.id, prime.id)
        prime_chron.concurrent_hash <= {'pre' => Serial.find(trans_chron.succeeding_serial_id)} unless trans_chron.nil?
      else
        prime_chron.concurrent_hash <= {'pre' => Serial.find(trans_chron.preceding_serial_id)}
      end
    end
    return prime_chron
  end


  class ChronologyHashItem
    class_attribute :chronology_hash
    #class_attribute :previous_serial
    #class_attribute :succeeding_serial
    class_attribute :concurrent_hash
  end
=end
end

