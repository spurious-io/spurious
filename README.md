# Spurious

Spurious is a toolset allowing development against a subset of AWS resource, locally.

The services are run as docker containers, and spurious manages the lifecycle and 
linking so all you have to worry about is using the the services.

You change the endpoint and port for each service to those provided by spurious.

There are a number of supporting repos that ease the configuration of these SDKs.

## Supported services

Currently the following services are supported by spurious:

* S3 ([fake-s3](https://github.com/jubos/fake-s3))
* SQS ([fake_sqs](https://github.com/iain/fake_sqs))
* DynamoDB ([DynamoDB Local](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html))
* ElastiCache ([fake_elasticache](https://github.com/stevenjack/fake_elasticache))

> The following services are actively in development:

* Spurious Browser (A web based application much like the AWS Console allowing control 
  over the spurious services from a web interface).
* SNS
* CloudFormation (Allow you to create resources that there are already services for in spurious).

## Requirements

Spurious works on the following platforms:

* OSX
* Windows

> Support for linux will be available shortly.

### Dependencies

Spurious requires the following to be installed and started to work correctly:

* Ruby 1.9.*
* Docker 1.0.*

## Installation

### Quick install

For the quick install to work, make sure you have [homebrew](http://brew.sh/) installed then run the following:

```bash
curl -L https://raw.github.com/stevenjack/spurious/master/tools/install.sh | sh
```

### Manual install

#### Docker

Each of the local services are run inside a docker container, so without docker spurious won't work.
As OSX doesn't currently have support for LXC containers natively, you need to run a VM that is capable
of providing this.

The quickest way to get docker setup on OSX is with a combination of [homebrew](http://brew.sh/),
[boot2docker](https://github.com/boot2docker/boot2docker) and [VirutalBox](https://www.virtualbox.org/wiki/Downloads)
 (boot2docker currently only supports VirtualBox)

`brew install boot2docker docker`

Once you've installed both of these, run the following commands to start the boot2docker:

```bash
boot2docker	init
boot2docker up
```

Once the process has completed, you should be given an env variable to export, make sure that this is exported
before continuing as spurious makes use of this.

##### Alternative VM setup

Boot2docker is just one route of being able to run docker containers from your mac and as it only supports VirtualBox is 
a little limited. You can use a number of other virtual machines, just sure you've exposed the docker API and you can connectivity
to the VM on it's own IP address so you can construct the following en variable:

```bash
DOCKER_HOST=tcp://{IP_OF_HOST:DOCKER_API_PORT}
```

#### Spurious

Add this line to your application's Gemfile:

    gem 'spurious'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spurious


This will install spurious and give you the CLI tools for starting the server and interacting with it.

## Usage

Spurious is split up into two components, the cli and the server. The server interacts with the docker API and
controls the lifecycle of the containers. The CLI simply talks to the server and formats the responses for
the end user.

The server runs as a daemon and must be run before using the CLI, if it's not the CLI will prompt you. To run
enter in an directory:

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

Once you've started the server you can start using the spurious CLI tool. Run the following commands to get the
containers up and running:

```bash
spurious init
spurious up
```

You should now have 6 containers running which you can check with:

```bash
docker ps
```

### Using the containers

Once the containers are up and running, they're assigned random port numbers from docker which are available on the
ip address of the VM used to run the containers. To make the discovery of these ports simpler there's the following
command:

```bash
spurious ports
```

that returns the list of host and port details for each of the spurious containers. If you pass the flag --json you'll
get the result back as a JSON string so you can then parse this and use it to automatically configure your chosen method of working with AWS.

### SDK Helpers

Once the containers are running you'll need to wire up the SDK to point to the correct endpoints and port numbers. Here's
and example using the ruby SDK:

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

* [Spurious ruby AWS SDK Helper](https://github.com/stevenjack/spurious-ruby-awssdk-helper)


#### PHP/Java/Node.js

> Coming soon

## Contributing

1. Fork it ( http://github.com/stevenjack/spurious/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
