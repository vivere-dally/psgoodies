using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsLifecycle.Complete, "gPromise")]
  [Alias("Complete", "gComplete")]
  [OutputType(typeof(Promise))]
  public class CompletePromise : PSCmdlet
  {
    [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
    public Promise Promise { get; set; }

    protected override void ProcessRecord()
    {
      try
      {
        Promise.Task.Wait();
        WriteObject(Promise.Task.Result, true);
      }
      catch (System.Exception exception)
      {
        WriteError(new ErrorRecord(exception, System.Guid.NewGuid().ToString(), ErrorCategory.InvalidOperation, Promise));
      }
    }
  }
}
