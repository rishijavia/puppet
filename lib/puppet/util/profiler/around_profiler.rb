# A Profiler that can be used to wrap around blocks of code. It is configured
# with other profilers and controls them to start before the block is executed
# and finish after the block is executed.
#
# @api private
class Puppet::Util::Profiler::AroundProfiler

  def initialize
    @profilers = []
  end

  # Reset the profiling system to the original state
  #
  # @api private
  def clear
    @profilers = []
  end

  # Retrieve the current list of profilers
  #
  # @api private
  def current
    @profilers
  end

  # @param profiler [#profile] A profiler for the current thread
  # @api private
  def add_profiler(profiler)
    @profilers << profiler
    profiler
  end

  # @param profiler [#profile] A profiler to remove from the current thread
  # @api private
  def remove_profiler(profiler)
    @profilers.delete(profiler)
  end

  # Profile a block of code and log the time it took to execute.
  #
  # This outputs logs entries to the Puppet masters logging destination
  # providing the time it took, a message describing the profiled code
  # and a leaf location marking where the profile method was called
  # in the profiled hierachy.
  #
  # @param message [String] A description of the profiled event
  # @param block [Block] The segment of code to profile
  # @api private
  def profile(message)
    retval = nil
    contexts = {}
    @profilers.each do |profiler|
      contexts[profiler] = profiler.start(message)
    end

    begin
      retval = yield
    ensure
      @profilers.each do |profiler|
        profiler.finish(contexts[profiler], message)
      end
    end

    retval
  end
end