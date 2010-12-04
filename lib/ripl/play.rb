require 'ripl'

module Ripl::Play
  VERSION = '0.2.0'

  def before_loop
    super
    play_back
    config[:play_quiet] = false
    require 'ripl/readline'
  end

  def print_result(*)
    super unless config[:play_quiet]
  end

  def get_input
    puts(prompt + @play_input)
    @play_input
  end

  def play_back
    if !$stdin.tty?
      play_back_string($stdin.read)
      $stdin.reopen '/dev/tty'
    elsif config[:play][/^http/]
      play_back_url(config[:play])
    elsif File.exists? config[:play]
      play_back_string(File.read(config[:play]))
    else
      abort "ripl can't play `#{config[:play]}'"
    end
  end

  def play_back_url(url)
    require 'open-uri'
    require 'net/http'

    if url[/gist.github.com\/[a-z\d]+$/]
      url += '.txt'
    elsif url[/github.com.*blob/]
      url.sub!('blob', 'raw')
    end

    play_back_string open(url).string
  rescue SocketError
    abort "ripl can't play `#{url}'"
  end

  def play_back_string(str)
    Ripl::Play.install_gems(str) if config[:play_install]
    str.split("\n").each {|input|
      @play_input = input
      loop_once
    }
  end

  class << self
    def install_gems(str)
      gems = gems_to_install(str)
      return if gems.empty?
      print "Can I install the following gems: #{gems.join(', ')} ? ([y]/n)"
      if $stdin.gets.to_s[/^n/]
        abort "Please install these gems manually: #{gems.join(' ')}"
      else
        system(ENV['GEM'] || 'gem', 'install', *gems)
      end
    end

    def gems_to_install(str)
      gems = str.scan(/require\s*['"]([^'"\s]+)['"]/).flatten
      gems.reject {|e| requireable(e) }.map {|e|
        e.include?('/') ? e[/^[^\/]+/] : e
      }.uniq.map {|e| e[/^active_/] ? e.sub('_', '') : e }
    end

    def requireable(lib)
      require lib
      true
    rescue LoadError
      false
    end
  end
end

Ripl::Shell.send :include, Ripl::Play
Ripl.config[:readline] = false
Ripl.config[:play] = 'ripl_tape'
