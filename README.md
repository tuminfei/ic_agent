# IcAgent

## Ruby Agent Library for the Internet Computer

`ic_agent` provides basic modules to interact with canisters on the DFINITY Internet Computer.


## Installation

```
gem install ic_agent
```

### Features

1. candid types encode & decode
2. support secp256k1 & ed25519 identity, pem file import
3. canister DID file parsing
4. canister class, initialized with canister id and DID file
5. common canister interfaces: ledger, management, nns, cycles wallet
6. async support

### Modules & Usage

#### 1. Principal

Create an instance:

```ruby
require "lib/ic_agent/principal"
p = IcAgent::Principal() # default is management canister id `aaaaa-aa`
p1 = IcAgent::Principal(bytes=b'') # create an instance from bytes
p2 = IcAgent::Principal.anonymous() # create anonymous principal
p3 = IcAgent::Principal.self_authenticating(pubkey) # create a principal from public key
p4 = IcAgent::Principal.from_str('aaaaa-aa') # create an instance from string
p5 = IcAgent::Principal.from_hex('xxx') # create an instance from hex
```

Class methods:

```ruby
p.bytes # principal bytes
p.len # byte array length
p.to_str() # convert to string
```

#### 2. Identity

Create an instance:

```ruby
require "lib/ic_agent/indentity"
i = IcAgent::Identity.new # create an identity instance, key is randomly generated
i1 = IcAgent::Identity.new(privkey = "833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42") # create an instance from private key
```

Sign a message and Verify:

```ruby
msg = "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f"
sig = i.sign(msg) # sig = (der_encoded_pubkey, signature)
ver = i.verify(msg, sig[1])
```

#### 3. Client

Create an instance:

```ruby
client = IcAgent::Client.new(url = "https://ic0.app")
client.status
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ic_agent. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ic_agent/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the IcAgent project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ic_agent/blob/main/CODE_OF_CONDUCT.md).
