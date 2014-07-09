require 'eventmachine'
require 'json'
require 'spurious/command/state'

module Spurious
  module Command
    class Ports < State

      def receive_data(data)
        parsed_data = JSON.parse(data.strip)
        data = []
        parsed_data['response'].each do |type, mapping|
          mapping.each do |mapping_data|
            data << [
              type,
              mapping_data["GuestPort"],
              mapping_data["HostPort"]
            ]
          end
        end

        if app.options[:json]
          app.say JSON.generate(parsed_data['response'])
        else
          app.say "\n"
          app.print_table(
            build_table(['Service', 'Guest port', 'Host port'], data)
          ) unless parsed_data['response'].empty?

        end
        EventMachine.stop_event_loop if parsed_data['close']

      end

      def build_table(headers, data)
        [].tap do |table|
          table << headers.reduce([]) do |array, header|
            array << app.set_color(header, :cyan)
          end

          data.each do |items|
            table << items.map { |item| app.set_color(item, :white) }
          end
        end
      end

    end
  end
end
