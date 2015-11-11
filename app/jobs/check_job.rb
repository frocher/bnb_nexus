class CheckJob
  def call(job)
    CheckTask.enqueue(job.tags[0])
  end
end
