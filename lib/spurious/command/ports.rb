require 'eventmachine'
require 'json'
require 'spurious/command/state'

module Spurious
  module Command
    class Ports < State

      def receive_data(data)
        parsed_data = JSON.parse(data.strip)
        data = []

        if parsed_data['response'].is_a? String
          @exiting = true
          app.say "[error] #{parsed_data['response']}", :red
          close_connection
        end

        parsed_data['response'].each do |type, mapping|
          mapping.each do |mapping_data|
            data << [
              type,
              mapping_data["Host"],
              mapping_data["HostPort"],
              mapping_data["Host"].include?("spurious") ? "http://#{mapping_data["Host"]}:#{mapping_data["HostPort"]}" : '-'
            ]
          end
        end

        if data.length == 0
          app.say "[error] Spurious services haven't been started, please run 'spurious start'", :red
          close_connection
        end

        if app.options[:json]
          app.say JSON.generate(parsed_data['response'])
        else
          app.say "\n"
          app.print_table(
            build_table(['Service', 'Host', 'Port', 'Browser link'], data)
          ) unless parsed_data['response'].empty?

        end
        if parsed_data['close']
          close_connection
        end

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
