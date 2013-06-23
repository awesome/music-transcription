require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Musicality::TempoComputer do
  it "should always return starting tempo if only tempo given" do
    tempo_profile = Musicality::Profile.new :start_value => tempo(120)
    tc = Musicality::TempoComputer.new tempo_profile
    [ValueComputer.domain_min, -1000, 0, 1, 5, 100, 10000, ValueComputer.domain_max].each do |offset|
      tc.notes_per_second_at(offset).should eq(0.5)
    end
  end

  it "should return raise ArgumentError if offset is past max" do
    tempo_profile = Musicality::Profile.new :start_value => tempo(120)
    tc = Musicality::TempoComputer.new tempo_profile
    lambda { tc.notes_per_second_at(ValueComputer.domain_max + 1) }.should raise_error(ArgumentError)
  end

  context "two tempos, no transition" do
    before :each do
      tempo_profile = Musicality::Profile.new :start_value => tempo(120), :value_changes => {
        1.0 => Musicality::immediate_change(tempo(60))
      }
      @tc = Musicality::TempoComputer.new tempo_profile
    end

    it "should be the first (starting) tempo just before the second tempo" do
      @tc.notes_per_second_at(0.999).should eq(0.5)
    end
        
    it "should transition to the second tempo immediately" do
      @tc.notes_per_second_at(1.0).should eq(0.25)
    end

    it "should be the first tempo for all time before" do
      @tc.notes_per_second_at(ValueComputer.domain_min).should eq(0.5)
    end
    
    it "should be at the second tempo for all time after" do
      @tc.notes_per_second_at(ValueComputer.domain_max).should eq(0.25)
    end
  end

  context "two tempos, linear transition" do
    before :each do
      tempo_profile = Musicality::Profile.new :start_value => tempo(120), :value_changes => {
        1.0 => Musicality::linear_change(tempo(60), 1.0)
      }
      @tc = Musicality::TempoComputer.new tempo_profile
    end

    it "should be the first (starting) tempo just before the second tempo" do
      @tc.notes_per_second_at(0.999).should eq(0.5)
    end
        
    it "should be the first (starting) tempo exactly at the second tempo" do
      @tc.notes_per_second_at(1.0).should eq(0.5)
    end

    it "should be 1/4 to the second tempo after 1/4 transition duration has elapsed" do
      @tc.notes_per_second_at(Rational(5,4).to_f).should eq(Rational(7,16).to_f)
    end

    it "should be 1/2 to the second tempo after 1/2 transition duration has elapsed" do
      @tc.notes_per_second_at(Rational(6,4).to_f).should eq(Rational(3,8).to_f)
    end

    it "should be 3/4 to the second tempo after 3/4 transition duration has elapsed" do
      @tc.notes_per_second_at(Rational(7,4).to_f).should eq(Rational(5,16).to_f)
    end

    it "should be at the second tempo after transition duration has elapsed" do
      @tc.notes_per_second_at(Rational(8,4).to_f).should eq(0.25)
    end
  end
end
