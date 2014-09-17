module Loggable
  extend ActiveSupport::Concern

  def logs
    @logs ||= []
  end

  def has_logs?
    logs.length > 0
  end

  ###
   # Add the given log string, and return false.
   # @returns false
  ###
  def add_log(s)
    logs.push s
    return false
  end

  def clear_logs
    @logs = []
  end
end
