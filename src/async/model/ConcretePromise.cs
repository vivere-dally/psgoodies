using System.Management.Automation;
using System.Threading.Tasks;

namespace PSGoodies.Async.Model
{
  public class ConcretePromise : Promise
  {
    public ConcretePromise(Task<System.Collections.ObjectModel.Collection<PSObject>> task)
      : base(task)
    {
    }

    public Task<System.Collections.ObjectModel.Collection<PSObject>> GetTask()
    {
      return this.Task;
    }
  }
}
