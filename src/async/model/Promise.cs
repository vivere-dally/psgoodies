using System.Management.Automation;
using System.Threading.Tasks;

namespace PSGoodies.Async.Model
{
  public abstract class Promise
  {
    protected Task<System.Collections.ObjectModel.Collection<PSObject>> Task { get; private set; }

    public Promise(Task<System.Collections.ObjectModel.Collection<PSObject>> task)
    {
      this.Task = task;
    }
  }
}
