using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsLifecycle.Start, "gCatch")]
  [OutputType(typeof(Promise))]
  public class Catch : PSCmdlet
  {
    [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
    public Promise Promise { get; set; }

    [Parameter(Mandatory = true)]
    public ScriptBlock ScriptBlock { get; set; }

    protected override void ProcessRecord()
    {
      var concretePromise = (ConcretePromise)Promise;
      if (!concretePromise.GetTask().IsFaulted)
      {
        WriteObject(Promise);
      }

      concretePromise = new ConcretePromise(new Task<System.Collections.ObjectModel.Collection<PSObject>>(() =>
      {
        return ScriptBlock.Invoke(concretePromise.GetTask().Exception);
      }));
      WriteObject((Promise)concretePromise);
    }
  }
}
