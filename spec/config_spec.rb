require 'helper'

describe Spurious::Config do

  describe ".app" do

    it 'Loads the config' do
      expect(Spurious::Config.app[:images]["bbcnews/fake-sqs".to_sym]).to eq({:port => 4568, :name => 'spurious-sqs'})

    end

  end
end
