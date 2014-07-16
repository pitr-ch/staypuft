module Staypuft
  module Deployment::VlanRangeValuesValidator
    GENERAL_MSG = "Start and end vlan IDs required, in format '10:100'"
    INT_VAL_MSG = "is not a valid integer between 1 and 4094"
    FIRST_VALID = 1
    LAST_VALID = 4024

    def validate_each(record, attribute, value)
      return if value.empty?
      errors_found = false
      range_val_str_arr = value.split(':')
      range_vals = []

      # two colon-separated values provided
      if range_val_str_arr.size == 2
        range_val_str_arr.each_with_index do |range_val_str, index|
          # is valid unsigned int format
          if range_val_str =~ /\A\d+\Z/
            this_val = range_val_str.to_i
            # int value between 1 and 4024
            if this_val.between?(FIRST_VALID,LAST_VALID)
              range_vals << this_val
            else
              record.errors.add attribute, "Range #{entry_from_index(index)} #{range_val_str} #{INT_VAL_MSG}"
              errors_found = true
            end
          else
            record.errors.add attribute, "Range #{entry_from_index(index)} #{range_val_str} #{INT_VAL_MSG}"
            errors_found = true
          end
        end
      else
        record.errors.add attribute, GENERAL_MSG
        errors_found = true
      end

      # no errors so far -- final verification that the last value is >= first value
      unless errors_found
        unless range_vals[1] >= range_vals[0]
          record.errors.add attribute, "End VLAN ID must be equal to or greater than start VLAN ID."
        end
      end
    end

    def entry_from_index(index)
      if index == 0
        "start"
      else
        "end"
      end
    end
  end
end
