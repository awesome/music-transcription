require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Musicality::Part do
  context '.new' do
    its(:start_offset) { should eq(0) }
    its(:notes) { should be_empty }
    
    it "should assign loudness_profile profile given during construction" do
      loudness_profile = Profile.new(
        :start_value => 0.5,
        :value_changes => {
          1.0 => Musicality::linear_change(1.0, 2.0)
        }
      )
      part = Musicality::Part.new :loudness_profile => loudness_profile
      part.loudness_profile.should eq(loudness_profile)
    end  
    
    it "should assign notes given during construction" do
      notes = [
        {
          :duration => 0.25,
          :intervals => [
            { :pitch => C1 },
            { :pitch => D1 },
          ]
        }
      ]
      
      part = Musicality::Part.new :notes => notes
      part.notes.should eq(notes)
    end
    
    context 'file_path given' do
      
      before :all do
        @part_hash = {
          :notes => [
            { :duration => 0.25,
              :intervals => [
                { :pitch => C1 },
                { :pitch => D1 } ]
            },
            { :duration => 0.125,
              :intervals => [
                { :pitch => E2 } ]
            },
          ],
          :loudness_profile => {
            :start_value => 0.6
          }
        }
        
        @path = 'temp.yml'
      end
      
      context 'hash of part stored in YAML file' do
        it 'should load part from file' do
          File.open(@path, 'w') do |file|
            file.write @part_hash.to_yaml
          end
          part = Part.new @part_hash
          part_from_file = Part.new(:file_path => @path)
          part_from_file.should eq part
        end
      end

      context 'part stored in YAML file' do
        it 'should load part from file' do
          part = Part.new @part_hash
          File.open(@path, 'w') do |file|
            file.write part.to_yaml
          end
          part_from_file = Part.new(:file_path => @path)
          part_from_file.should eq part
        end
      end
      
      after :all do
        File.delete @path
      end
    end
  end
  
end
