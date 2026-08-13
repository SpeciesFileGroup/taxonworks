require 'rails_helper'

describe Vendor::Prawn, type: :model do

  after { described_class.instance_variable_set(:@covered_codepoints, nil) }

  context 'when the CJK font is not installed (local dev, CI)' do
    before { allow(described_class).to receive(:cjk_font_available?).and_return(false) }

    it 'font_families only registers LiberationSans' do
      expect(described_class.font_families.keys).to eq(['LiberationSans'])
    end

    it 'cjk_fallback is empty' do
      expect(described_class.cjk_fallback).to eq([])
    end
  end

  context 'when the CJK font is installed (production/staging)' do
    before { allow(described_class).to receive(:cjk_font_available?).and_return(true) }

    it 'font_families also registers SourceHanSans' do
      expect(described_class.font_families.keys).to include('LiberationSans', 'SourceHanSans')
    end

    it 'SourceHanSans points at CJK_FONT_PATH' do
      expect(described_class.font_families['SourceHanSans']).to eq(normal: described_class::CJK_FONT_PATH)
    end

    it 'cjk_fallback names SourceHanSans' do
      expect(described_class.cjk_fallback).to eq(['SourceHanSans'])
    end
  end

  # ── text ──────────────────────────────────────────────────────────────────

  describe '.text' do
    it 'returns a Prawn::Document with LiberationSans as the current font' do
      pdf = described_class.text('hello')
      expect(pdf).to be_a(::Prawn::Document)
      expect(pdf.font.family).to eq('LiberationSans')
    end

    it 'can render a Latin Extended diacritic without raising' do
      expect { described_class.text('Güçlü, Staręga, Šilhavý', inline_format: true) }.not_to raise_error
    end

    it 'passes cjk_fallback as fallback_fonts, without the caller specifying it' do
      allow(described_class).to receive(:cjk_fallback).and_return(['SourceHanSans'])
      fake_pdf = instance_double(::Prawn::Document, font_families: {}, font: nil)
      allow(::Prawn::Document).to receive(:new).and_return(fake_pdf)

      expect(fake_pdf).to receive(:text).with('some text', inline_format: true, fallback_fonts: ['SourceHanSans'])
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

  describe '.covered_codepoints' do
    context 'when the CJK font is not installed' do
      before { allow(described_class).to receive(:cjk_font_available?).and_return(false) }

      it 'covers LiberationSans characters (e.g. ü, U+00FC)' do
        expect(described_class.covered_codepoints).to include(0x00FC)
      end

      it 'does not cover CJK characters' do
        expect(described_class.covered_codepoints).not_to include(0x3042) # あ
      end
    end

    context 'when the CJK font is installed' do
      before do
        allow(described_class).to receive(:cjk_font_available?).and_return(true)

        fake_cjk_font = instance_double(TTFunk::File)
        fake_cmap = instance_double(TTFunk::Table::Cmap)
        # Format04/12 etc are modules dynamically extended onto a Subtable
        # instance at parse time, so `code_map` isn't declared on the base
        # Subtable class itself - a verifying double can't represent that.
        fake_subtable = double('cmap subtable', code_map: { 0x3042 => 1 })
        allow(fake_cmap).to receive(:unicode).and_return([fake_subtable])
        allow(fake_cjk_font).to receive(:cmap).and_return(fake_cmap)
        allow(TTFunk::File).to receive(:open).and_call_original
        allow(TTFunk::File).to receive(:open).with(described_class::CJK_FONT_PATH).and_return(fake_cjk_font)
      end

      it 'covers both LiberationSans and the CJK font characters' do
        expect(described_class.covered_codepoints).to include(0x00FC, 0x3042)
      end
    end
  end

  describe '.warn_on_uncovered_glyphs' do
    context 'when the CJK font is not installed' do
      before { allow(described_class).to receive(:cjk_font_available?).and_return(false) }

      it 'does not notify, even when the text has CJK characters' do
        expect(ExceptionNotifier).not_to receive(:notify_exception)
        described_class.warn_on_uncovered_glyphs("あ")
      end
    end

    context 'when the CJK font is installed' do
      before do
        allow(described_class).to receive(:cjk_font_available?).and_return(true)
        allow(described_class).to receive(:covered_codepoints).and_return(Set.new([0x00FC, 0x3042]))
      end

      it 'does not notify when every character is covered' do
        expect(ExceptionNotifier).not_to receive(:notify_exception)
        described_class.warn_on_uncovered_glyphs("üあ")
      end

      it 'notifies with the uncovered characters when some are missing' do
        expect(ExceptionNotifier).to receive(:notify_exception) do |_error, data:|
          expect(data[:uncovered_chars]).to eq("い") # い, not in the covered set
        end
        described_class.warn_on_uncovered_glyphs("あい")
      end

      it 'merges caller-provided context into the notification data' do
        expect(ExceptionNotifier).to receive(:notify_exception) do |_error, data:|
          expect(data[:style_id]).to eq('123')
        end
        described_class.warn_on_uncovered_glyphs("い", context: { style_id: '123' })
      end
    end
  end

end
