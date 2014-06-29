require 'helper'

describe Spurious::App do

  describe "#init" do

    it 'Pulls the correct images down' do
      docker_provider = double('Docker::Image', :pull => false)
      allow(Docker::Image).to receive(:create).twice.and_return(true)
      allow(Spurious::Config).to receive(:app).and_return({:images => {:item1 => nil, :item2 => nil}})

      args = %w[init]
      content = capture(:stdout) { Spurious::App.start args }

      expect(content).to match(/2 containers successfully initialized/)

    end

  end
end
