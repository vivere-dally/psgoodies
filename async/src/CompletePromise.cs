using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  /// <summary>
  ///   <para type="synopsis">Complete a Promise.</para>
  ///   <para type="description">The Complete-gPromise cmdlet waits for the completion of a Promise.</para>
  ///   <para type="link" uri="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await">The JavaScript await.</para>
  /// </summary>
  /// <example>
  ///   <code>PS C:\> Complete-gPromise $promise </code>
  ///   <para>This command waits for the completion of a Promise.</para>
  /// </example>
  [Cmdlet(VerbsLifecycle.Complete, "gPromise")]
  [Alias("Complete-Promise", "Complete", "gComplete")]
  [OutputType(typeof(PSObject))]
  public class CompletePromise : PSCmdlet
  {
    /// <summary>
    /// <para type="description">The Promise that will be handled.</para>
    /// </summary>
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
