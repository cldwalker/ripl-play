require 'ripl'

module Ripl::Play
  def before_loop
    super
    play_back if File.exists? config[:play].to_s
  end

  def play_back
    File.read(config[:play]).split("\n").each do |input|
      puts prompt + input
      eval_input(input)
      print_result(@result)
    end
  end
end

Ripl::Shell.send :include, Ripl::Play
