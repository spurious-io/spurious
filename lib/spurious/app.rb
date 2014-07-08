require 'thor'
require 'eventmachine'
require 'spurious/command/init'

module Spurious
  class App < Thor
    include Thor::Actions
    namespace :spurious

    desc "init", "Initialize the spurious containers"
    def init
      EventMachine.run {
          EventMachine::connect '127.0.0.1', 4590, Spurious::Command::Init, self
      }
    end

  end
end
