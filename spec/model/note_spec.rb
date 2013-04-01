require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Musicality::Note do
  before :all do
    @pitch = PitchConstants::C4
  end
  
  context '.new' do
    it 'should assign :duration that is given during construction' do
      note = Note.new :duration => 2
      note.duration.should eq(2)
    end
    
    it "should assign :sustain, :attack, and :seperation parameters if given during construction" do
      note = Note.new :duration => 2, :sustain => 0.1, :attack => 0.2, :seperation => 0.3
      note.sustain.should eq(0.1)
      note.attack.should eq(0.2)
      note.seperation.should eq(0.3)
    end
    
    it 'should have no intervals if not given' do
      Note.new(:duration => 2).intervals.should be_empty
    end
    
    it 'should assign intervals when given' do
      intervals = [
        Interval.new(:pitch => PitchConstants::C2),
        Interval.new(:pitch => PitchConstants::D2),
      ]
      Note.new(:duration => 2, :intervals => intervals).intervals.should eq(intervals)
    end
  end
  
  context '#duration=' do
    it 'should assign duration' do
      note = Note.new :pitch => @pitch, :duration => 2
      note.duration = 3
      note.duration.should eq 3
    end
  end
  
  context '#sustain=' do
    it "should assign sustain" do
      note = Note.new :pitch => @pitch, :duration => 2
      note.sustain = 0.123
      note.sustain.should eq 0.123
    end
  end

  context '#attack=' do
    it "should assign attack" do
      note = Note.new :pitch => @pitch, :duration => 2
      note.attack = 0.123
      note.attack.should eq 0.123
    end
  end
  
  context '#seperation=' do
    it "should assign seperation" do
      note = Note.new :pitch => @pitch, :duration => 2
      note.seperation = 0.123
      note.seperation.should eq 0.123
    end
  end
  
  it "should be hash-makeable" do
    Hashmake::hash_makeable?(Note).should be_true
  
    hash = {
      :duration => 2,
      :attack => 0.2,
      :seperation => 0.6,
      :intervals => [
        { :pitch => @pitch, :link => tie(PitchConstants::Eb2) }
      ]
    }
    note = Note.new hash
    note2 = Note.new note.make_hash
    note.should eq(note2)
  end
end
