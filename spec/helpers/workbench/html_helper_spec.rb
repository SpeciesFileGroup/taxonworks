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

  specify '#mark_tag does not mark text inside an HTML entity' do
    expect(helper.mark_tag('AT&amp;T', 'amp')).to eq('AT&amp;T')
  end

  specify '#mark_tag still marks visible text adjacent to an HTML entity' do
    expect(helper.mark_tag('Smith &amp; term', 'term')).to eq('Smith &amp; <mark>term</mark>')
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

  specify '#mark_tag returns a non-html_safe string when html_safe: false' do
    expect(helper.mark_tag('term', 'term', html_safe: false)).to_not be_html_safe
  end

  specify '#mark_tag with html_safe: false still marks the term' do
    expect(helper.mark_tag('plain text term here', 'term', html_safe: false))
      .to eq('plain text <mark>term</mark> here')
  end

  specify '#mark_tag with html_safe: false does not leak safety from a caller that keeps concatenating' do
    # Guards against ActiveSupport::SafeBuffer#+ escaping later unsafe appends
    # when the accumulator was seeded with an already-safe mark_tag result.
    s = helper.mark_tag('term', 'term', html_safe: false)
    s += ' ' + helper.content_tag(:span, 'x')
    expect(s).to eq('<mark>term</mark> <span>x</span>')
  end

end
