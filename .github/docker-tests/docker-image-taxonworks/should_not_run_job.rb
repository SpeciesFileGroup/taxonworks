class ShouldNotRunJob < ApplicationJob
  queue_as :should_not_run

  def perform(otu)
    otu.destroy!
  end
end
