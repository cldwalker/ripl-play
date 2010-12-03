require 'ripl'

module Ripl::Record
  def after_loop
    super
    saved_history = Array(history)
    saved_history.pop if Ripl::Shell::EXIT_WORDS.include?(saved_history[-1])
    saved_history = saved_history.reverse.slice(0, @line - 1).reverse
    File.open(config[:play], 'w') {|f| f.write saved_history.join("\n") }
  end
end

Ripl::Shell.send :include, Ripl::Record
Ripl.config[:play] = 'ripl_tape'
