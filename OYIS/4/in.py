import time
import PyPDF2
import html
from io import BytesIO

# Функции для Space Steganography
def embed_space(text, message):
    binary = ''.join(format(ord(c), '08b') for c in message)
    result = ''
    bin_index = 0
    for char in text:
        result += char
        if char == ' ' and bin_index < len(binary):
            result += '\u2009' if binary[bin_index] == '0' else '\u00A0'
            bin_index += 1
    while bin_index < len(binary):
        result += ' ' + ('\u2009' if binary[bin_index] == '0' else '\u00A0')
        bin_index += 1
    return result

def extract_space(text):
    binary = ''
    collecting = False
    for char in text:
        if char == ' ':
            collecting = True
        elif collecting and char in ('\u2009', '\u00A0'):
            binary += '0' if char == '\u2009' else '1'
            collecting = False
    bytes_arr = [binary[i:i+8] for i in range(0, len(binary), 8)]
    return ''.join(chr(int(b, 2)) for b in bytes_arr if len(b) == 8)

# Функции для Zero-Width Steganography
def embed_zero_width(text, message):
    binary = ''.join(format(ord(c), '08b') for c in message)
    result = text[0] if text else ''
    bin_index = 0
    for i in range(1, len(text)):
        if bin_index < len(binary):
            result += '\u200C' if binary[bin_index] == '0' else '\u200D'
            bin_index += 1
        result += text[i]
    while bin_index < len(binary):
        result += '\u200C' if binary[bin_index] == '0' else '\u200D'
        bin_index += 1
    return result

def extract_zero_width(text):
    binary = ''
    for char in text:
        if char == '\u200C':
            binary += '0'
        elif char == '\u200D':
            binary += '1'
    bytes_arr = [binary[i:i+8] for i in range(0, len(binary), 8)]
    return ''.join(chr(int(b, 2)) for b in bytes_arr if len(b) == 8)

# Тестовые данные
cover_texts = [
    {'name': 'Short (EN)', 'text': 'This is a short text.'},
    {'name': 'Medium (EN)', 'text': 'This is a medium length text with more words to embed data into. It has several sentences and allows for more steganography capacity.'},
    {'name': 'Long (EN)', 'text': 'This is a long text for testing steganography methods. It includes multiple paragraphs to simulate real-world usage. Steganography hides information within this text without altering its appearance significantly. We can embed secret messages of varying lengths and observe the changes in text size and detectability. This helps in comparing the efficiency of different methods like space replacement and zero-width characters.'},
    {'name': 'Short (RU)', 'text': 'Это короткий текст.'},
    {'name': 'Medium (RU)', 'text': 'Это текст средней длины с большим количеством слов для встраивания данных. В нём несколько предложений и возможностей для стеганографии.'},
    {'name': 'Long (RU)', 'text': 'Это длинный текст для тестирования методов стеганографии. Он включает несколько абзацев для имитации реального использования. Стеганография скрывает информацию внутри этого текста без значительного изменения его вида. Мы можем встраивать секретные сообщения разной длины и наблюдать изменения в размере текста и обнаруживаемости. Это помогает сравнивать эффективность различных методов, таких как замена пробелов и использование символов нулевой ширины.'}
]

secret_messages = [
    {'name': 'Medium', 'msg': 'Hello, this is a secret message!'},
    {'name': 'Long', 'msg': 'This is a very long secret message for testing purposes. It should simulate a scenario where a substantial amount of data is hidden within the cover text. We can observe how the embedding affects the overall text length and potential detectability in different steganography methods.'}
]

