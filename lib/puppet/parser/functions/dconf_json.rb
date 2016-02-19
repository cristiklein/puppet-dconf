require 'json'

def dconf_json(obj)
  case obj
    when Fixnum, Float, TrueClass, FalseClass, NilClass
      return obj.to_json
    when String
      # dconf deviates "a bit" from the JSON standard
      return "'" << (obj.to_json)[1..-2] << "'";
    when Array
      isTuple = false
      arrayRet = []
      obj.each do |a|
        if a == 'dconf::tuple' then
          isTuple = true
        else
          arrayRet.push(dconf_json(a))
        end
      end
      if isTuple then
        return "(" << arrayRet.join(', ') << ")";
      else
        return "[" << arrayRet.join(', ') << "]";
      end
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

    dconf_json(['dconf::tuple', 'a', 'b'])

Would return: ('a', 'b')
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "dconf_json(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1

    json = arguments[0]
    return dconf_json(json)
  end
end
