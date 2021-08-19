using System.Collections.Generic;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using PSGoodies.PromiseGoodies.Model;

namespace PSGoodies.PromiseGoodies.Cmdlets
{
  [Cmdlet(VerbsLifecycle.Start, "gInternalPromise")]
  [OutputType(typeof(Promise))]
  public class StartPromiseInternal : PSCmdlet
  {
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    public ScriptBlock ScriptBlock { get; set; }

    [Parameter()]
    [AllowEmptyCollection()]
    public Dictionary<string, object> Usings { get; set; } = new Dictionary<string, object>();

    [Parameter()]
    [AllowEmptyCollection()]
    public ICollection<SessionStateCommandEntry> CommandEntries { get; set; } = new List<SessionStateCommandEntry>();

    [Parameter()]
    [AllowEmptyCollection()]
    public PSObject[] ArgumentList { get; set; } = new PSObject[0];

    [Parameter()]
    [AllowNull()]
    public Promise ChildPromise { get; set; } = null;

    protected override void ProcessRecord()
    {
      var promise = new Promise(this.ScriptBlock, this.CommandEntries, this.Usings, this.ArgumentList, this, ChildPromise);
      promise.StartJob();
      WriteObject(promise);
    }
  }
}
