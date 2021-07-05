using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{  /// <summary>
  ///   <para type="synopsis">Handle a successful Promise.</para>
  ///   <para type="description">The Use-gThen cmdlet handles a successful Promise by using a given ScriptBlock.</para>
  ///   <para type="link" uri="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/then">The JavaScript Promise then.</para>
  /// </summary>
  /// <example>
  ///   <code>PS C:\> Use-gThen $promise { # handle successful case } </code>
  ///   <para>This command handles a successful Promise.</para>
  /// </example>
  [Cmdlet(VerbsOther.Use, "gThen", DefaultParameterSetName = "Pipe")]
  [Alias("Use-Then", "Then", "gThen")]
  [OutputType(typeof(Promise))]
  public class UseThen : PSCmdlet
  {
    /// <summary>
    /// <para type="description">The Promise that will be handled.</para>
    /// </summary>
    [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Position")]
    public Promise Promise { get; set; }

    /// <summary>
    /// <para type="description">The ScriptBlock that will be ran asynchronously. This ScriptBlock gets ran only if the Promise is successful.</para>
    /// </summary>
    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 1, ParameterSetName = "Position")]
    public ScriptBlock ScriptBlock { get; set; }

    protected override void ProcessRecord()
    {
      WriteObject(new Promise(this.Resolve()));
    }

    private async Task<System.Collections.ObjectModel.Collection<PSObject>> Resolve()
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
