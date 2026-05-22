class SqedDepictionPreprocessJob < ApplicationJob
  queue_as :sqed_preprocess

  def perform(sqed_depiction_id:)
    sqed_depiction = SqedDepiction.find_by(id: sqed_depiction_id)
    sqed_depiction&.preprocess(false)
  end
end
