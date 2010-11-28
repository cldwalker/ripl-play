require 'ripl'

module Ripl::Play
  def before_loop
    super
    play_back
  end

  def play_back
    if !$stdin.tty?
      play_back_string($stdin.read)
      $stdin.reopen '/dev/tty'
    elsif config[:play][/^http/]
      play_back_url
    elsif File.exists? config[:play]
      play_back_string(File.read(config[:play]))
    else
      abort "ripl can't play `#{config[:play]}'"
    end
  end

  def play_back_url
    require 'open-uri'
    play_back_string open(config[:play]).string
  rescue SocketError
    abort "ripl can't play `#{config[:play]}'"
  end

  def play_back_string(str)
    str.split("\n").each do |input|
      puts prompt + input
      eval_input(input)
      print_result(@result)
    end
  end
end

Ripl::Shell.send :include, Ripl::Play
Ripl.config[:play] = 'ripl_tape'
