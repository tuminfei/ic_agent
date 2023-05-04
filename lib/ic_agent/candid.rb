require 'leb128'
require 'ctf_party'
require 'securerandom'
require 'digest'
require 'stringio'
require 'ruby_enum'

module IcAgent
	class Candid
		class TypeIds
			include Ruby::Enum
			include IcAgent::Utils
			
			define :Null, -1
			define :Bool, -2
			define :Nat, -3
			define :Int, -4
			define :Nat8, -5
			define :Nat16, -6
			define :Nat32, -7
			define :Nat64, -8
			define :Int8, -9
			define :Int16, -10
			define :Int32, -11
			define :Int64, -12
			define :Float32, -13
			define :Float64, -14
			define :Text, -15
			define :Reserved, -16
			define :Empty, -17
			define :Opt, -18
			define :Vec, -19
			define :Record, -20
			define :Variant, -21
			define :Func, -22
			define :Service, -23
			define :Principal, -24
		end
		
		PREFIX = 'DIDL'
	
		class TypeTable
			attr_accessor :typs, :idx
	
			def initialize
				@typs = []
				@idx = {}
			end
			
			def has(obj)
				return @idx.has_key?(obj.name)
			end
			
			def add(obj, buf)
				idx = @typs.length
				@idx[obj.name] = idx
				@typs.append(buf)
			end
			
			def merge(obj, knot)
				idx = self.has(obj) ? @idx[obj.name] : nil
				knot_idx = @idx.has_key?(knot) ? @idx[knot] : nil
				if idx == nil
					raise ValueError, "Missing type index for " + obj.name
				end
				if knot_idx == nil
					raise ValueError, "Missing type index for " + knot
				end
				@typs[idx] = @typs[knot_idx]
				#delete the type
				@typs.delete_at(knot_idx)
				@idx.delete(knot)
			end
	
			def encode
				l = 0
				@typs.each do |t|
					if t.length != 0
					l += 1
					end
				end
	
				length = LEB128.encode_signed(l).string
				buf = @typs.join("")
				return "#{length}#{buf}"
			end
			
			def index_of(type_name)
				if !@idx.has_key?(type_name)
					raise ValueError, "Missing type index for " + type_name
				end
				return LEB128.encode_signed(@idx[type_name] | 0).string
			end
		end
	
		# Represents an IDL type.
		class BaseType
			def display
				return self.name
			end
			
			def build_type_table(type_table)
				if !type_table.has(self)
					self._build_type_table_impl(type_table)
				end
			end
			
			def self.covariant
				raise NotImplementedError, "subclass must implement abstract method"
			end
			
			def self.decode_value
				raise NotImplementedError, "subclass must implement abstract method"
			end
			
			def self.encode_type
				raise NotImplementedError, "subclass must implement abstract method"
			end
			
			def self.encode_value
				raise NotImplementedError, "subclass must implement abstract method"
			end
			
			def self.check_type
				raise NotImplementedError, "subclass must implement abstract method"
			end
			
			def self._build_type_table_impl(type_table=nil)
				raise NotImplementedError, "subclass must implement abstract method"
			end
		end
	
		class PrimitiveType < BaseType
			def initialize
				super
			end
			
			def check_type(t)
				if self.name != t.name
					raise ValueError, "type mismatch: type on the wire #{t.name}, expect type #{self.name}"
				end
				return t
			end
			
			def _build_type_table_impl(type_table=nil)
				# No type table encoding for Primitive types.
				return
			end
		end
			
		class ConstructType < BaseType
			def initialize
				super
			end
			
			def check_type(t)
				if t.is_a?(RecClass)
					ty = t.get_type()
					if ty == nil
						raise ValueError, "type mismatch with uninitialized type"
					end
					return ty
				else
					raise ValueError, "type mismatch: type on the wire #{t.name}, expect type #{self.name}"
				end
			end
			
			def encode_type(type_table)
				return type_table.index_of(self.name)
			end
		end
	
	
		class NullClass < PrimitiveType
			def initialize()
				super
			end
			
			def covariant(x)
				x == nil
			end
			
			def encode_value(val)
				''
			end
			
			def encode_type(type_table=nil)
				LEB128.encode_signed(TypeIds::Null).string
			end
			
			def decode_value(b, t)
				check_type(t)
				return nil
			end
			
			def name
				'null'
			end
			
			def id
				TypeIds::Null
			end
		end
	
		class EmptyClass < PrimitiveType
			def initialize
				super
			end
			
			def covariant(x)
				false
			end
			
			def encode_value(val)
				raise ValueError.new("Empty cannot appear as a function argument")
			end
			
			def encode_type(type_table=nil)
				LEB128.encode_signed(TypeIds::Empty).string
			end
			
			def decode_value(b, t)
				raise ValueError.new("Empty cannot appear as an output")
			end
			
			def name
				'empty'
			end
			
			def id
				TypeIds::Empty
			end
		end
			
		class BoolClass < PrimitiveType
			def initialize
				super
			end
			
			def covariant(x)
				x.is_a?(TrueClass) || x.is_a?(FalseClass)
			end
			
			def encode_value(val)
				LEB128.encode_signed(val ? 1 : 0).string
			end
			
			def encode_type(type_table=nil)
				LEB128.encode_signed(TypeIds::Bool).string
			end
			
			def decode_value(b, t)
				check_type(t)
				byte = IcAgent::Candid.safe_read_byte(b)
				str_io = StringIO.new
				str_io.putc(byte.hex)
				if LEB128.decode_signed(str_io) == 1
					true
				elsif LEB128.decode_signed(str_io) == 0
					false
				else
					raise ValueError.new("Boolean value out of range")
				end
			end
			
			def name
				'bool'
			end
			
			def id
				TypeIds::Bool
			end
		end
			
		class ReservedClass < PrimitiveType
			def initialize
				super
			end
			
			def covariant(x)
				true
			end
			
			def encode_value
				''
			end
			
			def encode_type(type_table=nil)
				LEB128.encode_signed(TypeIds::Reserved).string
			end
			
			def decode_value(b, t)
				if name != t.name
					t.decode_value(b, t)
				end
				nil
			end
			
			def name
				'reserved'
			end
			
			def id
				TypeIds::Reserved
			end
		end
	
		class TextClass < PrimitiveType
			def initialize
				super
			end
	
			def covariant(x)
				x.is_a?(String)
			end
			
			def encode_value(val)
				buf = val.encode(Encoding::UTF_8)
				length = LEB128.encode_signed(buf.length).string
				length + buf
			end
			
			def encode_type(type_table=nil)
				LEB128.encode_signed(TypeIds::Text).string
			end
			
			def decode_value(b, t)
				check_type(t)
				length = IcAgent::Candid.leb128u_decode(b).to_i
				buf = IcAgent::Candid.safe_read(b, length)
				buf.hex2str
			end
			
			def name
				'text'
			end
			
			def id
				TypeIds::Text
			end
		end
			
		class IntClass < PrimitiveType
			def initialize
				super
			end
	
			def covariant(x)
				x.is_a?(Integer)
			end
			
			def encode_value(val)
				LEB128.encode_signed(val).string
			end
			
			def encode_type(type_table=nil)
				LEB128.encode_signed(TypeIds::Int).string
			end
			
			def decode_value(b, t)
				check_type(t)
				IcAgent::Candid.leb128i_decode(b)
			end
			
			def name
				'int'
			end
			
			def id
				TypeIds::Int
			end
		end
	
		class NatClass < PrimitiveType
			def initialize
				super
			end
			
			def covariant(x)
				x.is_a?(Integer) && x >= 0
			end
			
			def encode_value(val)
				LEB128.encode_signed(val).string
			end
			
			def encode_type(type_table=nil)
				LEB128.encode_signed(TypeIds::Nat).string
			end
			
			def decode_value(pipe, t)
				check_type(t)
				IcAgent::Candid.leb128u_decode(pipe)
			end
			
			def name
				'nat'
			end
			
			def id
				TypeIds::Nat
			end
		end
			
		class FloatClass < PrimitiveType
			def initialize(bits)
				super()
				@bits = bits
				raise ArgumentError, "not a valid float type" unless [32, 64].include?(@bits)
			end
			
			def covariant(x)
				x.is_a?(Float)
			end
			
			def encode_value(val)
				if @bits == 32
					[val].pack('f')
				elsif @bits == 64
					[val].pack('d')
				else
					raise ValueError, "The length of float have to be 32 bits or 64 bits "
				end
			end
			
			def encode_type(type_table=nil)
				opcode = if @bits == 32
					TypeIds::Float32
				else
					TypeIds::Float64
				end
				LEB128.encode_signed(opcode).string
			end
			
			def decode_value(b, t)
				check_type(t)
				by = IcAgent::Candid.safe_read(b, @bits / 8)
				if @bits == 32
					by.hex2str.unpack('f')[0]
				elsif @bits == 64
					by.hex2str.unpack('d')[0]
				else
					raise ValueError, "The length of float have to be 32 bits or 64 bits "
				end
			end
			
			def name
				"float#{@bits}"
			end
			
			def id
				if @bits == 32
					TypeIds::Float32
				else
					TypeIds::Float64
				end
			end
		end
	
		class FixedIntClass < PrimitiveType
			def initialize(bits)
				super()
				@bits = bits
				unless [8, 16, 32, 64].include?(@bits)
					raise ArgumentError.new("bits only support 8, 16, 32, 64")
				end
			end
			
			def covariant(x)
				min_val = -1 * 2 ** (@bits - 1)
				max_val = -1 + 2 ** (@bits - 1)
				if x >= min_val && x <= max_val
					true
				else
					false
				end
			end
			
			def encode_value(val)
				if @bits == 8
					buf = [val].pack('c') # signed char -> Int8
				elsif @bits == 16
					buf = [val].pack('s') # short -> Int16
				elsif @bits == 32
					buf = [val].pack('l') # int -> Int32
				elsif @bits == 64
					buf = [val].pack('q') # long long -> Int64
				else
					raise ArgumentError.new("bits only support 8, 16, 32, 64")
				end
				buf
			end
			
			def encode_type(type_table=nil)
				offset = (Math.log2(@bits) - 3).to_i
				LEB128.encode_signed(-9 - offset).string
			end
			
			def decode_value(b, t)
				check_type(t)
				by = IcAgent::Candid.safe_read(b, @bits / 8)
				if @bits == 8
					by.hex2str.unpack('c')[0] # signed char -> Int8
				elsif @bits == 16
					by.hex2str.unpack('s')[0] # short -> Int16
				elsif @bits == 32
					by.hex2str.unpack('l')[0] # int -> Int32
				elsif @bits == 64
					by.hex2str.unpack('q')[0] # long long -> Int64
				else
					raise ArgumentError.new("bits only support 8, 16, 32, 64")
				end
			end
			
			def name
				'int' + @bits.to_s
			end
			
			def id
				case @bits
				when 8
					TypeIds::Int8
				when 16
					TypeIds::Int16
				when 32
					TypeIds::Int32
				when 64
					TypeIds::Int64
				end
			end
		end
	
		class FixedNatClass < PrimitiveType
			def initialize(bits)
				super()
				@bits = bits
				unless [8, 16, 32, 64].include? bits
					raise ArgumentError, 'bits only support 8, 16, 32, 64'
				end
			end
	
			def covariant(x)
				max_val = -1 + 2**@bits
				x >= 0 && x <= max_val
			end
	
			def encode_value(val)
				case @bits
				when 8
					buf = [val].pack('C') # unsigned char -> Nat8
				when 16
					buf = [val].pack('S') # unsigned short -> Nat16
				when 32
					buf = [val].pack('L') # unsigned int -> Nat32
				when 64
					buf = [val].pack('Q') # unsigned long long -> Nat64
				else
					raise ArgumentError, 'bits only support 8, 16, 32, 64'
				end
				buf
			end
	
			def encode_type(type_table=nil)
				offset = Math.log2(@bits).to_i - 3
				LEB128.encode_signed(-5 - offset).string
			end
	
			def decode_value(b, t)
				check_type(t)
				by = IcAgent::Candid.safe_read(b, @bits / 8)
				case @bits
				when 8
					return by.hex2str.unpack('C').first # unsigned char -> Nat8
				when 16
					return by.hex2str.unpack('S').first # unsigned short -> Nat16
				when 32
					return by.hex2str.unpack('L').first # unsigned int -> Nat32
				when 64
					return by.hex2str.unpack('Q').first # unsigned long long -> Nat64
				else
					raise ArgumentError, 'bits only support 8, 16, 32, 64'
				end
			end
	
			def name
				"nat#{@bits}"
			end
	
			def id
				case @bits
				when 8
					TypeIds::Nat8
				when 16
					TypeIds::Nat16
				when 32
					TypeIds::Nat32
				when 64
					TypeIds::Nat64
				end
			end
		end
	
		class PrincipalClass < PrimitiveType
			def initialize
				super
			end
		
			def covariant(x)
				if x.is_a?(String)
					p = IcAgent::Principal.from_str(x)
				elsif x.is_a?(Array)
					p = IcAgent::Principal.from_hex(x.pack('C*').unpack1('H*'))
				else
					raise ValueError, 'only support string or bytes format'
				end
				p.is_a?(IcAgent::Principal)
			end
		
			def encode_value(val)
				tag = 1.chr(Encoding::ASCII_8BIT)
				if val.is_a?(String)
					buf = IcAgent::Principal.from_str(val).bytes
				elsif val.is_a?(Array)
					buf = val.pack('C*')
				else
					raise ValueError, 'Principal should be string or bytes.'
				end
				l = LEB128.encode_signed(buf.size).string
				tag + l + buf
			end
		
			def encode_type(type_table=nil)
				LEB128.encode_signed(TypeIds::Principal).string
			end
		
			def decode_value(b, t)
				check_type(t)
				res = IcAgent::Candid.safe_read_byte(b)
				if res != '01'
					raise ValueError, 'Cannot decode principal'
				end
				
				length = IcAgent::Candid.leb128u_decode(b)
				IcAgent::Principal.from_hex(IcAgent::Candid.safe_read(b, length)).to_str
			end
		
			def name
				'principal'
			end
		
			def id
				TypeIds::Principal
			end
		end
	
		class VecClass < ConstructType
			def initialize(_type)
				super()
				@interior_type = _type
			end
	
			def covariant(x)
				x.is_a?(Enumerable) && !x.any? { |item| !@interior_type.covariant(item) }
			end
	
			def encode_value(val)
				length = LEB128.encode_signed(val.length).string
				vec = val.map { |v| @interior_type.encode_value(v) }
				(length + vec.join).b
			end
	
			def _build_type_table_impl(type_table)
				@interior_type.build_type_table(type_table)
				op_code = LEB128.encode_signed(TypeIds::Vec).string
				buffer = @interior_type.encode_type(type_table)
				type_table.add(self, op_code + buffer)
			end
	
			def decode_value(b, t)
				vec = check_type(t)
				raise "Not a vector type" unless vec.is_a?(VecClass)
				length = IcAgent::Candid.leb128u_decode(b)
				rets = []
				length.times { rets << @interior_type.decode_value(b, @interior_type) }
				rets
			end
	
			def name
				"vec (#{@interior_type.name})"
			end
	
			def id
				TypeIds::Vec
			end
	
			def display
				"vec " + @interior_type.display
			end
		end
	
		class OptClass < ConstructType
			def initialize(_type)
				super()
				@type = _type
			end
		
			def covariant(x)
				x.is_a?(Array) && (x.empty? || (x.length == 1 && @type.covariant(x[0])))
			end
		
			def encode_value(val)
				if val.empty?
					"\x00".b
				else
					"\x01".b + @type.encode_value(val[0])
				end
			end
		
			def _build_type_table_impl(type_table)
				@type.build_type_table(type_table)
				op_code = LEB128.encode_signed(TypeIds::Opt).string
				buffer = @type.encode_type(type_table)
				type_table.add(self, op_code + buffer)
			end
		
			def decode_value(b, t)
				opt = check_type(t)
				raise ValueError, "Not an option type" unless opt.is_a?(OptClass)
		
				flag = IcAgent::Candid.safe_read_byte(b)
				if flag == "\x00".b
					[]
				elsif flag == "\x01".b
					[@type.decode_value(b, opt.instance_variable_get(:@type))]
				else
					raise ValueError, "Not an option value"
				end
			end
		
			def name
				"opt (#{@type.name})"
			end
		
			def id
				TypeIds::Opt
			end
		
			def display
				"opt (#{@type.display})"
			end
		end
	
		class RecordClass < ConstructType
			def initialize(field)
				super()
				@fields = field.sort_by { |k, _v| IcAgent::Utils.label_hash(k) }.to_h
			end
		
			def try_as_tuple
				res = []
				idx = 0
				@fields.each do |k, v|
					return nil unless k == "_#{idx}_" # check
					res << v
					idx += 1
				end
				res
			end
		
			def covariant(x)
				raise ArgumentError, "Expected dict type input." unless x.is_a?(Hash)
		
				@fields.each do |k, v|
					raise ArgumentError, "Record is missing key #{k}" unless x.key?(k)
					return false unless v.covariant(x[k])
				end
		
				true
			end
		
			def encode_value(val)
				bufs = @fields.map { |k, v| v.encode_value(val[k]) }
				bufs.join.b
			end
		
			def _build_type_table_impl(type_table)
				@fields.values.each do |field_value|
					field_value.send(:build_type_table, type_table)
				end
		
				op_code = LEB128.encode_signed(TypeIds::Record).string
				length = LEB128.encode_signed(@fields.size).string
		
				fields = @fields.map { |k, v| LEB128.encode_signed(IcAgent::Utils.label_hash(k)).string + v.encode_type(type_table) }.join.b
				type_table.add(self, op_code + length + fields)
			end
		
			def decode_value(b, t)
				record = check_type(t)
				raise ArgumentError, "Not a record type" unless record.is_a?(RecordClass)
		
				x = {}
				idx = 0
				keys = @fields.keys
				@fields.each do |k, v|
					if idx >= @fields.length || IcAgent::Utils.label_hash(keys[idx]) != IcAgent::Utils.label_hash(k)
						# skip field
						v.decode_value(b, v)
						next
					end
		
					expect_key = keys[idx]
					expected_value = @fields[expect_key]
					x[expect_key] = expected_value.decode_value(b, v)
					idx += 1
				end
		
				raise ArgumentError, "Cannot find field #{keys[idx]}" if idx < @fields.length
				x
			end
		
			def name
				fields = @fields.map { |k, v| "#{k}:#{v.name}" }.join(";")
				"record {#{fields}}"
			end
		
			def id
				TypeIds::Record
			end
		
			def display
				d = {}
				@fields.each { |k, v| d[v] = v.display }
				"record #{d}"
			end
		end

		class TupleClass < RecordClass
			def initialize(*_components)
				x = {}
				_components.each_with_index do |v, i|
					x["_#{i}_"] = v
				end
				super(x)
				@components = _components
			end

			def covariant(x)
				unless x.is_a?(Array)
					raise ValueError, 'Expected tuple type input.'
				end
				@components.each_with_index do |v, idx|
					unless v.covariant(x[idx])
						return false
					end
				end
				x.length >= @fields.length
			end

			def encode_value(val)
				bufs = ''.b
				@components.each_with_index do |_, i|
					bufs += @components[i].encode_value(val[i])
				end
				bufs
			end

			def decode_value(b, t)
				tup = check_type(t)
				unless tup.is_a?(TupleClass)
					raise ValueError, 'not a tuple type'
				end
				unless tup._components.length == @components.length
					raise ValueError, 'tuple mismatch'
				end
				res = []
				tup._components.each_with_index do |wireType, i|
					if i >= @components.length
						wireType.decodeValue(b, wireType)
					else
						res << @components[i].decodeValue(b, wireType)
					end
				end
				res
			end

			def id
				TypeIds::Tuple
			end

			def display
				d = @components.map { |item| item.display() }
				"record {#{d.join(';')}}"
			end
		end
	
		class VariantClass < ConstructType
			def initialize(field)
				super()
				@fields = field.sort_by { |kv| IcAgent::Utils.label_hash(kv[0]) }.to_h
			end
		
			def covariant(x)
				return false unless x.length == 1
		
				@fields.each do |k, v|
					next if !x.key?(k) || v.covariant(x[k])
		
					return false
				end
		
				true
			end
		
			def encode_value(val)
				idx = 0
				@fields.each do |name, ty|
					if val.key?(name)
						count = LEB128.encode_signed(idx).string
						buf = ty.encode_value(val[name])
						return count + buf
					end
		
					idx += 1
				end
				raise "Variant has no data: #{val}"
			end
		
			def _build_type_table_impl(type_table)
				@fields.each do |_, v|
					v.build_type_table(type_table)
				end
				opCode = LEB128.encode_signed(TypeIds::Variant).string
				length = LEB128.encode_signed(@fields.length).string
				fields = ''.b
				@fields.each do |k, v|
					fields += LEB128.encode_signed(IcAgent::Utils.label_hash(k)).string + v.encode_type(type_table)
				end
				type_table.add(self, opCode + length + fields)
			end
		
			def decode_value(b, t)
				variant = check_type(t)
				raise "Not a variant type" unless variant.is_a?(VariantClass)
		
				idx = leb128uDecode(b)
				raise "Invalid variant index: #{idx}" if idx >= variant._fields.length
		
				keys = variant._fields.keys
				wireHash = keys[idx]
				wireType = variant._fields[wireHash]
		
				@fields.each do |key, expectType|
					next unless IcAgent::Utils.label_hash(wireHash) == IcAgent::Utils.label_hash(key)
		
					ret = {}
					value = expectType ? expectType.decode_value(b, wireType) : nil
					ret[key] = value
					return ret
				end
		
				raise "Cannot find field hash #{wireHash}"
			end
		
			def name
				fields = @fields.map { |k, v| "#{k}:#{v.name || ''}" }.join(';')
				"variant {#{fields}}"
			end
		
			def id
				TypeIds::Variant
			end
		
			def display
				d = {}
				@fields.each do |k, v|
					d[k] = v.name || ''
				end
				"variant #{d}"
			end
		end
	
		class RecClass < ConstructType
			@@counter = 0
			
			def initialize
				super()
				@id = @@counter
				@@counter += 1
				@type = nil
			end
			
			def fill(t)
				@type = t
			end
			
			def get_type
				if @type.is_a?(RecClass)
					@type.get_type
				else
					@type
				end
			end
			
			def covariant(x)
				return false if @type.nil?
				@type.covariant(x)
			end
			
			def encode_value(val)
				if @type.nil?
					raise "Recursive type uninitialized"
				else
					@type.encode_value(val)
				end
			end
			
			def encode_type(type_table)
				if @type.is_a?(PrimitiveType)
					@type.encode_type(type_table)
				else
					super.encode_type(type_table)
				end
			end
			
			def _build_type_table_impl(type_table)
				if @type.nil?
					raise "Recursive type uninitialized"
				else
					if !get_type.is_a?(PrimitiveType)
						type_table.add(self, '')
						@type.build_type_table(type_table)
						type_table.merge(self, @type.name)
					end
				end
			end
			
			def decode_value(b, t)
				if @type.nil?
					raise "Recursive type uninitialized"
				else
					@type.decode_value(b, t)
				end
			end
			
			def name
				"rec_#{@id}"
			end
			
			def display
				if @type.nil?
					raise "Recursive type uninitialized"
				else
					"#{name}.#{@type.name}"
				end
			end
		end
	
		class FuncClass < ConstructType
			attr_accessor :arg_types, :ret_types, :annotations
	
			def initialize(arg_types, ret_types, annotations)
					super()
					@arg_types = arg_types
					@ret_types = ret_types
					@annotations = annotations
			end
			
			def covariant(x)
					x.is_a?(Array) && x.length == 2 && x[0] && 
						(x[0].is_a?(String) ? IcAgent::Principal.from_str(x[0]) : IcAgent::Principal.from_hex(x[0].unpack('H*').first)).is_a?(IcAgent::Principal) &&
						x[1].is_a?(String)
			end
			
			def encode_value(vals)
					principal = vals[0]
					methodName = vals[1]
					tag = [1].pack('C')
					if principal.is_a?(String)
							buf = IcAgent::Principal.from_str(principal).bytes
					elsif principal.is_a?(String)
							buf = principal
					else
							raise ArgumentError, 'Principal should be string or bytes.'
					end
					l = LEB128.encode_signed(buf.length).string
					canister = tag + l + buf
			
					method = methodName.encode
					methodLen = LEB128.encode_signed(method.length).string
					tag + canister + methodLen + method
			end
			
			def _build_type_table_impl(type_table)
					@arg_types.each { |arg| arg.build_type_table(type_table) }
					@ret_types.each { |ret| ret.build_type_table(type_table) }
			
					op_code = LEB128.encode_signed(TypeIds::Func).string
					arg_len = LEB128.encode_signed(@arg_types.length).string
					args = ''
					@arg_types.each { |arg| args += arg.encode_type(type_table) }
					ret_len = LEB128.encode_signed(@ret_types.length).string
					rets = ''
					@ret_types.each { |ret| rets += ret.encode_type(type_table) }
					ann_len = LEB128.encode_signed(@annotations.length).string
					anns = ''
					@annotations.each { |a| anns += _encode_annotation(a) }
					type_table.add(self, op_code + arg_len + args + ret_len + rets + ann_len + anns)
			end
			
			def decode_value(b, t)
					x = IcAgent::Candid.safe_read_byte(b)
					raise ArgumentError, 'Cannot decode function reference' unless LEB128.decode_signed(x) == 1
					res = IcAgent::Candid.safe_read_byte(b)
					raise ArgumentError, 'Cannot decode principal' unless LEB128.decode_signed(res) == 1
					length = LEB128.decode_signed(b)
					canister = IcAgent::Principal.from_hex(safeRead(b, length).unpack('H*').first)
					mLen = LEB128.decode_signed(b)
					buf =  IcAgent::Candid.safe_read(b, mLen)
					method = buf.force_encoding('UTF-8')
			
					[canister, method]
			end
			
			def name
					args = @arg_types.map { |arg| arg.name }.join(', ')
					rets = @ret_types.map { |ret| ret.name }.join(', ')
					anns = @annotations.join(' ')
					"(#{args}) → (#{rets}) #{anns}"
			end
			
			def id
					TypeIds::Func
			end
			
			def display
					args = @arg_types.map { |arg| arg.display }.join(', ')
					rets = @ret_types.map { |ret| ret.display }.join(', ')
					anns = @annotations.join(' ')
					"(#{args}) → (#{rets}) #{anns}"
			end
	
			def _encode_annotation(ann)
				if ann == 'query'
					return [1].pack('C')
				elsif ann == 'oneway'
					return [2].pack('C')
				else
					raise 'Illeagal function annotation'
				end
			end
		end
		
		class ServiceClass < ConstructType
			def initialize(field)
				super()
				@fields = Hash[field.sort_by { |k, _| IcAgent::Utils.label_hash(k.to_s) }]
			end
		
			def covariant(x)
				if x.is_a?(String)
					p = IcAgent::Principal.from_str(x)
				elsif x.is_a?(Array)
					p = IcAgent::Principal.from_hex(x.pack('C*').unpack1('H*'))
				else
					raise ArgumentError, 'only support string or bytes format'
				end
				p.is_a?(IcAgent::Principal)
			end
		
			def encode_value(val)
				tag = [1].pack('C')
				if val.is_a?(String)
					buf = IcAgent::Principal.from_str(val).bytes
				elsif val.is_a?(Array)
					buf = val
				else
					raise ArgumentError, 'Principal should be string or bytes.'
				end
				l = LEB128.encode_signed(buf.length).string
				tag + l + buf
			end
		
			def _build_type_table_impl(type_table)
				@fields.each_value { |v| v.build_type_table(type_table) }
				op_code = LEB128.encode_signed(TypeIds::Service).string
				length = LEB128.encode_signed(@fields.length).string
				fields = ''.b
				@fields.each { |k, v|
					fields += LEB128.encode_signed(k.to_s.bytesize).string + k.to_s + v.encode_type(type_table)
				}
				type_table.add(self, op_code + length + fields)
			end
		
			def decode_value(b, t)
				res = IcAgent::Candid.safe_read_byte(b)
				raise ArgumentError, 'Cannot decode principal' unless LEB128.decode_signed(res) == 1
				length = LEB128.decode_signed(b)
				IcAgent::Principal.from_hex(safeRead(b, length).pack('C*').unpack1('H*'))
			end
		
			def name
				fields = @fields.map { |k, v| "#{k} : #{v.name}" }.join(', ')
				"service #{fields}"
			end
		
			def id
				TypeIds::Service
			end
		end
		
	
	
		#####################
	
		class Pipe
			def initialize(buffer = '', length = 0)
				@buffer = buffer
				@view = buffer[0...buffer.size]
			end
			
			def buffer
				@view
			end
			
			def length
				@view.size
			end
			
			def end?
				length == 0
			end
			
			def read(num)
				if @view.size < num
					raise ValueError.new("Wrong: out of bound")
				end
				read_num = num * 2
				res = @view[0...read_num]
				@view = @view[read_num...@view.length]
				return res
			end
			
			def readbyte
				res = @view[0, 2]
				@view = @view[2...@view.length]
				return res
			end
		end
	
		class BaseTypes
			def self.method_missing(method_name)
				case method_name.to_s
				when 'null'
					return NullClass.new
				when 'empty'
					return EmptyClass.new
				when 'bool'
					return BoolClass.new
				when 'int'
					return IntClass.new
				when 'reserved'
					return ReservedClass.new
				when 'nat'
					return NatClass.new
				when 'text'
					return TextClass.new
				when 'principal'
					return PrincipalClass.new
				when 'float32'
					return FloatClass.new(32)
				when 'float64'
					return FloatClass.new(64)
				when 'int8'
					return FixedIntClass.new(8)
				when 'int16'
					return FixedIntClass.new(16)
				when 'int32'
					return FixedIntClass.new(32)
				when 'int64'
					return FixedIntClass.new(64)
				when 'nat8'
					return FixedNatClass.new(8)
				when 'nat16'
					return FixedNatClass.new(16)
				when 'nat32'
					return FixedNatClass.new(32)
				when 'nat64'
					return FixedNatClass.new(64)
				end
				puts "Method #{method_name} is not defined"
			end
			
			def self.tuple(*types)
				return TupleClass.new(*types)
			end
			
			def self.vec(t)
				return VecClass.new(t)
			end
			
			def self.opt(t)
				return OptClass.new(t)
			end
			
			def self.record(t)
				return RecordClass.new(t)
			end
			
			def self.variant(fields)
				return VariantClass.new(fields)
			end
			
			def self.rec
				return RecClass.new
			end
			
			def self.func(args, ret, annotations)
				return FuncClass.new(args, ret, annotations)
			end
			
			def self.service(t)
				return ServiceClass.new(t)
			end
		end
	
		def self.leb128u_decode(pipe)
			res = StringIO.new
			loop do
				byte = safe_read_byte(pipe)
				res.putc(byte.hex)
				break if byte < "80" || pipe.length.zero?
			end

			LEB128.decode_signed(res)
		end
		
		def self.leb128i_decode(pipe)
			length = pipe.buffer.length
			count = 0
			(0...length).each do |i|
				count = i
				if pipe.buffer[i] < "80"   # 0x80
					if pipe.buffer[i] < "40" # 0x40
						return leb128u_decode(pipe)
					end
					break
				end
			end
			res = StringIO.new
			res.putc(safe_read(pipe, count + 1).hex)
			LEB128.decode_signed(res)
		end
		
		def self.safe_read(pipe, num)
			raise ArgumentError, 'unexpected end of buffer' if pipe.length < num
			pipe.read(num)
		end
		
		def self.safe_read_byte(pipe)
			raise ArgumentError, 'unexpected end of buffer' if pipe.length < 1
			pipe.readbyte
		end

		def self.leb128_string_hex(p_str)
			LEB128.encode_signed(p_str).string.to_hex
		end

		def self.unicode_to_hex(u_code)
			u_code.to_hex
		end
		
		def self.build_type(raw_table, table, entry)
			ty = entry[0]
			if ty == TypeIds::Vec
				if ty >= raw_table.length
					raise ValueError, "type index out of range"
				end
				t = get_type(raw_table, table, entry[1])
				if t.nil?
					t = table[t]
				end
				return BaseTypes::vec(t)
			elsif ty == TypeIds::Opt
				if ty >= raw_table.length
					raise ValueError, "type index out of range"
				end
				t = get_type(raw_table, table, entry[1])
				if t.nil?
					t = table[t]
				end
				return BaseTypes::opt(t)
			elsif ty == TypeIds::Record
				fields = {}
				entry[1].each do |hash, t|
					name = '_' + hash.to_s + '_'
					if t >= raw_table.length
						raise ValueError, "type index out of range"
					end
					temp = get_type(raw_table, table, t)
					fields[name] = temp
				end
				record = BaseTypes::record(fields)
				tup = record.try_as_tuple()
				if tup.is_a?(Array)
					return BaseTypes::tuple(*tup)
				else
					return record
				end
			elsif ty == TypeIds::Variant
				fields = {}
				entry[1].each do |hash, t|
					name = '_' + hash.to_s + '_'
					if t >= raw_table.length
						raise ValueError, "type index out of range"
					end
					temp = get_type(raw_table, table, t)
					fields[name] = temp
				end
				return BaseTypes::variant(fields)
			elsif ty == TypeIds::Func
				return BaseTypes::func([], [], [])
			elsif ty == TypeIds::Service
				return BaseTypes::service({})
			else
				raise ValueError, "Illegal op_code: #{ty}"
			end
		end

		def self.read_type_table(pipe)
			type_table = []
			
			type_table_len = leb128u_decode(pipe).to_i
			type_table_len.times do
				ty = leb128i_decode(pipe)
		
				if ty == TypeIds::Opt || ty == TypeIds::Vec
						t = leb128i_decode(pipe)
						type_table << [ty, t]
				elsif ty == TypeIds::Record || ty == TypeIds::Variant
						fields = []
						obj_length = leb128u_decode(pipe)
						prev_hash = -1
		
						obj_length.times do
								hash = leb128u_decode(pipe)
		
								if hash >= 2**32
										raise ValueError.new("field id out of 32-bit range")
								end
		
								if prev_hash.is_a?(Integer) && prev_hash >= hash
										raise ValueError.new("field id collision or not sorted")
								end
		
								prev_hash = hash
								t = leb128i_decode(pipe)
								fields << [hash, t]
						end
		
						type_table << [ty, fields]
				elsif ty == TypeIds::Func
						2.times do
								fun_len = leb128u_decode(pipe)
								fun_len.times { leb128i_decode(pipe) }
						end
		
						ann_len = leb128u_decode(pipe)
						safe_read(pipe, ann_len)
						type_table << [ty, nil]
				elsif ty == TypeIds::Service
						serv_len = leb128u_decode(pipe)
		
						serv_len.times do
								l = leb128u_decode(pipe)
								safe_read(pipe, l)
								leb128i_decode(pipe)
						end
		
						type_table << [ty, nil]
				else
						raise ValueError.new("Illegal op_code: #{ty}")
				end
			end
		
			raw_list = []
			types_len = leb128u_decode(pipe).to_i
			
			types_len.times do
					raw_list << leb128i_decode(pipe)
			end
			
			[type_table, raw_list]
	end		

	
		def self.get_type(raw_table, table, t)
			if t < -24
				raise ValueError, "not supported type"
			end
			
			if t < 0
				case t
				when -1
					return BaseTypes.null
				when -2
					return BaseTypes.bool
				when -3
					return BaseTypes.nat
				when -4
					return BaseTypes.int
				when -5
					return BaseTypes.nat8
				when -6
					return BaseTypes.nat16
				when -7
					return BaseTypes.nat32
				when -8
					return BaseTypes.nat64
				when -9
					return BaseTypes.int8
				when -10
					return BaseTypes.int16
				when -11
					return BaseTypes.int32
				when -12
					return BaseTypes.int64
				when -13
					return BaseTypes.float32
				when -14
					return BaseTypes.float64
				when -15
					return BaseTypes.text
				when -16
					return BaseTypes.reserved
				when -17
					return BaseTypes.empty
				when -24
					return BaseTypes.principal
				else
					raise ValueError, "Illegal op_code: #{t}"
				end
			end
			
			if t >= raw_table.length
				raise ValueError, "type index out of range"
			end
			
			return table[t]
		end
	
	
		# params = [{type, value}]
		# data = b'DIDL' + len(params) + encoded types + encoded values
		def self.encode(params)
			arg_types = []
			args = []
			params.each do |p|
				arg_types << p[:type]
				args << p[:value]
			end
	
			if arg_types.length != args.length
				raise ValueError, "Wrong number of message arguments"
			end
	
			typetable = TypeTable.new

			arg_types.each do |item|
				item.build_type_table(typetable)
			end
	
			pre = unicode_to_hex(PREFIX)
			table = unicode_to_hex(typetable.encode())
			length = leb128_string_hex(args.length)
	
			typs = ''
			arg_types.each do |t|
				typs += unicode_to_hex(t.encode_type(typetable))
			end
	
			vals = ''
			args.each_with_index do |arg, i|
				t = arg_types[i]
				unless t.covariant(args[i])
					raise TypeError, "Invalid #{t.display} argument: #{args[i]}"
				end
				vals += unicode_to_hex(t.encode_value(args[i]))
			end
	
			return pre + table + length + typs + vals
		end
	
		# decode a bytes value
		# def decode(retTypes, data):	
		def self.decode(data, ret_types=nil)
			pipe = Pipe.new(data)
			if data.length < PREFIX.length
				raise ValueError.new("Message length smaller than prefix number")
			end
			prefix_buffer = safe_read(pipe, PREFIX.length).hex2str
	
			if prefix_buffer != PREFIX
				raise ValueError.new("Wrong prefix:" + prefix_buffer + 'expected prefix: DIDL')
			end
			raw_table, raw_types = read_type_table(pipe)
			
			if ret_types
				if ret_types.class != Array
					ret_types = [ret_types]
				end
				if raw_types.length < ret_types.length
					raise ValueError.new("Wrong number of return value")
				end
			end
			
			table = []
			raw_table.length.times do
				table.append(BaseTypes.rec)
			end
		
			raw_table.each_with_index do |entry, i|
				t = build_type(raw_table, table, entry)
				table[i].fill(t)
			end
		
			types = []
			raw_types.each do |t|
				types.append(get_type(raw_table, table, t))
			end
	
			outputs = []
			types.each_with_index do |t, i|
				outputs.append({
					'type' => t.name,
					'value' => t.decode_value(pipe, types[i])
				})
			end
		
			return outputs
		end
	end
end
