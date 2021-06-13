using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsLifecycle.Start, "gPromise", DefaultParameterSetName = "Pipe")]
  [Alias("Promise")]
  [OutputType(typeof(Promise))]
  public class StartPromise : PSCmdlet
  {
    [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Position")]
    public ScriptBlock ScriptBlock { get; set; }

    [Parameter(Position = 0, ParameterSetName = "Pipe")]
    [Parameter(Position = 1, ParameterSetName = "Position")]
    public PSObject[] ArgumentList { get; set; } = new PSObject[0];

    protected override void ProcessRecord()
    {
      var task = Task.Run<System.Collections.ObjectModel.Collection<PSObject>>(() =>
      {
        return ScriptBlock.Invoke(ArgumentList);
      });

      WriteObject(new Promise(task));
    }
  }
}
