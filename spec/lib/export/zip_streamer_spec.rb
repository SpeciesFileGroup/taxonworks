require 'rails_helper'

describe Export::ZipStreamer, type: :model do
  let(:streamer) { described_class.new }
  let(:temp_dir) { Dir.mktmpdir('zip_streamer_test') }

  after do
    FileUtils.rm_rf(temp_dir) if temp_dir && Dir.exist?(temp_dir)
  end

  def create_temp_file(name, content)
    path = File.join(temp_dir, name)
    File.write(path, content)
    path
  end

  # Namespaced to avoid collision with similar class in other specs.
  module ZipStreamerSpecHelpers
    class FakeZip
      attr_reader :entries

      def initialize
        @entries = []
      end

      def write_deflated_file(name)
        sink = StringIO.new
        yield sink
        @entries << { name: name, content: sink.string }
      end
    end
  end

  describe '#file_available?' do
    specify 'returns true when file exists' do
      path = create_temp_file('test.pdf', 'content')
      entry = { path: path }

      result = streamer.file_available?(entry) { |e| e[:path] }

      expect(result).to be(true)
    end

    specify 'returns false when file does not exist' do
      entry = { path: '/nonexistent/file.pdf' }

      result = streamer.file_available?(entry) { |e| e[:path] }

      expect(result).to be(false)
    end

    specify 'returns false when path is nil' do
      entry = { path: nil }

      result = streamer.file_available?(entry) { |e| e[:path] }

      expect(result).to be(false)
    end
  end

  describe '#stream' do
    let(:file_path) { ->(e) { e[:path] } }
    let(:file_name) { ->(e) { e[:name] } }
    let(:entry_id) { ->(e) { e[:id] } }

    specify 'streams files into the zip' do
      path_a = create_temp_file('a.pdf', 'content A')
      path_b = create_temp_file('b.pdf', 'content B')
      entries = [
        { id: 1, name: 'a.pdf', path: path_a },
        { id: 2, name: 'b.pdf', path: path_b }
      ]

      zip = ZipStreamerSpecHelpers::FakeZip.new
      streamer.stream(
        entries: entries,
        zip_streamer: ->(&block) { block.call(zip) },
        file_path: file_path,
        file_name: file_name,
        entry_id: entry_id
      )

      expect(zip.entries.length).to eq(2)
      expect(zip.entries.map { |e| e[:name] }).to contain_exactly('a.pdf', 'b.pdf')
      contents = zip.entries.map { |e| e[:content] }
      expect(contents).to contain_exactly('content A', 'content B')
    end

    specify 'disambiguates duplicate filenames with entry ID' do
      path_a = create_temp_file('file1.pdf', 'content A')
      path_b = create_temp_file('file2.pdf', 'content B')
      entries = [
        { id: 1, name: 'shared.pdf', path: path_a },
        { id: 2, name: 'shared.pdf', path: path_b }
      ]

      zip = ZipStreamerSpecHelpers::FakeZip.new
      streamer.stream(
        entries: entries,
        zip_streamer: ->(&block) { block.call(zip) },
        file_path: file_path,
        file_name: file_name,
        entry_id: entry_id
      )

      names = zip.entries.map { |e| e[:name] }
      expect(names.uniq.length).to eq(2)
      expect(names).to include('shared.pdf')
      expect(names.find { |n| n != 'shared.pdf' }).to match(/\Ashared-2\.pdf\z/)
    end

    specify 'writes errors.txt when no files could be streamed' do
      entries = [
        { id: 1, name: 'missing.pdf', path: '/nonexistent/file.pdf' }
      ]

      zip = ZipStreamerSpecHelpers::FakeZip.new
      streamer.stream(
        entries: entries,
        zip_streamer: ->(&block) { block.call(zip) },
        file_path: file_path,
        file_name: file_name,
        entry_id: entry_id
      )

      expect(zip.entries.length).to eq(1)
      expect(zip.entries.first[:name]).to eq('errors.txt')
    end

    specify 'continues streaming after individual file failure' do
      path_good = create_temp_file('good.pdf', 'good content')
      entries = [
        { id: 1, name: 'missing.pdf', path: '/nonexistent/file.pdf' },
        { id: 2, name: 'good.pdf', path: path_good }
      ]

      zip = ZipStreamerSpecHelpers::FakeZip.new
      streamer.stream(
        entries: entries,
        zip_streamer: ->(&block) { block.call(zip) },
        file_path: file_path,
        file_name: file_name,
        entry_id: entry_id
      )

      expect(zip.entries.length).to eq(1)
      expect(zip.entries.first[:name]).to eq('good.pdf')
    end

    specify 'sanitizes filenames' do
      path = create_temp_file('test.pdf', 'content')
      entries = [
        { id: 1, name: 'file with spaces & special<chars>.pdf', path: path }
      ]

      zip = ZipStreamerSpecHelpers::FakeZip.new
      streamer.stream(
        entries: entries,
        zip_streamer: ->(&block) { block.call(zip) },
        file_path: file_path,
        file_name: file_name,
        entry_id: entry_id
      )

      # Zaru sanitizes the filename
      expect(zip.entries.first[:name]).not_to include('<')
      expect(zip.entries.first[:name]).not_to include('>')
    end
  end
end
