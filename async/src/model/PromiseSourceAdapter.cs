using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace PSGoodies.Async.Model
{
  public class PromiseSourceAdapter : JobSourceAdapter
  {
    #region Constructor Fields
    private ConcurrentDictionary<Guid, Job2> __repository;
    #endregion

    public PromiseSourceAdapter()
    {
      this.Name = "PromiseSourceAdapter";
      this.__repository = new ConcurrentDictionary<Guid, Job2>();
    }

    public override Job2 NewJob(JobInvocationInfo specification)
    {
      var job = specification.Parameters[0][0].Value as Promise;
      if (job != null)
      {
        this.__repository.TryAdd(job.InstanceId, job);
      }

      return job;
    }

    public override IList<Job2> GetJobs()
    {
      return this.__repository.Values.ToArray();
    }

    public override IList<Job2> GetJobsByName(string name, bool recurse)
    {
      IList<Job2> jobs = new List<Job2>();
      foreach (var job in this.__repository.Values)
      {
        if (job.Name.Equals(name, StringComparison.OrdinalIgnoreCase))
        {
          jobs.Add(job);
        }
      }

      return jobs;
    }

    public override IList<Job2> GetJobsByCommand(string command, bool recurse)
    {
      IList<Job2> jobs = new List<Job2>();
      foreach (var job in this.__repository.Values)
      {
        if (job.Command.Equals(command, StringComparison.OrdinalIgnoreCase))
        {
          jobs.Add(job);
        }
      }

      return jobs;
    }

    public override IList<Job2> GetJobsByState(JobState state, bool recurse)
    {
      IList<Job2> jobs = new List<Job2>();
      foreach (var job in this.__repository.Values)
      {
        if (job.JobStateInfo.State == state)
        {
          jobs.Add(job);
        }
      }

      return jobs;
    }

    public override Job2 GetJobByInstanceId(Guid instanceId, bool recurse)
    {
      Job2 job;
      if (this.__repository.TryGetValue(instanceId, out job))
      {
        return job;
      }

      return null;
    }

    public override Job2 GetJobBySessionId(int id, bool recurse)
    {
      foreach (var job in this.__repository.Values)
      {
        if (job.Id == id)
        {
          return job;
        }
      }

      return null;
    }

    public override void RemoveJob(Job2 job)
    {
      Job2 removeJob = this.GetJobByInstanceId(job.InstanceId, false);
      if (removeJob != null)
      {
        removeJob.StopJob();
        this.__repository.TryRemove(job.InstanceId, out removeJob);
      }
    }

    public override IList<Job2> GetJobsByFilter(Dictionary<string, object> filter, bool recurse)
    {
      throw new PSNotSupportedException();
    }
  }
}