class UptimeJob
  def call(job)
    UptimeTask.enqueue(job.tags[0])
  end
end
