using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;

namespace BSTU.Results.Collection;

public class ResultsService : IResultsService
{
    private readonly string _filePath;
    private readonly object _lock = new object();
    private List<ResultItem> _collection = new List<ResultItem>();
    private int _nextKey = 1;

    public ResultsService(string filePath = "results.json")
    {
        _filePath = filePath;
        LoadFromFile();
    }

    private void LoadFromFile()
    {
        lock (_lock)
        {
            if (File.Exists(_filePath))
            {
                var json = File.ReadAllText(_filePath);
                _collection = JsonConvert.DeserializeObject<List<ResultItem>>(json) ?? new List<ResultItem>();
                _nextKey = _collection.Any() ? _collection.Max(x => x.Key) + 1 : 1;
            }
        }
    }

    private void SaveToFile()
    {
        lock (_lock)
        {
            var json = JsonConvert.SerializeObject(_collection, Formatting.Indented);
            File.WriteAllText(_filePath, json);
        }
    }

    public IEnumerable<ResultItem> GetAll()
    {
        lock (_lock)
        {
            return _collection.ToList();
        }
    }

    public ResultItem? GetByKey(int key)
    {
        lock (_lock)
        {
            return _collection.FirstOrDefault(x => x.Key == key);
        }
    }

    public ResultItem Add(string value)
    {
        lock (_lock)
        {
            var item = new ResultItem { Key = _nextKey++, Value = value };
            _collection.Add(item);
            SaveToFile();
            return item;
        }
    }

    public ResultItem? Update(int key, string value)
    {
        lock (_lock)
        {
            var item = _collection.FirstOrDefault(x => x.Key == key);
            if (item != null)
            {
                item.Value = value;
                SaveToFile();
                return item;
            }
            return null;
        }
    }

    public ResultItem? Delete(int key)
    {
        lock (_lock)
        {
            var item = _collection.FirstOrDefault(x => x.Key == key);
            if (item != null)
            {
                _collection.Remove(item);
                SaveToFile();
                return item;
            }
            return null;
        }
    }
}