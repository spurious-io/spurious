require 'thor'
require 'docker'

module Spurious
  class App < Thor
    include Thor::Actions
    namespace :spurious

    # def self.start(given_args = ARGV, config = {})
    #   #@@docker_provider = docker_provider
    #   super(given_args = ARGV, config = {})
    # end

    desc "init", "Initialize the spurious containers"
    def init
      config = Spurious::Config.app[:images]

      config.each_key do |image|
        say "Pulling #{image} from the public repo...", :green
        Docker::Image.create('fromImage' => image)
      end
      say "#{config.length} containers successfully initialized"

    end

    desc "status", "The status of the spurious docker containerts"
    def status

    end

    desc "update", "Updates the spurious images and restarts the containers"
    def update

    end

    desc "stop", "Stops all spurious containers"
    def stop

    end

    desc "restart", "Restarts the spurious containers"
    def restart

    end

  end
end
