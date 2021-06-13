using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsOther.Use, "gFinally", DefaultParameterSetName = "Pipe")]
  [Alias("Finally")]
  [OutputType(typeof(Promise))]
  public class UseFinally : PSCmdlet
  {
    [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Position")]
    public Promise Promise { get; set; }

    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 1, ParameterSetName = "Position")]
    public ScriptBlock ScriptBlock { get; set; }

    protected override void ProcessRecord()
    {
      WriteWarning("UseFinally");
      WriteObject(new Promise(Resolve()));
    }

    private async Task<System.Collections.ObjectModel.Collection<PSObject>> Resolve()
    {
      System.Collections.ObjectModel.Collection<PSObject> result = null;
      try
      {
        result = await Promise.Task;
      }
      catch (System.Exception exception)
      {
        result = new System.Collections.ObjectModel.Collection<PSObject>();
        result.Add(new PSObject(new ErrorRecord(exception, exception.Source, ErrorCategory.InvalidOperation, Promise)));
      }

      ScriptBlock.Invoke();
      return result;
    }
  }
}
