require 'spec_helper'

describe EmailFinder::EmailResolver do
  let!(:domain){"unitedsciencecorp.com"}
  let!(:subject){EmailFinder::EmailResolver.new(domain)}

  context "pattern_index" do
    it 'returns the index of the matching email patter' do
      expect(subject.pattern_index).to eq 8 # dfryer
    end
  end
end
