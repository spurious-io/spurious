require 'eventmachine'
require 'json'
require 'thor'

module Spurious
  module Command
    class State < EventMachine::Connection
      attr_accessor :app
      attr_reader :type

      include Thor::Actions

      def initialize(type, app, *args)
        super
        @type = type
        @app = app
      end

      def post_init
        send_data JSON.generate(:type => type)
      end

      def receive_data(data)
        data_parts = data.split("\n")
        data_parts.each do |data_part|
          parsed_data = JSON.parse(data_part.strip)
          app.say parsed_data['response'], parsed_data['colour'].to_sym
          EventMachine.stop_event_loop if parsed_data['close']
        end

      end
    end
  end
end
