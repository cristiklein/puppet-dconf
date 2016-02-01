require 'json'

def dconf_json(obj)
  case obj
    when Fixnum, Float, TrueClass, FalseClass, NilClass
      return obj.to_json
    when String
      # dconf deviates "a bit" from the JSON standard
      return "'" << (obj.to_json)[1..-2] << "'";
    when Array
      arrayRet = []
      obj.each do |a|
        arrayRet.push(dconf_json(a))
      end
      return "[" << arrayRet.join(', ') << "]";
    when Hash
      ret = []
      obj.keys.sort.each do |k|
        ret.push(k.to_json << ":" << dconf_json(obj[k]))
      end
      return "{" << ret.join(", ") << "}";
    else
      raise Exception("Unable to handle object of type <%s>" % obj.class.to_s)
  end
end

module Puppet::Parser::Functions
  newfunction(:dconf_json, :type => :rvalue, :doc => <<-EOS
This function takes data, outputs making sure the hash keys are sorted.
The format is a "dialect" of JSON as produced and consumed by dconf.

*Examples:*

    dconf_json({'key'=>'value'})

Would return: {'key': 'value'}
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "dconf_json(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1

    json = arguments[0]
    return dconf_json(json)
  end
end
