class Semaphore
  def initialize(resource_count = 0)
    @available_resource_count = resource_count.to_i
    @mutex = Mutex.new
    @waiting_threads = []
  end
  
  def wait
    sleep_thread unless available_resource?
  end
  
  def signal
    schedule_waiting_thread if waiting_thread?
  end
  
  def synchronize
    self.wait
    yield
  ensure
    self.signal
  end
  
  private 
  
  def available_resource?
    @mutex.synchronize do
      return (@available_resource_count -= 1) >= 0
    end
  end
  
  def sleep_thread
    @waiting_threads << Thread.current
    Thread.stop  
  end
  
  def waiting_thread?
    @mutex.synchronize do
      return (@available_resource_count += 1) <= 0
    end
  end
  
  def schedule_waiting_thread
    thread = @waiting_threads.shift
    thread.wakeup if thread
  end
end
