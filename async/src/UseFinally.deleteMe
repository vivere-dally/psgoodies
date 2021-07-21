using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  /// <summary>
  ///   <para type="synopsis">Handle a Promise regardless of its state.</para>
  ///   <para type="description">The Use-gFinally cmdlet handles a Promise regardless of its state, i.e. either successful or faulted, by using a given ScriptBlock.</para>
  ///   <para type="link" uri="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/finally">The JavaScript Promise finally.</para>
  /// </summary>
  /// <example>
  ///   <code>PS C:\> Use-gFinally $promise { # handle both cases } </code>
  ///   <para>This command handles a Promise regardless of its state.</para>
  /// </example>
  [Cmdlet(VerbsOther.Use, "gFinally", DefaultParameterSetName = "Pipe")]
  [Alias("Use-Finally", "Finally", "gFinally")]
  [OutputType(typeof(Promise))]
  public class UseFinally : PSCmdlet
  {
    /// <summary>
    /// <para type="description">The Promise that will be handled.</para>
    /// </summary>
    [Parameter(Mandatory = true, ValueFromPipeline = true, ParameterSetName = "Pipe")]
    [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Position")]
    public Promise Promise { get; set; }

    /// <summary>
    /// <para type="description">The ScriptBlock that will be ran asynchronously.</para>
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
      finally
      {
        ScriptBlock.Invoke();
      }

      return result;
    }
  }
}
