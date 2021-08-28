using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace PSGoodies.PromiseGoodies.Model
{
  public class Promise : Job2, IDisposable
  {
    private const string VERBATIM_ARGUMENT = "--%";

    #region Fields
    private ScriptBlock __scriptBlock;
    private PSObject[] __argumentList;
    private PSCmdlet __psCmdlet;
    private ICollection<SessionStateCommandEntry> __commandEntries;
    private Dictionary<string, object> __usings;
    private PSDataCollection<object> __input;
    private PSDataCollection<PSObject> __output;
    private Runspace __runspace;
    private PowerShell __powershell;
    #endregion

    #region Properties
    public Promise ChildPromise { get; private set; }
    #endregion

    private Promise() { }

    public Promise(
      ScriptBlock scriptBlock,
      ICollection<SessionStateCommandEntry> commandEntries,
      Dictionary<string, object> usings,
      PSObject[] argumentList,
      PSCmdlet psCmdlet,
      Promise childPromise = null)
      : base(scriptBlock.ToString(), "Promise")
    {
      this.__scriptBlock = scriptBlock;
      this.__commandEntries = commandEntries;
      this.__usings = usings;
      this.__argumentList = argumentList;
      this.__psCmdlet = psCmdlet;
      this.__Initialize();

      this.ChildPromise = childPromise;
    }

    #region Private Methods
    private void __Initialize()
    {
      var iss = InitialSessionState.CreateDefault2();
      iss.Commands.Add(this.__commandEntries);
      iss.LanguageMode = PSLanguageMode.FullLanguage;

      this.__input = new PSDataCollection<object>();
      this.__output = new PSDataCollection<PSObject>();
      this.__runspace = RunspaceFactory.CreateRunspace(this.__psCmdlet.Host, iss);
      this.__powershell = PowerShell.Create();
      this.__powershell.Runspace = this.__runspace;
      this.__powershell.InvocationStateChanged += (sender, psStateChanged) => this.SetJobState(psStateChanged.InvocationStateInfo);

      this.PSJobTypeName = "Promise";

      this.Information = this.__powershell.Streams.Information;
      this.Information.EnumeratorNeverBlocks = true;

      this.Debug = this.__powershell.Streams.Debug;
      this.Debug.EnumeratorNeverBlocks = true;

      this.Output = this.__output;
      this.Output.EnumeratorNeverBlocks = true;

      this.Progress = this.__powershell.Streams.Progress;
      this.Progress.EnumeratorNeverBlocks = true;

      this.Error = this.__powershell.Streams.Error;
      this.Error.EnumeratorNeverBlocks = true;

      this.Warning = this.__powershell.Streams.Warning;
      this.Warning.EnumeratorNeverBlocks = true;

      var PromiseDefinition = new JobDefinition(typeof(PromiseSourceAdapter), "", this.Name);
      Dictionary<string, object> parameterCollection = new Dictionary<string, object>();
      parameterCollection.Add("NewJob", this);
      var jobSpecification = new JobInvocationInfo(PromiseDefinition, parameterCollection);
      var newJob = this.__psCmdlet.JobManager.NewJob(jobSpecification);
      System.Diagnostics.Debug.Assert(newJob == this, "JobManager must return this job");
    }

    #endregion

    #region Overrides
    protected override void Dispose(bool disposing)
    {
      if (disposing)
      {
        if (this.__powershell.InvocationStateInfo.State == PSInvocationState.Running)
        {
          this.__powershell.Stop();
        }

        this.__powershell.Dispose();
        this.__input.Complete();
        this.__output.Complete();
      }

      base.Dispose(disposing);
    }
    public override bool HasMoreData => (this.Output.Count > 0 ||
                                         this.Error.Count > 0 ||
                                         this.Progress.Count > 0 ||
                                         this.Verbose.Count > 0 ||
                                         this.Debug.Count > 0 ||
                                         this.Warning.Count > 0);

    public override string Location => "PowerShell";

    public override string StatusMessage => string.Empty;

    public override void StartJob()
    {
      if (this.JobStateInfo.State != JobState.NotStarted)
      {
        throw new Exception("Cannot start job because it is not in NotStarted state.");
      }

      this.__runspace.Open();
      try
      {
        var currentLocationPath = this.__psCmdlet.SessionState.Path.CurrentLocation.Path;
        using (var ps = PowerShell.Create())
        {
          ps.Runspace = this.__runspace;
          ps.AddCommand("Set-Location").AddParameter("LiteralPath", currentLocationPath).Invoke();
        }
      }
      catch (System.Exception) { }

      this.__powershell.Commands.Clear();
      this.__powershell.AddScript(this.__scriptBlock.ToString());
      if (this.__argumentList != null)
      {
        foreach (var arg in this.__argumentList)
        {
          this.__powershell.AddArgument(arg);
        }
      }

      if (this.__usings != null && this.__usings.Count > 0)
      {
        this.__powershell.AddParameter(Promise.VERBATIM_ARGUMENT, this.__usings);
      }

      this.__powershell.BeginInvoke<object, PSObject>(this.__input, this.__output);
    }

    public override void StartJobAsync()
    {
      this.StartJob();
      this.OnStartJobCompleted(new AsyncCompletedEventArgs(null, false, this));
    }

    public override void StopJob()
    {
      this.__powershell.Stop();
    }

    public override void StopJob(bool force, string reason)
    {
      this.StopJob();
    }

    public override void StopJobAsync()
    {
      this.__powershell.BeginStop((iasync) =>
      {
        this.OnStopJobCompleted(new AsyncCompletedEventArgs(null, false, this));
      }, null);
    }

    public override void StopJobAsync(bool force, string reason)
    {
      this.StopJobAsync();
    }

    public override void SuspendJob()
    {
      throw new System.NotImplementedException();
    }

    public override void SuspendJob(bool force, string reason)
    {
      throw new System.NotImplementedException();
    }

    public override void ResumeJob()
    {
      throw new System.NotImplementedException();
    }

    public override void ResumeJobAsync()
    {
      throw new System.NotImplementedException();
    }

    public override void SuspendJobAsync()
    {
      throw new System.NotImplementedException();
    }

    public override void SuspendJobAsync(bool force, string reason)
    {
      throw new System.NotImplementedException();
    }

    public override void UnblockJob()
    {
      throw new System.NotImplementedException();
    }

    public override void UnblockJobAsync()
    {
      throw new System.NotImplementedException();
    }

    #endregion

    #region Overloads
    private void SetJobState(PSInvocationStateInfo invocationStateInfo)
    {
      var disposeRunspace = false;
      System.Enum.TryParse<JobState>(invocationStateInfo.State.ToString(), out JobState jobState);
      switch (invocationStateInfo.State)
      {
        case PSInvocationState.Running:
          this.SetJobState(JobState.Running);
          break;

        case PSInvocationState.Completed:
        case PSInvocationState.Stopped:
        case PSInvocationState.Failed:
          this.SetJobState(jobState, invocationStateInfo.Reason);
          disposeRunspace = true;
          break;
      }

      if (disposeRunspace)
      {
        this.__runspace.Dispose();
      }
    }

    #endregion
  }
}
