require 'legacy_obitfinder'


describe LegacyObitFinder do

  it "should have class LegacyObitFinder" do
    LegacyObitFinder.new({})
  end

  it "should return date range" do
    expect(LegacyObitFinder.new(date_range: "new_range").date_range_option).to eql('&daterange=new_range')
  end

  it "should return keyword" do
    expect(LegacyObitFinder.new(keyword: "keyword").keyword).to eql('&keyword=keyword')
  end

  it "should return lastname" do
    expect(LegacyObitFinder.new(last_name: "lastname").last_name).to eql('&lastname=lastname')
  end

  it "should return firstname" do
    expect(LegacyObitFinder.new(first_name: "firstname").first_name).to eql('&firstname=firstname')
  end

  it "should return stateid" do
    expect(LegacyObitFinder.new(state_id: "stateid").state_id).to eql('&stateid=stateid')
  end

  it "should return countryid" do
    expect(LegacyObitFinder.new(country_id: "countryid").country_id).to eql('countryid=countryid')
  end
end