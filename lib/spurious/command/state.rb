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
        @exiting = false
      end

      def unbind
        unless @exiting
          app.say "[error] The spurious-server instance has died, start it again with: 'spurious-server start'", :red
          EventMachine.stop_event_loop
        end
      end

      def post_init
        send_data JSON.generate(:type => type)
      end

      def receive_data(data)
        data_parts = data.split("\n")
        data_parts.each do |data_part|
          parsed_data = JSON.parse(data_part.strip)
          output parsed_data
          if parsed_data['close']
            close_connection
          end
        end
      end

      def close_connection
        @exiting = true
        EventMachine.stop_event_loop
        exit
      end

      protected

      def output(data)
        message_type = data['message_type']
        if message_type != 'debug' || (message_type == 'debug' && app.options['debug_mode'] == 'true')
          app.say "[#{data['message_type']}] #{data['response']}", data['colour'].to_sym
        end
      end

    end
  end
end
