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
      WriteObject(new Promise(this.Resolve()));
    }

    private async Task<System.Collections.ObjectModel.Collection<PSObject>> Resolve()
    {
      try
      {
        var result = await Promise.Task;
        return result;
      }
      catch (System.Exception exception)
      {
        return ScriptBlock.Invoke(exception);
      }
    }
  }
}
