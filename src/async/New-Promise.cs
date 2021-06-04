using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsCommon.New, "GooPromise")]
  public class NewPromise : PSCmdlet
  {
    [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
    public ScriptBlock ScriptBlock { get; set; }

    [Parameter()]
    public PSObject[] ArgumentList { get; set; } = new PSObject[0];

    protected override void ProcessRecord()
    {
      var task = new Task<System.Collections.ObjectModel.Collection<PSObject>>(() =>
      {
        return ScriptBlock.Invoke(ArgumentList);
      });

      task.Start();
      WriteObject(new Promise(task));
    }
  }
}
