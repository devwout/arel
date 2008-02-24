require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

module ActiveRelation
  describe Relation do
    before do
      @relation = Table.new(:users)
      @attribute1 = @relation[:id]
      @attribute2 = @relation[:name]
    end
  
    describe '[]' do
      describe 'when given a', Range do
        it "manufactures a range relation when given a range" do
          @relation[1..2].should == Range.new(@relation, 1..2)
        end
      end
      
      describe 'when given an', Attribute do
        it "return the attribute congruent to the provided attribute" do
          @relation[@attribute1].should == @attribute1
        end
      end
      
      describe 'when given a', Symbol, String do
        it "returns the attribute with the same name, if it exists" do
          @relation[:id].should == @attribute1
          @relation['id'].should == @attribute1
          @relation[:does_not_exist].should be_nil
        end
      end
    end
  
    describe '#include?' do
      it "manufactures an inclusion predicate" do
        @relation.include?(@attribute1).should be_kind_of(RelationInclusion)
      end
    end
    
    describe '#Expression?' do
      it "returns false" do
        @relation.should_not be_aggregation
      end
    end

    describe 'read operations' do
      describe 'joins' do
        before do
          @predicate = @relation[:id].equals(@relation[:id])
        end
      
        describe '#join' do
          it "manufactures an inner join operation between those two relations" do
            @relation.join(@relation).on(@predicate).should == Join.new("INNER JOIN", @relation, @relation, @predicate)
          end
        end
    
        describe '#outer_join' do
          it "manufactures a left outer join operation between those two relations" do
            @relation.outer_join(@relation).on(@predicate).should == Join.new("LEFT OUTER JOIN", @relation, @relation, @predicate)
          end      
        end
      end
  
      describe '#project' do
        it "manufactures a projection relation" do
          @relation.project(@attribute1, @attribute2).should == Projection.new(@relation, @attribute1, @attribute2)
        end
      end
    
      describe '#as' do
        it "manufactures an alias relation" do
          @relation.as(:thucydides).should == Alias.new(@relation, :thucydides)
        end
      end
  
      describe '#rename' do
        it "manufactures a rename relation" do
          @relation.rename(@attribute1, :users).should == Rename.new(@relation, @attribute1 => :users)
        end
      end
  
      describe '#select' do
        before do
          @predicate = Equality.new(@attribute1, @attribute2)
        end
    
        it "manufactures a selection relation" do
          @relation.select(@predicate).should == Selection.new(@relation, @predicate)
        end
    
        it "accepts arbitrary strings" do
          @relation.select("arbitrary").should == Selection.new(@relation, "arbitrary")
        end
      end
  
      describe '#order' do
        it "manufactures an order relation" do
          @relation.order(@attribute1, @attribute2).should == Order.new(@relation, @attribute1, @attribute2)
        end
      end
      
      describe '#aggregate' do
        it 'manufactures a group relation' do
          @relation.aggregate(@expression1, @expression2).group(@attribute1, @attribute2). \
            should == Aggregation.new(@relation, :expressions => [@expresion, @expression2], :groupings => [@attribute1, @attribute2])
        end
      end
    end
  
    describe 'write operations' do
      describe '#delete' do
        it 'manufactures a deletion relation' do
          @relation.delete.should be_kind_of(Deletion)
        end
      end
    
      describe '#insert' do
        it 'manufactures an insertion relation' do
          @relation.insert(record = {:id => 1}).should be_kind_of(Insertion)
        end
      end
    end
  end
end