class HtmlFile
  attr_reader :hash, :fileHtml, :obits
  def initialize(obits)
    @obits = obits
    File.delete("obit_results.html") if File.exists?("obit_results.html")
    @fileHtml = File.new("obit_results.html", "w+")
  end

  def create
    before_table_rows
    obits.each { |obit| table_row(obit)}
    after_table_rows

    system("start obit_results.html") #...on windows
  end

  private
    def before_table_rows
      fileHtml.puts "<HTML><BODY>"
      fileHtml.puts "<CENTER>Obituaries</CENTER><br>"
      fileHtml.puts "<TABLE BORDER='1' ALIGN='center'>"
      fileHtml.puts "<TR><TH>Name</TH></TR>"
    end

    def after_table_rows
       fileHtml.puts "</TABLE>"
      fileHtml.puts "</BODY></HTML>"
      fileHtml.close()
    end

    def table_row(obit)
      fileHtml.puts "<TR><TD><a href=#{obit.link}>#{obit.name}</TD></TR>"
    end

end