require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TimeScore do
  before :each do
    @parts = { "piano (LH)" => Samples::SAMPLE_PART }
    @program = Program.new [0...0.75, 0...0.75]
  end
  
  describe '.new' do
    context "no args given" do
      let(:score) { TimeScore.new }
      subject { score }
      its(:program) { should eq(Program.new) }
      its(:parts) { should be_empty }
    end
    
    context 'args given' do
      it "should assign parts given during construction" do
        score = TimeScore.new :program => @program, :parts => @parts
        score.parts.should eq(@parts)
      end
      
      it "should assign program given during construction" do
        score = TimeScore.new :program => @program
        score.program.should eq(@program)
      end      
    end
  end
end

describe TempoScore do
  before :each do
    @parts = { "piano (LH)" => Samples::SAMPLE_PART }
    @program = Program.new [0...0.75, 0...0.75]
    @tempo_profile = Profile.new(Tempo.new(120), 0.5 => linear_change(Tempo.new(60), 0.25))
  end
  
  describe '.new' do
    it "should assign tempo profile given during construction" do
      score = TempoScore.new @tempo_profile
      score.tempo_profile.should eq(@tempo_profile)
    end
    
    it "should assign part and program given during construction" do
      score = TempoScore.new @tempo_profile, parts: @parts, program: @program
      score.parts.should eq(@parts)
      score.program.should eq(@program)
    end
  end
end
