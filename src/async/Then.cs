using System;
using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  [Cmdlet(VerbsCommon.New, "Then")]
  public class Then : PSCmdlet
  {
    [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
    public Promise Promise { get; set; }

    [Parameter(Mandatory = true)]
    public ScriptBlock ScriptBlock { get; set; }

    protected override void ProcessRecord()
    {
      try
      {
        WriteObject(new Promise(Execute()));
      }
      catch (Exception exception)
      {
        
      }
    }

    private async Task<System.Collections.ObjectModel.Collection<PSObject>> Execute()
    {
      System.Collections.ObjectModel.Collection<PSObject> result = await Promise.Task;
      PSObject[] resultArray = new PSObject[result.Count];
      for (int i = 0; i < result.Count; i++)
      {
        resultArray[i] = result[i];
      }

      return ScriptBlock.Invoke(resultArray);
    }
  }
}
