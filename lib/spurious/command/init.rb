require 'eventmachine'
require 'json'

module Spurious
  module Command
    class Init < EventMachine::Connection
      attr_accessor :app

      def initialize(app)
        super
        @app = app
        # stuff here...
      end


      def post_init
        send_data JSON.generate(:type => :init)
      end

      def receive_data(data)
        parsed_data = JSON.parse(data)
        if parsed_data['type'] != 'error'
          app.say parsed_data['response'], :green
        else
          app.say parsed_data['response'], :red
        end

      end
    end
  end
end
