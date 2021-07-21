using System.Management.Automation;
using System.Threading.Tasks;
using PSGoodies.Async.Model;

namespace PSGoodies.Async
{
  /// <summary>
  ///   <para type="synopsis">Start a Promise.</para>
  ///   <para type="description">The Start-gPromise cmdlet starts a Promise by using a given ScriptBlock.</para>
  ///   <para type="link" uri="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise">The JavaScript Promise.</para>
  /// </summary>
  /// <example>
  ///   <code>PS C:\> Start-gPromise { Invoke-WebRequest -Uri 'your_uri' } </code>
  ///   <para>This command starts a Promise that makes a web request.</para>
  /// </example>
  [Cmdlet(VerbsLifecycle.Start, "gPromise", DefaultParameterSetName = "Pipe")]
  [Alias("Start-Promise", "Promise", "gPromise")]
  [OutputType(typeof(Promise))]
  public class StartPromise : PSCmdlet
  {
    /// <summary>
    /// <para type="description">The ScriptBlock that will be ran asynchronously.</para>
    /// </summary>
    // [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Pipe")]
    // [Parameter(Mandatory = true, Position = 0, ParameterSetName = "Position")]
    [Parameter(Mandatory = true)]
    public ScriptBlock ScriptBlock { get; set; }

    /// <summary>
    /// <para type="description">Array of arguments that will be passed to the ScriptBlock.</para>
    /// </summary>
    // [Parameter(ValueFromPipeline = true, ParameterSetName = "Pipe")]
    // [Parameter(Position = 1, ParameterSetName = "Position")]
    [Parameter()]
    public PSObject[] ArgumentList { get; set; } = new PSObject[0];

    protected override void ProcessRecord()
    {
      WriteVerbose("START");
      WriteObject(new Promise(Resolve()));
      WriteVerbose("END");
    }

    private async Task<System.Collections.ObjectModel.Collection<PSObject>> Resolve()
    {
      var result = await Task.Run<System.Collections.ObjectModel.Collection<PSObject>>(() =>
      {
        return ScriptBlock.Invoke(ArgumentList);
      });

      return result;
    }
  }
}
