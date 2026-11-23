require 'rails_helper'

describe Workbench::FeedbackHelper, type: :helper do

  specify '#feedback_badge_tag is a thin feedback span of the given type' do
    expect(helper.feedback_badge_tag('species', :light)).to eq(
      '<span class="feedback feedback-thin feedback-light">species</span>'
    )
  end

  specify '#feedback_badge_tag escapes its content' do
    expect(helper.feedback_badge_tag('<b>"x"</b>', :warning)).to eq(
      '<span class="feedback feedback-thin feedback-warning">' \
      '&lt;b&gt;&quot;x&quot;&lt;/b&gt;</span>'
    )
  end

end
