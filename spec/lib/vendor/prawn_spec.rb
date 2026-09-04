require 'rails_helper'

describe Vendor::Prawn, type: :model do

  context 'when the CJK font is installed (production/staging)' do
    before {
      allow(described_class).to receive(:cjk_font_available?).and_return(true)
    }

    it 'font_families also registers SourceHanSans' do
      expect(described_class.font_families.keys)
        .to include('LiberationSans', 'SourceHanSans')
    end

    it 'SourceHanSans points at CJK_FONT_PATH' do
      expect(described_class.font_families['SourceHanSans'])
        .to eq(normal: described_class::CJK_FONT_PATH)
    end

    it 'cjk_fallback names SourceHanSans' do
      expect(described_class.cjk_fallback).to eq(['SourceHanSans'])
    end
  end

  describe '.text' do
    it 'returns a Prawn::Document with LiberationSans as the current font' do
      pdf = described_class.text('hello')
      expect(pdf).to be_a(::Prawn::Document)
      expect(pdf.font.family).to eq('LiberationSans')
    end

    it 'can render a Latin Extended diacritic without raising' do
      expect {
        described_class.text('Güçlü, Staręga, Šilhavý', inline_format: true)
      }.not_to raise_error
    end

    it 'passes cjk_fallback as fallback_fonts, without the caller specifying it' do
      allow(described_class)
        .to receive(:cjk_fallback).and_return(['SourceHanSans'])
      fake_pdf = instance_double(::Prawn::Document, font_families: {}, font: nil)
      allow(::Prawn::Document).to receive(:new).and_return(fake_pdf)

      expect(fake_pdf)
        .to receive(:text)
        .with('some text', inline_format: true, fallback_fonts: ['SourceHanSans'])
      described_class.text('some text', inline_format: true)
    end

    it 'passes an empty fallback_fonts when the CJK font is unavailable' do
      allow(described_class).to receive(:cjk_fallback).and_return([])
      fake_pdf = instance_double(::Prawn::Document, font_families: {}, font: nil)
      allow(::Prawn::Document).to receive(:new).and_return(fake_pdf)

      expect(fake_pdf).to receive(:text).with('some text', fallback_fonts: [])
      described_class.text('some text')
    end
  end

end
