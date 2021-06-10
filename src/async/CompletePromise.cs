using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsLifecycle.Complete, "gFinally")]
  [OutputType(typeof(Promise))]
  public class CompletePromise : PSCmdlet
  {
    [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
    public Promise Promise { get; set; }

    [Parameter(Mandatory = true)]
    public ScriptBlock ScriptBlock { get; set; }

    protected override void ProcessRecord()
    {
      var concretePromise = (ConcretePromise) Promise;
      if (concretePromise.GetTask().IsFaulted) {
        WriteObject(Promise);
      }

      concretePromise = new ConcretePromise(this.Resolve());
      WriteObject((Promise) concretePromise);
    }

    private async Task<System.Collections.ObjectModel.Collection<PSObject>> Resolve()
    {
      System.Collections.ObjectModel.Collection<PSObject> result = await ((ConcretePromise) Promise).GetTask();
      PSObject[] resultArray = new PSObject[result.Count];
      for (int i = 0; i < result.Count; i++)
      {
        resultArray[i] = result[i];
      }

      return ScriptBlock.Invoke(resultArray);
    }
  }
}
