require 'rails_helper'

describe Vendor::Prawn, type: :model do

  context 'when the CJK font is installed (production/staging)' do
    before {
      allow(described_class).to receive(:cjk_font_available?).and_return(true)
    }

    it 'font_families also registers the CJK font' do
      expect(described_class.font_families.keys)
        .to include('LiberationSans', described_class::CJK_FONT_FAMILY)
    end

    it 'the CJK font uses CJK_FONT_PATH for every style' do
      path = described_class::CJK_FONT_PATH
      expect(
        described_class.font_families[described_class::CJK_FONT_FAMILY]
      ).to eq(normal: path, bold: path, italic: path, bold_italic: path)
    end

    it 'cjk_fallback names the CJK font' do
      expect(described_class.cjk_fallback)
        .to eq([described_class::CJK_FONT_FAMILY])
    end
  end

  describe '.text' do
    # These render with the real font files, installed by the OS
    # fonts-liberation package. Skipped locally when absent (e.g. non-Ubuntu
    # dev machines); never skipped on CI, where the package is required.
    context 'with Liberation Sans installed' do
      before do
        if !File.file?(described_class::LIBERATION_SANS_REGULAR) &&
            ENV['CI'].nil?
          skip 'Liberation fonts not installed (set TW_LIBERATION_SANS_DIR)'
        end
      end

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
    end

    it 'passes cjk_fallback as fallback_fonts, without the caller specifying it' do
      allow(described_class)
        .to receive(:cjk_fallback).and_return(['DroidSansFallback'])
      fake_pdf = instance_double(::Prawn::Document, font_families: {}, font: nil)
      allow(::Prawn::Document).to receive(:new).and_return(fake_pdf)

      expect(fake_pdf)
        .to receive(:text)
        .with('some text', inline_format: true, fallback_fonts: ['DroidSansFallback'])
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
