using System.Collections.Generic;

namespace BSTU.Results.Collection;

public interface IResultsService
{
    IEnumerable<ResultItem> GetAll();
    ResultItem? GetByKey(int key);
    ResultItem Add(string value);
    ResultItem? Update(int key, string value);
    ResultItem? Delete(int key);
}