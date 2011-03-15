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

  VERSION = '1.3'

  ##
  # For statistics!

  USER_AGENT = "meme/#{VERSION} Ruby/#{RUBY_VERSION}"

  ##
  # We have some generators up-in-here

  GENERATORS = Hash.new do |_, k|
    raise Error, "unknown generator #{k}"
  end

  GENERATORS['Y_U_NO']            = [165241, 'Y-U-NO', 'Y U NO']
  GENERATORS['B_FROG']            = [1211,   'Foul-Bachelorette-Frog']
  GENERATORS['B_FROG2']           = [1045,   'Foul-Bachelor-Frog']
  GENERATORS['PHILOSORAPTOR']     = [984,    'Philosoraptor']
  GENERATORS['I_WOLF']            = [926,    'Insanity-Wolf']
  GENERATORS['C_WOLF']            = [931,    'Courage-Wolf']
  GENERATORS['G_GRANDPA']         = [185650, 'Grumpy-Grandpa']
  GENERATORS['S_AWKWARD_PENGUIN'] = [983,    'Socially-Awkward-Penguin']
  GENERATORS['A_DOG']             = [940,    'Advice-Dog']
  GENERATORS['J_DUCREUX']         = [1356,   'Joseph-Ducreux']
  GENERATORS['XZIBIT']            = [3114,   'XZIBIT']
  GENERATORS['TROLLFACE']         = [1030,   'Troll-Face']
  GENERATORS['A_DODSON']          = [106375, 'Antoine-Dodson']
  GENERATORS['P_OAK']             = [24321,  'Professor-Oak']
  GENERATORS['OBAMA']             = [1332,   'Obama-']
  GENERATORS['SPARTA']            = [1013,   'sparta']
  GENERATORS['TOWNCRIER']         = [434537, 'Towncrier']
  GENERATORS['H_MERMAID']         = [405224, 'Hipster-Mermaid']
  GENERATORS['SCUMBAG']           = [364688, 'Scumbag-Steve']
  GENERATORS['I_DONT_ALWAYS']     = [38926,  'The-Most-Interesting-Man-in-the-World']
  GENERATORS['BUTTHURT_DWELLER']  = [1438, 'Butthurt-Dweller']

  ##
  # Looks up generator name

  def GENERATORS.match(name)
    # TODO  meme Y U NO DEMETAPHONE?
    return self[name] if has_key? name
    matcher = Regexp.new(name, Regexp::IGNORECASE)
    _, generator = find { |k,v| matcher =~ k || v.grep(matcher).any? }
    generator || self[name] # raises the error if generator is nil
  end

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

    abort "#{$0} [GENERATOR|--list] LINE [LINE]" unless line1

    meme = new generator
    link = meme.generate line1, line2

    meme.paste link

    if $stdout.tty?
      puts link
    else
      puts meme.fetch link
    end
    link
  rescue Interrupt
    exit
  rescue SystemExit
    raise
  rescue Exception => e
    abort "ERROR: #{e.message} (#{e.class})"
  end

  ##
  # Generates links for +generator+

  def initialize generator
    @template_id, @generator_name, @default_line = GENERATORS.match generator
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

    raise Error, "two lines are required for #{@generator_name}" unless line1

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

  def fetch link
    url = URI.parse link
    res = nil

    Net::HTTP.start url.host do |http|
      get = Net::HTTP::Get.new url.request_uri
      get['User-Agent'] = USER_AGENT

      res = http.request get
    end
    res.body
  end

  ##
  # Tries to find clipboard copy executable and if found puts +link+ in your
  # clipboard.

  def paste link
    clipboard = %w{
      /usr/bin/pbcopy
      /usr/bin/xclip
    }.find { |path| File.exist? path }

    if clipboard
      IO.popen clipboard, 'w' do |io| io.write link end
    end
  end

end

