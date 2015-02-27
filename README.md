# Spurious

Spurious is a toolset allowing development against a subset of AWS resources, locally.

The services are run as Docker containers, and Spurious manages their lifecycle and 
linking so all you have to worry about is using the services.

To use Spurious, you'll need to change the endpoint and port for each AWS service to those provided by Spurious.

There are a number of supporting libraries that ease the configuration of the AWS SDKs.

## Supported services

Currently the following AWS services are supported by Spurious:

- S3 ([fake-s3](https://github.com/jubos/fake-s3))
- SQS ([fake_sqs](https://github.com/iain/fake_sqs))
- DynamoDB ([DynamoDB Local](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html))
- ElastiCache ([fake_elasticache](https://github.com/stevenjack/fake_elasticache))
- Spurious Browser ([spurious-browser](https://github.com/stevenjack/spurious-browser))

> The following services are actively in development:

- SNS
- CloudFormation (Allow you to create resources that there are already services for in Spurious).

## Requirements

Spurious works on the following platforms:

- OSX
- Linux
- Windows

### Dependencies

Spurious requires the following to be installed and started to work correctly:

- Ruby 1.9.* (or JRuby)
- Docker 1.0.*

## Installation

### Quick install

```bash
curl -L https://raw.github.com/stevenjack/spurious/master/tools/install.sh | sh
```

### Manual install

#### Docker

Each of the local services are run inside a Docker container, so without Docker, Spurious won't work.

As OSX doesn't currently have support for LXC containers natively, you need to run a VM that is capable
of providing this.

The quickest way to get Docker setup on OSX is with a combination of [homebrew](http://brew.sh/),
[boot2docker](https://github.com/boot2docker/boot2docker) and [VirutalBox](https://www.virtualbox.org/wiki/Downloads) (boot2docker currently only supports VirtualBox)

`brew install boot2docker docker`

Once you've installed both of these, run the following commands to start the boot2docker:

```bash
boot2docker	init
boot2docker up
```

Once the process has completed, you should be given an environment variable to export, make sure that this is exported before continuing, as Spurious makes use of this.

##### Alternative VM setup

Boot2docker is just one route of being able to run Docker containers from Mac OSX (which is limited by the fact it only supports VirtualBox). You can use a number of other virtual machines, just make sure you've exposed the Docker API and you can connect to the VM on its own IP address so you can construct the following environment variable:

```bash
DOCKER_HOST=tcp://{IP_OF_HOST:DOCKER_API_PORT}
```

#### Spurious

> Spurious is currently implemented in Ruby (move to [golang](http://golang.org/) is in progress) and so it requires you to install the Spurious CLI tools from a RubyGem

Add this line to your application's Gemfile:

    gem 'spurious'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spurious

This will install Spurious and give you the CLI tools for starting the server and interacting with it.

## Usage

Spurious is split up into two components, the CLI and the server. The server interacts with the Docker API and
controls the lifecycle of the containers. The CLI simply talks to the server and formats the responses for
the end user.

The server runs as a daemon and must be run before using the CLI. If it's not running, then the CLI will prompt you. To enter a directory.

To start the server, run:

```bash
spurious-server start
```

You can check the status of the server by running:

```bash
spurious-server status
```

and stop it with:

```bash
spurious-server stop
```

Once you've started the server you can start using the Spurious CLI tool. Run the following commands to get the
containers up and running:

```bash
spurious init
spurious up|boot|start
```

You should now have six containers running, which you can check with:

```bash
docker ps
```

### GUI

One of the services started by Spurious is the [browser](https://www.github.com/stevenjack/spurious-browser). This allows you to interact and manage the fake services from a graphical interface.

To access the browser service, enter the following command:

```bash
spurious ports
```

This should display output similar to:

```bash
Service                      Host                         Port   Browser link
spurious-dynamo              dynamodb.spurious.localhost  49255  http://dynamodb.spurious.localhost:49255
spurious-browser             browser.spurious.localhost   49259  http://browser.spurious.localhost:49259 <--- Link to browser
spurious-elasticache         192.168.59.103               49257  -
spurious-elasticache-docker  192.168.59.103               49258  -
spurious-memcached           192.168.59.103               49256  -
spurious-s3                  s3.spurious.localhost        49254  http://s3.spurious.localhost:49254
spurious-sqs                 sqs.spurious.localhost       49253  http://sqs.spurious.localhost:49253
```

You'll find the browser link next to the service `spurious-browser`.

### Using the containers

Once the containers are up and running, they're assigned random port numbers from Docker which are available on the ip address of the VM used to run the containers. To make the discovery of these ports simpler there's the following command:

```bash
spurious ports
```

This will return a list of host and port details for each of the Spurious containers. If you pass the flag `--json` you'll get the results back as a JSON string so you can then parse and use to automatically configure your chosen method of working with AWS (e.g. some of the helper libraries - see below - utilise this method).

### Debug mode

To enable debug output when running Spurious, either use the command line argument:

```bash
spurious init --debug-mode=true
```

Or set the `SPURIOUS_DEBUG` environment variable before running the `init` command:

```bash
SPURIOUS_DEBUG=true spurious init
```

### SDK Helpers

Once the containers are running you'll need to wire up the SDK to point to the correct endpoints and port numbers. Here's an example using the Ruby SDK:

```ruby
require 'json'

port_config = JSON.parse(`spurious ports --json`)

AWS.config(
  :region              => 'eu-west-1',
  :use_ssl             => false,
  :access_key_id       => "access",
  :secret_access_key   => "secret",
  :dynamo_db_endpoint  => port_config['spurious-dynamo']['Host'],
  :dynamo_db_port      => port_config['spurious-dynamo']['HostPort'],
  :sqs_endpoint        => port_config['spurious-sqs']['Host'],
  :sqs_port            => port_config['spurious-sqs']['HostPort'],
  :s3_endpoint         => port_config['spurious-s3']['Host'],
  :s3_port             => port_config['spurious-s3']['HostPort'],
  :s3_force_path_style => true
)
```

There are also helpers available for the different flavours of the AWS SDK:

#### Ruby

* [Ruby AWS SDK Helper](https://github.com/spurious-io/ruby-awssdk-helper)

#### Clojure

* [Clojure AWS SDK Helper](https://github.com/Integralist/spurious-clojure-aws-sdk-helper)

#### JavaScript

* [JS AWS SDK Helper](https://github.com/spurious-io/js-aws-sdk-helper) (In active development)

#### PHP/Java/Go...

> Coming soon

## Contributing

1. Fork it ( http://github.com/spurious-io/spurious/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
