require 'mechanize'
require 'parallel'
class GetPic
  def initialize(url)
    puts "initializing......."
    @agent = Mechanize.new
    @url = url
    @picSet = []
    @count = 0
    @setCount = 0
    puts "init done"
  end

  def getPicSet
    @picSet
  end

  def downloadPic
    puts "begin task"
    getPicSetFrom(@url)
    @picSet.each do |picSet|
      getPicFromSet(picSet)
    end
    puts "total sum is #{@count}"
    puts "program done"
  end

  private
  def getPicSetFrom(url)
    puts "task <picSet add> begin"
    i = 1
    while(true)
      indexUrl = url + "#{i}.shtml"
      begin
      page = @agent.get(indexUrl)
      page.encoding = 'gb2312'
      rescue
        puts "task <picSet add> done"
        puts "the sum of picture set is #{@setCount}"
        break
      end
      page.css('ul.picList li p a').each do |link|
        @picSet.push(link['href'])
        @setCount += 1;
      end
      i += 1
    end
  end

  def getPicFromSet(picSetUrl)
    page = @agent.get(picSetUrl)
    page.encoding = 'gb2312'
    title = page.at_css('div.tit4 h3').text
    imgs = page.css('ul#picLists li a img')
    Parallel.each_with_index(imgs, in_threads: 4) do |img, index|
    # page.css('ul#picLists li a img').each do |img|
      getPicDataAndSave(img['src'], title, index)
    end
  end

  def getPicDataAndSave(picUrl, title, index)
    data = @agent.get(picUrl).body
    writePic(data, title, index)
    @count += 1
    puts "task <pic download>" + title + "#{index} #done #remain #{@setCount - @count}"
  end

  def writePic(data, title, index)
    begin
    File.open('./pic/' + title.sub + '/' + "#{index}.jpg", 'wb+') do |file|
      file.write(data)
    end
    rescue
      Dir.mkdir('./pic/' + title) unless File::directory?('./pic/' + title)
      retry
    end
  end

  def testWrite
    File.open('./allset.txt', 'w+') do |file|
      @picSet.each do |links|
        file.write(links + ';')
      end
    end
  end
  def testRead
    data = ''
    File.open('./allset.txt', 'r') do |file|
      data = file.gets
      @picSet = data.split(';')
    end
  end
end
