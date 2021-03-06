require "xmlrpc/create"
require "xmlrpc/utils"
require "xmlrpc/parser"
require "xmlrpc/client"

module XMLRPC

  #  module XMLWriter

  #    class SimpleExt < XMLRPC::XMLWriter::Simple
  #      def pi(name, *params)
  #        "<?#{name} " + params.join(" ") + "?> "
  #      end

  #      def ele(name, *children)
  #        element(name, nil, *children)
  #      end
  #
  #      def tag(name, txt)
  #        element(name, nil, text(txt))
  #      end
  #    end
  #  end

  class ClientExt < XMLRPC::Client
    
    def call2(method, *args)
      request = create().methodCall(method, *args)
      data = do_rpc(request, false)
      parser().parseMethodResponse(data)
    end

    def create
      if @create.nil? then
        @create  = CreateExt.new
      end
      @create
    end
  end
  
  class CreateExt < XMLRPC::Create

    def methodResponse(is_ret, *params)
      if is_ret
        resp = params.collect do |param|
          @writer.ele("param", conv2value_ext(param))
        end

        resp = [@writer.ele("params", *resp)]
      else
        if params.size != 1 or params[0] === XMLRPC::FaultException
          raise ArgumentError, "no valid fault-structure given"
        end
        resp = @writer.ele("fault", conv2value_ext(params[0].to_h))
      end


      tree = @writer.document(
        @writer.pi("xml", 'version="1.0"', 'encoding="UTF-8"'),
        @writer.ele("methodResponse", resp)
      )
      
      @writer.document_to_str(tree) + "\n"
    end

    def methodCall(name, *params)
      name = name.to_s

      if name !~ /[a-zA-Z0-9_.:\/]+/
        raise ArgumentError, "Wrong XML-RPC method-name"
      end

      parameter = params.collect do |param|
        @writer.ele("param", conv2value_ext(param))
      end

      tree = @writer.document(
        @writer.pi("xml", 'version="1.0"', 'encoding="UTF-8"') + "\n",
        @writer.ele("methodCall",
          @writer.tag("methodName", name),
          @writer.ele("params", *parameter) 
        )
      )
      
      @writer.document_to_str(tree)
    end

    protected

    #
    # converts a Ruby object into
    # a XML-RPC <value> tag
    #
    def conv2value_ext(param)

      val = case param
      when Fixnum
        @writer.tag("int", param.to_s)

      when Bignum
        if Config::ENABLE_BIGINT
          @writer.tag("int", param.to_s)
        else
          if param >= -(2**31) and param <= (2**31-1)
            @writer.tag("int", param.to_s)
          else
            raise "Bignum is too big! Must be signed 32-bit integer!"
          end
        end
      when TrueClass, FalseClass
        @writer.tag("boolean", param ? "1" : "0")

      when String
        @writer.tag("string", param)

      when Symbol
        @writer.tag("string", param.to_s)

      when NilClass
        if Config::ENABLE_NIL_CREATE
          @writer.ele("nil")
        else
          raise "Wrong type NilClass. Not allowed!"
        end

      when Float
        @writer.tag("double", param.to_s)

      when Struct
        h = param.members.collect do |key|
          value = param[key]
          @writer.ele("member",
            @writer.tag("name", key.to_s),
            conv2value_ext(value)
          )
        end

        @writer.ele("struct", *h)

      when Hash
        # TODO: can a Hash be empty?

        h = param.collect do |key, value|
          @writer.ele("member",
            @writer.tag("name", key.to_s),
            conv2value_ext(value)
          )
        end

        @writer.ele("struct", *h)

      when Array
        # TODO: can an Array be empty?
        a = param.collect {|v| conv2value_ext(v) }

        @writer.ele("array",
          @writer.ele("data", *a)
        )

      when Time, Date, ::DateTime
        @writer.tag("dateTime.iso8601", param.strftime("%Y%m%dT%H:%M:%S"))

      when XMLRPC::DateTime
        @writer.tag("dateTime.iso8601",
          format("%.4d%02d%02dT%02d:%02d:%02d", *param.to_a))

      when XMLRPC::Base64
        @writer.tag("base64", param.encoded)

      else
        if Config::ENABLE_MARSHALLING and param.class.included_modules.include? XMLRPC::Marshallable
          # convert Ruby object into Hash
          ret = {"___class___" => param.class.name}
          param.instance_variables.each {|v|
            name = v[1..-1]
            val = param.instance_variable_get(v)

            if val.nil?
              ret[name] = val if Config::ENABLE_NIL_CREATE
            else
              ret[name] = val
            end
          }
          return conv2value_ext(ret)
        else
          ok, pa = wrong_type(param)
          if ok
            return conv2value_ext(pa)
          else
            raise "Wrong type!"
          end
        end
      end

      @writer.ele("value", val)
    end
    
  end
end