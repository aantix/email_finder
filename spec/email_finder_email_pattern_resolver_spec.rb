require 'spec_helper'

describe EmailFinder::EmailPatternResolver do
  let!(:username){"jjones"}
  let!(:subject){EmailFinder::EmailPatternResolver.new(username)}
  let!(:klass){EmailFinder::EmailPatternResolver}

  context "first_names" do
    let!(:names){subject.send(:first_names)}

    it 'reads in the names' do
      expect(names).to be_a(Array)
      expect(names).to_not be_empty
    end
  end

  context "#name_for" do
    it "renders the username given the first and last name" do
      expect(klass.name_for('Jim', 'Jones', '<%= first_name %><%= last_name %>')).to eq 'JimJones'
      expect(klass.name_for('Jim', 'Jones', '<%= last_name %>.<%= first_name %>')).to eq 'Jones.Jim'
    end
  end

  context "pattern" do
    it "returns a first_name, last_name username pattern" do
      expect(EmailFinder::EmailPatternResolver.new('JimJones').pattern).to eq("<%= first_name %><%= last_name %>")
      expect(EmailFinder::EmailPatternResolver.new('JonesJim').pattern).to eq("<%= last_name %><%= first_name %>")
      expect(EmailFinder::EmailPatternResolver.new('jjones').pattern).to eq("<%= first_name[0..0] %><%= last_name %>")

      expect(EmailFinder::EmailPatternResolver.new('jim.jones').pattern).to eq("<%= first_name %>.<%= last_name %>")
      expect(EmailFinder::EmailPatternResolver.new('jones_jim').pattern).to eq("<%= last_name %>_<%= first_name %>")
    end
  end
end
