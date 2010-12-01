require 'ripl'

module Ripl::Play
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
    str.split("\n").each {|input|
      @play_input = input
      loop_once
    }
  end
end

Ripl::Shell.send :include, Ripl::Play
Ripl.config[:readline] = false
Ripl.config[:play] = 'ripl_tape'
