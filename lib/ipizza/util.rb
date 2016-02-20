require 'base64'
require 'openssl'

module Ipizza
  class Util
    class << self

      # Calculates and adds control number using 7-3-1 algoritm
      # for Estonian banking account and reference numbers.
      def sign_731(ref_num)
        arr = ref_num.to_s.reverse.split('')
        m = 0
        r = 0

        arr.each do |e|
          m = case m
              when 7 then 3
              when 3 then 1
              else 7
              end
          r = r + (e.to_i * m)
        end
        c = ((r + 9) / 10).to_f.truncate * 10 - r
        arr.reverse! << c
        arr.join
      end

      # Produces string to be signed out of service message parameters.
      #
      #   p(x1)||x1||p(x2)||x2||...||p(xn)||xn
      #
      # Where || is string concatenation, p(x) is length of the
      # (stripped) field x represented by three digits.
      #
      # Parameters val1, val2, value3 would be turned into "003val1003val2006value3".
      def mac_data_string(params, sign_param_order)
        sign_param_order
          .map { |k| params[k].to_s.strip }
          .reduce('') { |acc, val| memo << sprintf('%03i', val.size) << val }
      end

    end
  end
end
