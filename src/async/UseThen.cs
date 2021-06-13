using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsOther.Use, "gThen", DefaultParameterSetName = "Pipe")]
  [Alias("Then")]
  [OutputType(typeof(Promise))]
  public class UseThen : PSCmdlet
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
        System.Collections.ObjectModel.Collection<PSObject> result = await Promise.Task;
        PSObject[] resultArray = new PSObject[result.Count];
        for (int i = 0; i < result.Count; i++)
        {
          resultArray[i] = result[i];
        }

        return ScriptBlock.Invoke(resultArray);
      }
      catch (System.Exception exception)
      {
        throw exception;
      }
    }
  }
}
