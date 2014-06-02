
require 'open-uri'
require 'nokogiri'

class LegacyObitFinder
  attr_reader :main_url, :date_range_option, :keyword, 
              :last_name, :first_name, :country_id, :state_id, 
              :obit_links, :per_page, :results_total, :last_page

  def initialize(args)
    @main_url           = args[:main_url] || "http://www.legacy.com/ns/obitfinder/obituary-search.aspx"
    @country_id         = "countryid=#{args[:country_id] || usa_country_id}"
    @date_range_option  = "&daterange=#{args[:date_range] || "Last30Days"}"
    @keyword            = "&keyword=#{args[:keyword]}" if args[:keyword]
    @last_name          = "&lastname=#{args[:last_name]}" if args[:last_name]
    @first_name         = "&firstname=#{args[:first_name]}" if args[:first_name]
    @state_id           = "&stateid=#{args[:state_id]}" if args[:state_id]
    @per_page           = "&entriesperpage=50"
    @obits              = []
  end

  def date_range_options
    ['Last14Days', 'Last24Hrs', 'Last3Days', 'Last30Days', 'Last6Mths', 'Last1Yrs', 'All']
  end

  def obits
   all_obit_pages
   @obits
  end

  private
    def obits_page(page_number)
      @page = Nokogiri::HTML(open(search_string + "Page=#{page_number}"))
    end

    def all_obit_pages
      page = 1
      @no_obits = false
      begin
        obits_page(page)
        if page == 1
          @results_total = @page.css("div.ResultsHeader b")[2].text.to_i || 0
          @last_page = (@results_total / 50.0).ceil
        end
        parse(page)
        page += 1
      end until page > last_page || @no_obits

    end

    def parse(page_number)
      obit_tags = @page.css("div.obitName a")
      @no_obits = true if obit_tags.count == 0
      require 'pry'; binding.pry
      obit_tags.each { |obit| @obits << Hash["#{name(obit)}" => "#{link(obit)}"] }      
    end   

    def name(obit)
      obit.text
    end

    def link(obit)
      obit[href]
    end

    def usa_country_id
      1
    end

    def search_string
      "#{main_url}?#{country_id}#{date_range_option}#{keyword}#{last_name}#{first_name}#{state_id}#{per_page}"
    end
end