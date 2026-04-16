require 'rails_helper'

describe SerialChronology, type: :model do

  let(:serial_chronology) { SerialChronology.new }

  let(:serial1) { FactoryBot.create(:valid_serial) }
  let(:serial2) { FactoryBot.create(:valid_serial) }
  let(:serial3) { FactoryBot.create(:valid_serial) }
  let(:serial4) { FactoryBot.create(:valid_serial) }

  specify 'can not cycle self' do
    serial_chronology.succeeding_serial = serial1 
    serial_chronology.preceding_serial = serial1 
    expect(serial_chronology.valid?).to be_falsey
  end

  specify 'can not cycle self in chain 1' do
    SerialChronology::SerialSequence.create!(
      preceding_serial: serial1,
      succeeding_serial: serial2,
    )

    serial_chronology.preceding_serial = serial2 
    serial_chronology.succeeding_serial = serial1 

    expect(serial_chronology.valid?).to be_falsey
  end

  specify 'can not cycle self in chain 2' do
    SerialChronology::SerialSequence.create!(
      preceding_serial: serial1,
      succeeding_serial: serial2,
    )

    SerialChronology::SerialSequence.create!(
      preceding_serial: serial2,
      succeeding_serial: serial3,
    )

    serial_chronology.preceding_serial = serial3 
    serial_chronology.succeeding_serial = serial1 

    expect(serial_chronology.valid?).to be_falsey
  end

  specify 'can not cycle self in chain 3' do
    SerialChronology::SerialSequence.create!(
      preceding_serial: serial2,
      succeeding_serial: serial1,
    )

    SerialChronology::SerialSequence.create!(
      preceding_serial: serial3,
      succeeding_serial: serial1,
    )

    SerialChronology::SerialSequence.create!(
      preceding_serial: serial1,
      succeeding_serial: serial4,
    )

    serial_chronology.preceding_serial = serial4 
    serial_chronology.succeeding_serial = serial2 

    expect(serial_chronology.valid?).to be_falsey
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
