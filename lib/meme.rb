require 'net/http'
require 'rubygems'
require 'nokogiri'
require 'cgi'

##
# Generate memes using http://memegenerator.net

class Meme

  ##
  # Sometimes your meme will have an error, fix it!

  class Error < RuntimeError; end

  ##
  # Every meme generator needs a version

  VERSION = '1.0'

  ##
  # For statistics!

  USER_AGENT = "meme/#{VERSION} Ruby/#{RUBY_VERSION}"

  ##
  # We have some generators up-in-here

  GENERATORS = Hash.new do |_, k|
    raise Error, "unknown generator #{k}"
  end

  GENERATORS['Y_U_NO']        = [165241, 'Y-U-NO', 'Y U NO']
  GENERATORS['B_FROG']        = [1211,   'Foul-Bachelorette-Frog']
  GENERATORS['PHILOSORAPTOR'] = [984,    'Philosoraptor']

  ##
  # Interface for the executable

  def self.run argv = ARGV
    generator = ARGV.shift

    if generator == '--list' then
      width = GENERATORS.keys.map { |command| command.length }.max

      GENERATORS.each do |command, (id, name, _)|
        puts "%-*s    %s" % [width, command, name]
      end

      exit
    end

    line1     = ARGV.shift
    line2     = ARGV.shift

    abort "#{$0} GENERATOR LINE [LINE]" unless line1

    meme = new generator
    link = meme.generate line1, line2

    meme.paste link

    puts link
  end

  ##
  # Generates links for +generator+

  def initialize generator
    @template_id, @generator_name, @default_line = GENERATORS[generator]
  end

  ##
  # Generates a meme with +line1+ and +line2+.  For some generators you only
  # have to supply one line because the first line is defaulted for you.
  # Isn't that great?

  def generate line1, line2 = nil
    url = URI.parse 'http://memegenerator.net/Instance/CreateOrEdit'
    res = nil
    location = nil

    unless line2 then
      line2 = line1
      line1 = @default_line
    end

    raise Error, "must supply both lines for #{generator_name}" unless line1

    Net::HTTP.start url.host do |http|
      post = Net::HTTP::Post.new url.path
      post['User-Agent'] = USER_AGENT
      post.set_form_data('templateType'  => 'AdviceDogSpinoff',
                         'text0'         => line1,
                         'text1'         => line2,
                         'templateID'    => @template_id,
                         'generatorName' => @generator_name)

      res = http.request post

      location = res['Location']
      redirect = url + location

      get = Net::HTTP::Get.new redirect.request_uri
      get['User-Agent'] = USER_AGENT

      res = http.request get
    end

    doc = Nokogiri.HTML res.body
    doc.css("a[href=\"#{location}\"] img").first['src']
  end

  ##
  # Puts +link+ in your clipboard, if you're on OS X, that is.

  def paste link
    IO.popen 'pbcopy', 'w' do |io| io.write link end
  end

end

