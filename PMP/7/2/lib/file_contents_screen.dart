import 'package:flutter/material.dart';

class FileContentsScreen extends StatelessWidget {
  final List<String> contents;

  const FileContentsScreen({Key? key, required this.contents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Contents'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Содержимое сохраненных файлов:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  final content = contents[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        content.contains('File not found') ?
                        Icons.error_outline : Icons.check_circle,
                        color: content.contains('File not found') ?
                        Colors.red : Colors.green,
                      ),
                      title: Text(
                        _getFileName(content),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        _getFileContent(content),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // Показать полное содержимое при тапе
                        _showFullContent(context, content);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            _buildSummary(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  String _getFileName(String content) {
    if (content.startsWith('Temp:')) return 'Temporary File';
    if (content.startsWith('Doc:')) return 'Documents File';
    if (content.startsWith('Support:')) return 'Support File';
    if (content.startsWith('Library:')) return 'Library File (iOS only)';
    if (content.startsWith('Cache:')) return 'Cache File (iOS only)';
    if (content.startsWith('External:')) return 'External Storage (Android only)';
    if (content.startsWith('External Cache:')) return 'External Cache (Android only)';
    if (content.startsWith('Downloads:')) return 'Downloads File';
    return 'Unknown File';
  }

  String _getFileContent(String content) {
    final parts = content.split(':');
    if (parts.length > 1) {
      return parts.sublist(1).join(':').trim();
    }
    return content;
  }

  void _showFullContent(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getFileName(content)),
        content: SingleChildScrollView(
          child: Text(_getFileContent(content)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final existingFiles = contents.where(
            (content) => !content.contains('File not found') &&
            !content.contains('not supported') &&
            !content.contains('not available')
    ).length;

    final totalFiles = contents.length;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Файлов найдено:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            '$existingFiles из $totalFiles',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: existingFiles == totalFiles ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}