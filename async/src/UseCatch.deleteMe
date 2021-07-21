using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  /// <summary>
  ///   <para type="synopsis">Handle a faulted Promise.</para>
  ///   <para type="description">The Use-gCatch cmdlet handles a faulted Promise by using a given ScriptBlock.</para>
  ///   <para type="link" uri="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/catch">The JavaScript Promise catch.</para>
  /// </summary>
  /// <example>
  ///   <code>PS C:\> Use-gCatch $promise { # handle error case } </code>
  ///   <para>This command handles a faulted Promise.</para>
  /// </example>
  [Cmdlet(VerbsOther.Use, "gCatch", DefaultParameterSetName = "Pipe")]
  [Alias("Use-Catch" , "Catch", "gCatch")]
  [OutputType(typeof(Promise))]
  public class UseCatch : PSCmdlet
  {
    /// <summary>
    /// <para type="description">The Promise that will be handled.</para>
    /// </summary>
    [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Position")]
    public Promise Promise { get; set; }

    /// <summary>
    /// <para type="description">The ScriptBlock that will be ran asynchronously. This ScriptBlock gets ran only if the Promise is faulted.</para>
    /// </summary>
    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 1, ParameterSetName = "Position")]
    public ScriptBlock ScriptBlock { get; set; }

    protected override void ProcessRecord()
    {
      WriteObject(new Promise(Resolve()));
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
