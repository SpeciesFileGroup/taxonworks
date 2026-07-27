require 'rails_helper'

describe Workbench::HtmlHelper, type: :helper do

  specify '#mark_tag wraps a matching term in <mark>' do
    expect(helper.mark_tag('plain text term here', 'term')).to eq('plain text <mark>term</mark> here')
  end

  specify '#mark_tag is case insensitive' do
    expect(helper.mark_tag('Plain Text', 'text')).to eq('Plain <mark>Text</mark>')
  end

  specify '#mark_tag wraps all occurrences of the term' do
    expect(helper.mark_tag('term term', 'term')).to eq('<mark>term</mark> <mark>term</mark>')
  end

  specify '#mark_tag escapes regex special characters in the term' do
    expect(helper.mark_tag('a (b) c', '(b)')).to eq('a <mark>(b)</mark> c')
  end

  specify '#mark_tag does not mark text inside HTML tag attributes' do
    expect(helper.mark_tag('<span title="Catalog Number">ABC123</span>', 'Catalog'))
      .to eq('<span title="Catalog Number">ABC123</span>')
  end

  specify '#mark_tag marks matching visible text alongside untouched markup' do
    expect(helper.mark_tag('<span title="Catalog Number">ABC123</span>', 'ABC'))
      .to eq('<span title="Catalog Number"><mark>ABC</mark>123</span>')
  end

  specify '#mark_tag returns nil when the string is nil' do
    expect(helper.mark_tag(nil, 'term')).to be_nil
  end

  specify '#mark_tag returns the string unchanged when the term is nil' do
    expect(helper.mark_tag('abc', nil)).to eq('abc')
  end

  specify '#mark_tag returns the string unchanged when the term is blank' do
    expect(helper.mark_tag('abc', '')).to eq('abc')
  end

  specify '#mark_tag returns an html_safe string' do
    expect(helper.mark_tag('term', 'term')).to be_html_safe
  end

end
