module Problemable
  extend ActiveSupport::Concern

  ###
   # We can't use `errors` here, because they interfere with form helpers/validation...
   # need to maybe instead move this into a service object/helper.
  ###
  def problems
    @problems ||= []
  end

  def has_problems?
    problems.length > 0
  end

  ###
   # Add the given problem string, and return false.
   # @returns false
  ###
  def add_problem(s)
    problems.push s
    return false
  end

  def clear_problems
    @problems = []
  end
end
