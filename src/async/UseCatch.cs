using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsOther.Use, "gCatch", DefaultParameterSetName = "Pipe")]
  [Alias("Catch")]
  [OutputType(typeof(Promise))]
  public class UseCatch : PSCmdlet
  {
    [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Position")]
    public Promise Promise { get; set; }

    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 1, ParameterSetName = "Position")]
    public ScriptBlock ScriptBlock { get; set; }

    protected override void ProcessRecord()
    {
      WriteWarning("UseCatch - enter");
      if (!Promise.Task.IsFaulted)
      {
        WriteWarning("UseCatch - not faulted");
        WriteObject(Promise);
        return;
      }

      WriteWarning("UseCatch");
      var promise = new Promise(Task.Run<System.Collections.ObjectModel.Collection<PSObject>>(() =>
      {
        return ScriptBlock.Invoke(Promise.Task.Exception);
      }));
      WriteWarning("UseCatch - exit");
      WriteObject(promise);
    }
  }
}
