
require 'mechanize'
require 'pry'
class LegacyObitFinder
  attr_reader :main_url, :date_range_option, :keyword, 
              :last_name, :first_name, :country_id, :state_id, 
              :obits, :per_page, :affiliate_id, :agent

  def initialize(args)
    @main_url           = args[:main_url] || "http://www.legacy.com/ns/obitfinder/obituary-search.aspx"
    @country_id         = "&countryid=#{args[:country_id] || usa_country_id}"
    @date_range_option  = "&daterange=#{args[:date_range] || "Last14Days"}"
    @keyword            = "&keyword=#{args[:keyword]}" if args[:keyword]
    @last_name          = "&lastname=#{args[:last_name]}" if args[:last_name]
    @first_name         = "&firstname=#{args[:first_name]}" if args[:first_name]
    @state_id           = "&stateid=#{args[:state_id]}" if args[:state_id]
    @affiliate_id       = "&affiliateid=#{args[:affiliate_id]}" if args[:affiliate_id]
    @per_page           = "&entriesperpage=50"
    @obits              = []
    @agent = Mechanize.new
    cookie = Mechanize::Cookie.new(:domain => 'www.legacy.com', 
                                   :name => "LegacySearchExpanded", 
                                   :value => '1', :path => '/ns/obitfinder/')
    agent.cookie_jar << cookie
  end

  def date_range_options
    ['Last14Days', 'Last24Hrs', 'Last3Days', 'Last30Days', 'Last6Mths', 'Last1Yrs', 'All']
  end

  def all_obits
   all_obit_pages
   obits.flatten
  end

  private
    def open_page(page_number)
      print "."
      @page = agent.get(search_string(page_number))
    end

    def all_obit_pages
      page_num = 1
      begin        
        if page_num == 1
          page_one = PageOneParser.new(open_page(page_num))
          results_total = page_one.results_total
          last_page = page_one.last_page
          obits << page_one.obits
        else
          obits << PageParser.new(open_page(page_num)).obits
        end
        page_num += 1
      end until page_num > last_page
    end

    def usa_country_id
      1
    end

    def search_string(page_number)
      "#{main_url}?Page=#{page_number}#{country_id}#{date_range_option}#{keyword}#{last_name}#{first_name}#{state_id}#{per_page}#{affiliate_id}"
    end
end

class PageParser
  attr_reader :results_total, :last_page, :obits, :page
  def initialize(page)
    @obits = []
    @page = page
    search("div.obitName a").each { |obit| @obits << Obituary.new(name(obit), link(obit)) }    
  end

  def search(element)
    page.search(element)
  end

  private
    def name(obit)
      obit.text
    end

    def link(obit)
      obit['href']
    end
end

class PageOneParser < PageParser  
  def initialize(page)
    @page = page
    results = search("div.ResultsHeader b")[2]
    @results_total = if results then results.text.to_i else 0 end
    @last_page = (results_total / 50.0).ceil
    super
  end
end

Obituary = Struct.new(:name, :link)