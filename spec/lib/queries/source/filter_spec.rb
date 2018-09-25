require 'rails_helper'

require_relative "shared_context"

describe Queries::Source::Filter, type: :model, group: [:source] do

  include_examples 'source queries'

  let(:query) {  Queries::Source::Filter.new({})  }

  specify 'author_ids' do
    query.author_ids = [p1.id]
    expect(query.all.map(&:id)).to contain_exactly(s2.id, s4.id)
  end


end
