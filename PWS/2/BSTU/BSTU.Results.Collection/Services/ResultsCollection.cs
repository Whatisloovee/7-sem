using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace BSTU.Results.Collection
{
    public class ResultsCollection : IResultsCollection
    {
        private readonly string _filePath = "results.json";
        private readonly SemaphoreSlim _semaphore = new SemaphoreSlim(1, 1);
        private int _nextKey = 1;

        public ResultsCollection()
        {
            InitializeNextKeyAsync().ConfigureAwait(false).GetAwaiter().GetResult();
        }

        private async Task InitializeNextKeyAsync()
        {
            await _semaphore.WaitAsync();
            try
            {
                var results = await ReadFromFileAsync();
                _nextKey = results.Any() ? results.Max(r => r.Key) + 1 : 1;
            }
            finally
            {
                _semaphore.Release();
            }
        }

        public async Task<IEnumerable<ResultItem>> GetAllAsync()
        {
            await _semaphore.WaitAsync();
            try
            {
                return await ReadFromFileAsync();
            }
            finally
            {
                _semaphore.Release();
            }
        }

        public async Task<ResultItem> GetAsync(int key)
        {
            await _semaphore.WaitAsync();
            try
            {
                var results = await ReadFromFileAsync();
                return results.FirstOrDefault(r => r.Key == key);
            }
            finally
            {
                _semaphore.Release();
            }
        }

        public async Task<ResultItem> AddAsync(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Value cannot be null or empty");

            await _semaphore.WaitAsync();
            try
            {
                var results = (await ReadFromFileAsync()).ToList();
                var newItem = new ResultItem { Key = _nextKey++, Value = value };
                results.Add(newItem);

                await SaveResultsAsync(results);
                return newItem;
            }
            finally
            {
                _semaphore.Release();
            }
        }

        public async Task<ResultItem> UpdateAsync(int key, string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Value cannot be null or empty");

            await _semaphore.WaitAsync();
            try
            {
                var results = (await ReadFromFileAsync()).ToList();
                var item = results.FirstOrDefault(r => r.Key == key);

                if (item == null)
                    return null;

                item.Value = value;
                await SaveResultsAsync(results);
                return item;
            }
            finally
            {
                _semaphore.Release();
            }
        }

        public async Task<ResultItem> DeleteAsync(int key)
        {
            await _semaphore.WaitAsync();
            try
            {
                var results = (await ReadFromFileAsync()).ToList();
                var item = results.FirstOrDefault(r => r.Key == key);

                if (item == null)
                    return null;

                results.Remove(item);
                await SaveResultsAsync(results);
                return item;
            }
            finally
            {
                _semaphore.Release();
            }
        }

        private async Task<List<ResultItem>> ReadFromFileAsync()
        {
            if (!File.Exists(_filePath))
                return new List<ResultItem>();

            try
            {
                var json = await File.ReadAllTextAsync(_filePath);
                return JsonSerializer.Deserialize<List<ResultItem>>(json) ?? new List<ResultItem>();
            }
            catch (Exception)
            {
                return new List<ResultItem>();
            }
        }

        private async Task SaveResultsAsync(List<ResultItem> results)
        {
            var options = new JsonSerializerOptions { WriteIndented = true };
            var json = JsonSerializer.Serialize(results, options);
            await File.WriteAllTextAsync(_filePath, json);
        }

        #region Синхронные методы для обратной совместимости

        public IEnumerable<ResultItem> GetAll()
        {
            return GetAllAsync().ConfigureAwait(false).GetAwaiter().GetResult();
        }

        public ResultItem Get(int key)
        {
            return GetAsync(key).ConfigureAwait(false).GetAwaiter().GetResult();
        }

        public ResultItem Add(string value)
        {
            return AddAsync(value).ConfigureAwait(false).GetAwaiter().GetResult();
        }

        public ResultItem Update(int key, string value)
        {
            return UpdateAsync(key, value).ConfigureAwait(false).GetAwaiter().GetResult();
        }

        public ResultItem Delete(int key)
        {
            return DeleteAsync(key).ConfigureAwait(false).GetAwaiter().GetResult();
        }

        #endregion
    }
}