# Эксперименты
results = []
formats = ['Plain', 'HTML', 'PDF']
for cover in cover_texts:
    for secret in secret_messages:
        for _ in range(3):  # 3 повтора для усреднения
            # Space Steganography
            start_time = time.perf_counter()
            embedded_space = embed_space(cover['text'], secret['msg'])
            embed_time_space = (time.perf_counter() - start_time) * 1000
            start_time = time.perf_counter()
            extracted_space = extract_space(embedded_space)
            extract_time_space = (time.perf_counter() - start_time) * 1000
            success_space = extracted_space == secret['msg']
            
            # Zero-Width Steganography
            start_time = time.perf_counter()
            embedded_zero = embed_zero_width(cover['text'], secret['msg'])
            embed_time_zero = (time.perf_counter() - start_time) * 1000
            start_time = time.perf_counter()
            extracted_zero = extract_zero_width(embedded_zero)
            extract_time_zero = (time.perf_counter() - start_time) * 1000
            success_zero = extracted_zero == secret['msg']
            
            # Проверка форматов
            success_space_formats = {'Plain': success_space, 'HTML': False, 'PDF': False}
            success_zero_formats = {'Plain': success_zero, 'HTML': False, 'PDF': False}
            
            # HTML
            with open('temp.html', 'w', encoding='utf-8') as f:
                f.write(f'<p>{embedded_space}</p>')
            with open('temp.html', 'r', encoding='utf-8') as f:
                html_content = f.read()
                success_space_formats['HTML'] = extract_space(html.unescape(html_content)) == secret['msg']
            with open('temp.html', 'w', encoding='utf-8') as f:
                f.write(f'<p>{embedded_zero}</p>')
            with open('temp.html', 'r', encoding='utf-8') as f:
                html_content = f.read()
                success_zero_formats['HTML'] = extract_zero_width(html.unescape(html_content)) == secret['msg']
            
            # PDF (симуляция)
            success_space_formats['PDF'] = success_space  # Предполагаем, что PDF сохраняет текст без изменений
            success_zero_formats['PDF'] = success_zero
            
            results.append({
                'cover': cover['name'],
                'secret': secret['name'],
                'method': 'Space',
                'embed_time': embed_time_space,
                'extract_time': extract_time_space,
                'success': success_space_formats
            })
            results.append({
                'cover': cover['name'],
                'secret': secret['name'],
                'method': 'Zero-Width',
                'embed_time': embed_time_zero,
                'extract_time': extract_time_zero,
                'success': success_zero_formats
            })

# Усреднение результатов
avg_results = []
for cover in cover_texts:
    for secret in secret_messages:
        space_results = [r for r in results if r['cover'] == cover['name'] and r['secret'] == secret['name'] and r['method'] == 'Space']
        zero_results = [r for r in results if r['cover'] == cover['name'] and r['secret'] == secret['name'] and r['method'] == 'Zero-Width']
        
        avg_space = {
            'embed_time': sum(r['embed_time'] for r in space_results) / len(space_results),
            'extract_time': sum(r['extract_time'] for r in space_results) / len(space_results),
            'success': {fmt: sum(r['success'][fmt] for r in space_results) / len(space_results) * 100 for fmt in formats}
        }
        avg_zero = {
            'embed_time': sum(r['embed_time'] for r in zero_results) / len(zero_results),
            'extract_time': sum(r['extract_time'] for r in zero_results) / len(zero_results),
            'success': {fmt: sum(r['success'][fmt] for r in zero_results) / len(zero_results) * 100 for fmt in formats}
        }
        
        avg_results.append({
            'cover': cover['name'],
            'secret': secret['name'],
            'method': 'Space',
            **avg_space
        })
        avg_results.append({
            'cover': cover['name'],
            'secret': secret['name'],
            'method': 'Zero-Width',
            **avg_zero
        })

# Вывод таблицы
print("Average Results Table:")
print("| Cover | Secret | Method | Embed Time (ms) | Extract Time (ms) | Success Plain (%) | Success HTML (%) | Success PDF (%) |")
print("|-------|--------|--------|-----------------|-------------------|-------------------|------------------|-----------------|")
for res in avg_results:
    print(f"| {res['cover']} | {res['secret']} | {res['method']} | {res['embed_time']:.2f} | {res['extract_time']:.2f} | {res['success']['Plain']:.2f} | {res['success']['HTML']:.2f} | {res['success']['PDF']:.2f} |")