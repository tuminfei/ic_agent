# IcAgent

## Ruby Agent Library for the Internet Computer

`ic_agent` provides basic modules to interact with canisters on the DFINITY Internet Computer.


## Installation

```
gem install ic_agent
```

### Features

1. principal create and generate
2. candid types encode & decode
3. support secp256k1 & ed25519 identity
4. canister DID file parsing
5. canister class, initialized with canister id and DID file
6. common canister interfaces: ledger, management, nns, cycles wallet
7. BLS Verify

### Modules & Usage

#### 1. Principal

Create an instance:

```ruby
require "lib/ic_agent/principal"
p = IcAgent::Principal.new # default is management canister id `aaaaa-aa`
p1 = IcAgent::Principal.new(bytes: '') # create an instance from bytes
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
require "lib/ic_agent/identity"
i = IcAgent::Identity.new # create an identity instance, key is randomly generated
i1 = IcAgent::Identity.new(privkey = '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42') # create an instance from private key
i2 = IcAgent::Identity.new(privkey = '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42', type = 'secp256k1')
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

#### 4. Candid

Encode parameters:

```ruby
# params is an array, return value is encoded bytes
params = [{'type': IcAgent::Candid::BaseTypes.nat, 'value': 10}]
data = IcAgent::Candid.encode(params)

params = [{'type': IcAgent::Candid::BaseTypes.null, 'value': nil}]
data = IcAgent::Candid.encode(params)
```

Decode parameters:

```ruby
# data is bytes, return value is an parameter array
params =  IcAgent::Candid.decode(data)
```

#### 5. Agent

Create an instance:

```ruby
# Identity and Client are dependencies of Agent
iden = IcAgent::Identity.new
client = IcAgent::Client.new
agent = IcAgent::Agent.new(iden, client)
```

Query call:

```ruby
# query the name of token canister `gvbup-jyaaa-aaaah-qcdwa-cai`
name = agent.query_raw("gvbup-jyaaa-aaaah-qcdwa-cai", "name", IcAgent::Candid.encode([]))
```

Update call:

```ruby
# transfer 100 token to blackhole address `aaaaa-aa`
params = [
  { 'type': IcAgent::Candid::BaseTypes.principal, 'value': 'aaaaa-aa' },
  { 'type': IcAgent::Candid::BaseTypes.nat, 'value': 10000000000 }
]
result = agent.update_raw("gvbup-jyaaa-aaaah-qcdwa-cai", "transfer", IcAgent::Candid.encode(params))
```

#### 6. Read System State

Create an instance:

```ruby
# Identity and Client are dependencies of Agent
iden = IcAgent::Identity.new
client = IcAgent::Client.new
agent = IcAgent::Agent.new(iden, client)

time = IcAgent::SyetemState.time(agent, "gvbup-jyaaa-aaaah-qcdwa-cai")

subnet_public_key = IcAgent::SyetemState.subnet_public_key(agent, "gvbup-jyaaa-aaaah-qcdwa-cai", "pjljw-kztyl-46ud4-ofrj6-nzkhm-3n4nt-wi3jt-ypmav-ijqkt-gjf66-uae")
```

#### 7. Canister

Create a canister instance with candid interface file and canister id, and call canister method with canister instance:

```ruby
agent = IcAgent::Agent.new(iden, client)
gov_canister_id = 'rrkah-fqaaa-aaaaa-aaaaq-cai'
gov_didl = <<~DIDL_DOC
      // type
      type AccountIdentifier = record { hash : vec nat8 };
      type Action = variant {
        RegisterKnownNeuron : KnownNeuron;
        ManageNeuron : ManageNeuron;
        ExecuteNnsFunction : ExecuteNnsFunction;
        RewardNodeProvider : RewardNodeProvider;
        SetDefaultFollowees : SetDefaultFollowees;
        RewardNodeProviders : RewardNodeProviders;
        ManageNetworkEconomics : NetworkEconomics;
        ApproveGenesisKyc : ApproveGenesisKyc;
        AddOrRemoveNodeProvider : AddOrRemoveNodeProvider;
        Motion : Motion;
      };
      ......
DIDL_DOC

gov_canister = IcAgent::Canister.new(agent, gov_canister_id, gov_didl)
res = gov_canister.get_neuron_ids()
```

#### 8. canister: ledger, management, cycles wallet ..

canister common tools:

```ruby
ledger = IcAgent::Common::Ledger.new
ledger.canister.name()
```

## UNIT TEST

```
bundle exec rspec  
```

## Docker

1. update to latest image

`docker pull tuminfei1981/ruby_ic_agent:latest`

2. Run image:

`docker run -it tuminfei1981/ruby_ic_agent:latest`

This  will enter the container with a linux shell opened.

```shell
/usr/src/app # 
```

3. Type `rspec` to run all tests

```shell
/usr/src/app # bundle exec rspec
.............................

Finished in 5.56 seconds (files took 0.12067 seconds to load)
29 examples, 0 failures

```

4. Or, type `./bin/console` to enter the ruby interactive environment and run any ic_agent code

```shell
/usr/src/app # ./bin/console
[1] pry(main)> p = IcAgent::Principal.new
=> #<IcAgent::Principal:0x000000013a54a548 @bytes="", @hex="", @is_principal=true, @len=0>
[2] pry(main)> p.to_s
=> "aaaaa-aa"
[3] pry(main)>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tuminfei/ic_agent. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tuminfei/ic_agent/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the IcAgent project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tuminfei/ic_agent/blob/main/CODE_OF_CONDUCT.md).
