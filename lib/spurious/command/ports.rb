require 'eventmachine'
require 'json'
require 'spurious/command/state'
require 'spurious/app'

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
              interpolate_host(mapping_data["Host"]),
              mapping_data["HostPort"]
            ]
          end
        end

        if app.options[:json]
          app.say JSON.generate(parsed_data['response'])
        else
          app.say "\n"
          app.print_table(
            build_table(['Service', 'Host', 'Port'], data)
          ) unless parsed_data['response'].empty?

        end
        EventMachine.stop_event_loop if parsed_data['close']

      end

      def interpolate_host(reported_host)
        app.options[:server_host] != Spurious::App::DEFAULT_HOST ? app.options[:server_host] : reported_host
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
