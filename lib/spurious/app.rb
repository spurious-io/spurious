require 'thor'
require 'eventmachine'
require 'spurious/command/state'
require 'spurious/command/ports'
require 'timeout'

module Spurious
  class App < Thor
    include Thor::Actions

    namespace :spurious

    class_option :server_port, :type => :string, :default => ENV.fetch('SPURIOUS_SERVER_PORT', 4590), :desc => "The port of spurious server"
    class_option :server_ip, :type => :string, :default => ENV.fetch('SPURIOUS_SERVER_IP', 'localhost'), :desc => "The ip address of spurious server"
    def initialize(*args)
      super
    end

    def self.state_methods
      methods = {
        :init => {
          :aliases => []
          },
        :start => {
          :aliases => ["up", "boot"]
          },
        :update => {
          :aliases => []
          },
        :stop => {
          :aliases => ["down", "halt"]
          },
        :delete => {
          :aliases => []
          }
        }
      methods.each do |meth, options|
        desc meth.to_s, "#{meth} the spurious containers"
        define_method(meth) do
          event_loop meth
        end

        unless options[:aliases].empty? then
          options[:aliases].each do |alias_meth|
            desc alias_meth, "alias for `spurious #{meth}`"
            define_method(alias_meth) do
              event_loop meth
            end
          end
        end
      end
    end

    state_methods

    method_option :'json', :type => :boolean, :default => false, :desc => 'Prints out ports as a json string'
    desc "ports", "List ports for the spurious containers"
    def ports

      if server_available? then
        EventMachine.run do
            EventMachine::connect options[:server_ip], options[:server_port], Spurious::Command::Ports, :ports, self
        end
      end
    end

    protected

    def server_available?
      available = true

      Timeout.timeout(1) do
        begin
          TCPSocket.new(options[:server_ip], options[:server_port])
        rescue Exception
          available = false
          say <<-eos

#{set_color("Connection to spurious server: #{options[:server_ip]}:#{options[:server_port]} has timed out.", :red)}

#{set_color('To check the status of the server, run:', :white)}
#{set_color('$ spurious-server status', :cyan)}

#{set_color('To start the server, run:', :white)}
#{set_color('$ spurious-server start', :cyan)}

          eos
        end
      end

      available

    end


    def event_loop(type)

      if server_available? then
        EventMachine.run do
            EventMachine::connect options[:server_ip], options[:server_port], Spurious::Command::State, type, self
        end
      end

    end
  end
end
