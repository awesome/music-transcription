require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Musicality::NoteSequence do
  before :all do
    @note1 = Musicality::Note.new(:pitch => Musicality::PitchConstants::C3, :duration => 2)
    @note2 = Musicality::Note.new(:pitch => Musicality::PitchConstants::D3, :duration => 1)
    @note3 = Musicality::Note.new(:pitch => Musicality::PitchConstants::E3, :duration => 3)
  end

  it "should raise ArgumentError if no notes are given during construction" do
    lambda { Musicality::NoteSequence.new }.should raise_error ArgumentError
  end

  it "should not raise ArgumentError if exactly two notes are given during construction" do
    lambda { Musicality::NoteSequence.new( :offset => 0.0, :notes => [ @note1, @note2 ]) }.should_not raise_error ArgumentError
  end

  it "should not raise ArgumentError if more than two notes are given during construction" do
    lambda { Musicality::NoteSequence.new( :offset => 0.0, :notes=> [ @note1, @note2, @note3 ]) }.should_not raise_error ArgumentError
  end

  it "should assign the :notes given during construction" do
    notes = [ @note1, @note2, @note3 ]
    group = Musicality::NoteSequence.new :offset => 0.0, :notes => notes
    group.notes.should eq(notes.clone)
  end

  it "should raise ArgumentError if a non-Array is given for notes" do
    lambda { Musicality::NoteSequence.new( :offset => 0.0, :notes => "b") }.should raise_error ArgumentError
  end

  it "should raise ArgumentError if a non-Note is include with the notes" do
    lambda { Musicality::NoteSequence.new( :offset => 0.0, :notes => [@note1, 5]) }.should raise_error ArgumentError
  end
  
  it "should compute duration according to sum of notes in sequence" do
    notes = [@note1, @note2, @note3 ]
    seq = Musicality::NoteSequence.new :offset => 0.0, :notes => notes
    seq.duration.should eq(6.0)
  end
  
  it "should be hash-makeable" do 
    hash = { 
      :offset => 1.5,
      :notes => [
        {:duration =>2, :pitch => {:octave =>3} },
        {:duration =>1, :pitch => {:octave =>3, :semitone =>2} }
      ]
    }
    obj = NoteSequence.new hash
    obj.offset.should eq(1.5)
    obj.notes.count.should eq(2)
    obj.notes[0].pitch.octave.should eq(3)
    obj.notes[1].pitch.octave.should eq(3)
    obj.notes[1].pitch.semitone.should eq(2)
  end
end
