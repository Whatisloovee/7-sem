using System.Collections.Generic;
using System.Threading.Tasks;

namespace BSTU.Results.Collection
{
    public interface IResultsCollection
    {
        Task<IEnumerable<ResultItem>> GetAllAsync();
        Task<ResultItem> GetAsync(int key);
        Task<ResultItem> AddAsync(string value);
        Task<ResultItem> UpdateAsync(int key, string value);
        Task<ResultItem> DeleteAsync(int key);

        IEnumerable<ResultItem> GetAll();
        ResultItem Get(int key);
        ResultItem Add(string value);
        ResultItem Update(int key, string value);
        ResultItem Delete(int key);
    }

    public class ResultItem
    {
        public int Key { get; set; }
        public string Value { get; set; }
    }
}
