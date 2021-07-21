using System.Collections.Generic;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using PSGoodies.Async.Model;

namespace PSGoodies.Async.Cmdlets
{
  [Cmdlet(VerbsLifecycle.Start, "gInternalPromise")]
  [OutputType(typeof(Promise))]
  public class StartPromiseInternal : PSCmdlet
  {
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    public ScriptBlock ScriptBlock { get; set; }

    [Parameter(Mandatory = true)]
    public Dictionary<string, object> Usings { get; set; }

    [Parameter(Mandatory = true)]
    public ICollection<SessionStateCommandEntry> CommandEntries { get; set; }

    [Parameter()]
    public PSObject[] ArgumentList { get; set; } = new PSObject[0];

    protected override void ProcessRecord()
    {
      var promise = new Promise(this.ScriptBlock, this.CommandEntries, this.Usings, this.ArgumentList, this);
      promise.StartJob();
      WriteObject(promise);
    }
  }
}
