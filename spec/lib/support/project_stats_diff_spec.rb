require 'rails_helper'

describe Support::ProjectStatsDiff do

  def row(project_id, table, count, max_id: count, max_created_at: '2026-01-01 00:00:00', max_updated_at: '2026-01-01 00:00:00', project_name: nil, model: nil)
    {
      'project_id' => project_id&.to_s,
      'project_name' => project_name || (project_id ? "Project #{project_id}" : nil),
      'model' => model || table.to_s.classify,
      'table' => table.to_s,
      'count' => count.to_s,
      'max_created_at' => max_created_at,
      'max_updated_at' => max_updated_at,
      'max_id' => max_id&.to_s
    }
  end

  def change_for(diff, project_id, table)
    diff.changes.detect { |c| c.project_id == project_id && c.table == table }
  end

  context 'kinds of change' do
    specify 'a project-scoped table whose rows are all gone is emptied' do
      diff = described_class.new([row(1, :otus, 5)], [])
      expect(change_for(diff, 1, 'otus').kind).to eq(:emptied)
    end

    specify 'a table whose count drops to 0 is emptied' do
      diff = described_class.new([row(nil, :users, 5)], [row(nil, :users, 0, max_id: 5)])
      expect(change_for(diff, nil, 'users').kind).to eq(:emptied)
    end

    specify 'a table with rows only in the end file is new' do
      diff = described_class.new([], [row(1, :otus, 3)])
      expect(change_for(diff, 1, 'otus').kind).to eq(:new)
    end

    specify 'a changed count is a count change, with delta and percent' do
      diff = described_class.new([row(1, :otus, 200)], [row(1, :otus, 250)])
      c = change_for(diff, 1, 'otus')
      expect(c.kind).to eq(:count)
      expect(c.delta).to eq(50)
      expect(c.percent).to eq(25.0)
    end

    specify 'same count with a higher max_id means rows were both inserted and deleted' do
      diff = described_class.new([row(1, :otus, 10, max_id: 10)], [row(1, :otus, 10, max_id: 14)])
      c = change_for(diff, 1, 'otus')
      expect(c.kind).to eq(:same_count)
      expect(c.signals).to contain_exactly(:inserted, :deleted)
    end

    specify 'same count and max_id with a later max_updated_at means rows were updated' do
      diff = described_class.new(
        [row(1, :otus, 10)],
        [row(1, :otus, 10, max_updated_at: '2026-02-01 00:00:00')]
      )
      c = change_for(diff, 1, 'otus')
      expect(c.kind).to eq(:same_count)
      expect(c.signals).to contain_exactly(:updated)
    end

    specify 'identical rows are not reported' do
      diff = described_class.new([row(1, :otus, 10)], [row(1, :otus, 10)])
      expect(diff.changes).to be_empty
      expect(diff.unchanged_count).to eq(1)
    end
  end

  context 'signals only claim what the snapshots prove' do
    specify 'a lower count without a higher max_id is deletes only' do
      diff = described_class.new([row(1, :otus, 10, max_id: 10)], [row(1, :otus, 7, max_id: 10)])
      expect(change_for(diff, 1, 'otus').signals).to contain_exactly(:deleted)
    end

    specify 'a higher count with a higher max_id is inserts, deletes unknown' do
      diff = described_class.new([row(1, :otus, 10, max_id: 10)], [row(1, :otus, 12, max_id: 15)])
      expect(change_for(diff, 1, 'otus').signals).to contain_exactly(:inserted)
    end

    specify 'a lower count with a higher max_id is both inserts and deletes' do
      diff = described_class.new([row(1, :otus, 10, max_id: 10)], [row(1, :otus, 8, max_id: 12)])
      expect(change_for(diff, 1, 'otus').signals).to contain_exactly(:inserted, :deleted)
    end

    specify 'updates are not claimed when rows were inserted' do
      diff = described_class.new(
        [row(1, :otus, 10, max_id: 10)],
        [row(1, :otus, 11, max_id: 11, max_updated_at: '2026-02-01 00:00:00')]
      )
      expect(change_for(diff, 1, 'otus').signals).not_to include(:updated)
    end
  end

  context 'projects' do
    specify 'a project with rows only in the start file is gone' do
      diff = described_class.new([row(1, :otus, 5), row(2, :otus, 5)], [row(2, :otus, 5)])
      expect(diff.projects_gone.keys).to eq([1])
    end

    specify 'a project with rows only in the end file is added' do
      diff = described_class.new([row(1, :otus, 5)], [row(1, :otus, 5), row(2, :otus, 1)])
      expect(diff.projects_added.keys).to eq([2])
    end

    specify 'renamed projects are reported' do
      diff = described_class.new([row(1, :otus, 5, project_name: 'Old')], [row(1, :otus, 5, project_name: 'New')])
      expect(diff.projects_renamed).to eq({1 => ['Old', 'New']})
    end

    specify 'project_id limits the diff to one project' do
      diff = described_class.new([row(1, :otus, 5), row(2, :otus, 5)], [row(1, :otus, 6), row(2, :otus, 9)], project_id: 2)
      expect(diff.changes.map(&:project_id)).to eq([2])
    end
  end

  context 'totals' do
    specify 'rows added and removed are summed separately' do
      diff = described_class.new(
        [row(1, :otus, 10), row(1, :notes, 10)],
        [row(1, :otus, 15), row(1, :notes, 4)]
      )
      expect(diff.rows_added).to eq(5)
      expect(diff.rows_removed).to eq(6)
    end
  end

  context '.from_files' do
    let(:dir) { Dir.mktmpdir }
    after { FileUtils.rm_rf(dir) }

    def write_tsv(name, rows, headers: Support::ProjectStatsDiff::HEADERS)
      path = File.join(dir, name)
      CSV.open(path, 'w', col_sep: "\t") do |csv|
        csv << headers
        rows.each { |r| csv << headers.map { |h| r[h] } }
      end
      path
    end

    specify 'reads the TSVs written by tw:audit:project_stats' do
      a = write_tsv('a.tsv', [row(1, :otus, 5)])
      b = write_tsv('b.tsv', [row(1, :otus, 8)])
      expect(change_for(described_class.from_files(a, b), 1, 'otus').delta).to eq(3)
    end

    specify 'raises on unexpected headers' do
      a = write_tsv('a.tsv', [], headers: %w[foo bar])
      b = write_tsv('b.tsv', [row(1, :otus, 8)])
      expect { described_class.from_files(a, b) }.to raise_error(ArgumentError, /headers/)
    end

    specify 'raises on a missing file' do
      b = write_tsv('b.tsv', [])
      expect { described_class.from_files(File.join(dir, 'nope.tsv'), b) }.to raise_error(ArgumentError, /nope\.tsv/)
    end
  end

  context '#report' do
    let(:diff) {
      described_class.new(
        [row(1, :otus, 1200), row(1, :notes, 3), row(2, :otus, 4)],
        [row(1, :otus, 1250), row(1, :images, 2)],
        start_label: 'pre.tsv', end_label: 'post.tsv'
      )
    }

    let(:report) { diff.report }

    specify 'names both files' do
      expect(report).to include('pre.tsv', 'post.tsv')
    end

    specify 'lists emptied tables in their own section' do
      expect(report).to match(/Emptied.*notes/m)
    end

    specify 'lists projects whose data is gone' do
      expect(report).to match(/Projects with no rows left.*Project 2/m)
    end

    specify 'formats counts with delimiters and signed deltas' do
      expect(report).to include('1,200', '1,250', '+50')
    end

    specify 'does not sign zero totals' do
      r = described_class.new([row(1, :otus, 10)], [row(1, :otus, 10, max_updated_at: '2026-02-01 00:00:00')]).report
      expect(r).to include('rows: 0 added, 0 removed, net 0')
    end
  end
end
