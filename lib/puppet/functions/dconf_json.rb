# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
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

# ---- original file header ----
#
# @summary
#   This function takes data, outputs making sure the hash keys are sorted.
#The format is a "dialect" of JSON as produced and consumed by dconf.
#
#*Examples:*
#
#    dconf_json({'key'=>'value'})
#
#Would return: {'key': 'value'}
#
#    dconf_json(['dconf::tuple', 'a', 'b'])
#
#Would return: ('a', 'b')
#
#
Puppet::Functions.create_function(:'dconf_json') do
  # @param arguments
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :arguments
  end


  def default_impl(*arguments)
    
    raise(Puppet::ParseError, "dconf_json(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size != 1

    json = arguments[0]
    return dconf_json(json)
  
  end
end
