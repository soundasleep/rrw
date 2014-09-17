module Errorable
  extend ActiveSupport::Concern

  def errors
    @errors ||= []
  end

  def has_errors?
    errors.length > 0
  end

  ###
   # Add the given error string, and return false.
   # @returns false
  ###
  def add_error(s)
    errors.push s
    return false
  end

  def clear_errors
    @errors = []
  end
end
