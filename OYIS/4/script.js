const fs = require('fs');

// Функции для Space Steganography
function embedSpace(text, message) {
  let binary = message.split('').map(c => c.charCodeAt(0).toString(2).padStart(8, '0')).join('');
  let result = '';
  let binIndex = 0;
  for (let char of text) {
    result += char;
    if (char === ' ' && binIndex < binary.length) {
      result += (binary[binIndex] === '0' ? '\u2009' : '\u00A0'); // Тонкий пробел для 0, неразрывный для 1
      binIndex++;
    }
  }
  // Если осталось бинарных данных, но пробелов не хватило, добавляем в конец (для демонстрации)
  while (binIndex < binary.length) {
    result += ' ' + (binary[binIndex] === '0' ? '\u2009' : '\u00A0');
    binIndex++;
  }
  return result;
}

function extractSpace(text) {
  let binary = '';
  let collecting = false;
  for (let char of text) {
    if (char === ' ') collecting = true;
    else if (collecting && (char === '\u2009' || char === '\u00A0')) {
      binary += (char === '\u2009' ? '0' : '1');
      collecting = false;
    }
  }
  let bytes = binary.match(/.{8}/g) || [];
  return bytes.map(b => String.fromCharCode(parseInt(b, 2))).join('');
}

// Функции для Zero-Width Steganography
function embedZeroWidth(text, message) {
  let binary = message.split('').map(c => c.charCodeAt(0).toString(2).padStart(8, '0')).join('');
  let result = text[0] || '';
  let binIndex = 0;
  for (let i = 1; i < text.length; i++) {
    if (binIndex < binary.length) {
      let bit = binary[binIndex];
      result += (bit === '0' ? '\u200C' : '\u200D');
      binIndex++;
    }
    result += text[i];
  }
  // Если осталось бинарных данных, добавляем в конец
  while (binIndex < binary.length) {
    result += (binary[binIndex] === '0' ? '\u200C' : '\u200D');
    binIndex++;
  }
  return result;
}

function extractZeroWidth(text) {
  let binary = '';
  for (let char of text) {
    if (char === '\u200C') binary += '0';
    else if (char === '\u200D') binary += '1';
  }
  let bytes = binary.match(/.{8}/g) || [];
  return bytes.map(b => String.fromCharCode(parseInt(b, 2))).join('');
}

// Определение текстов разной длины (cover texts)
const coverTexts = [
  {
    name: 'Short (English)',
    text: 'This is a short text.'
  },
  {
    name: 'Medium (English)',
    text: 'This is a medium length text with more words to embed data into. It has several sentences and allows for more steganography capacity.'
  },
  {
    name: 'Long (English)',
    text: 'This is a long text for testing steganography methods. It includes multiple paragraphs to simulate real-world usage. Steganography hides information within this text without altering its appearance significantly. We can embed secret messages of varying lengths and observe the changes in text size and detectability. This helps in comparing the efficiency of different methods like space replacement and zero-width characters.'
  },
  {
    name: 'Short (Russian)',
    text: 'Это короткий текст.'
  },
  {
    name: 'Medium (Russian)',
    text: 'Это текст средней длины с большим количеством слов для встраивания данных. В нём несколько предложений и возможностей для стеганографии.'
  },
  {
    name: 'Long (Russian)',
    text: 'Это длинный текст для тестирования методов стеганографии. Он включает несколько абзацев для имитации реального использования. Стеганография скрывает информацию внутри этого текста без значительного изменения его вида. Мы можем встраивать секретные сообщения разной длины и наблюдать изменения в размере текста и обнаруживаемости. Это помогает сравнивать эффективность различных методов, таких как замена пробелов и использование символов нулевой ширины.'
  }
];

// Определение секретных сообщений разной длины
const secretMessages = [
  {
    name: 'Short',
    msg: 'Hi'  // ~2 chars, 16 bits
  },
  {
    name: 'Medium',
    msg: 'Hello, this is a secret message!'  // ~30 chars, ~240 bits
  },
  {
    name: 'Long',
    msg: 'This is a very long secret message for testing purposes. It should simulate a scenario where a substantial amount of data is hidden within the cover text. We can observe how the embedding affects the overall text length and potential detectability in different steganography methods.'  // ~200 chars, ~1600 bits
  }
];

// Сбор результатов
const results = [];

// Максимальное увеличение для нормализации графиков (будет вычислено позже)
let maxIncrease = 0;

// Тестирование
coverTexts.forEach(cover => {
  secretMessages.forEach(secret => {
    // Space method
    let embeddedSpace = embedSpace(cover.text, secret.msg);
    let extractedSpace = extractSpace(embeddedSpace);
    if (extractedSpace !== secret.msg) {
      console.error(`Error in Space extraction for ${cover.name} / ${secret.name}`);
    }
    let origLen = cover.text.length;
    let embLenSpace = embeddedSpace.length;
    let increaseSpace = ((embLenSpace - origLen) / origLen * 100) || 0;
    results.push({
      cover: cover.name,
      secret: secret.name,
      method: 'Space',
      origLen,
      embLen: embLenSpace,
      increase: increaseSpace.toFixed(2) + '%'
    });
    if (increaseSpace > maxIncrease) maxIncrease = increaseSpace;

    // Zero-Width method
    let embeddedZero = embedZeroWidth(cover.text, secret.msg);
    let extractedZero = extractZeroWidth(embeddedZero);
    if (extractedZero !== secret.msg) {
      console.error(`Error in Zero-Width extraction for ${cover.name} / ${secret.name}`);
    }
    let embLenZero = embeddedZero.length;
    let increaseZero = ((embLenZero - origLen) / origLen * 100) || 0;
    results.push({
      cover: cover.name,
      secret: secret.name,
      method: 'Zero-Width',
      origLen,
      embLen: embLenZero,
      increase: increaseZero.toFixed(2) + '%'
    });
    if (increaseZero > maxIncrease) maxIncrease = increaseZero;
  });
});

// Вывод таблицы результатов
console.log('Results Table:');
console.table(results);

// Сохранение примеров в HTML (для одного примера)
const exampleCover = coverTexts[0].text;
const exampleSecret = secretMessages[0].msg;
const embeddedSpaceEx = embedSpace(exampleCover, exampleSecret);
const embeddedZeroEx = embedZeroWidth(exampleCover, exampleSecret);
fs.writeFileSync('embedded_space.html', `<p>${embeddedSpaceEx}</p>`);
fs.writeFileSync('embedded_zero.html', `<p>${embeddedZeroEx}</p>`);

// Функция для отрисовки ASCII бара
function printBar(label, value, maxValue, barWidth = 50) {
  const barLength = Math.round((value / maxValue) * barWidth);
  const bar = '#'.repeat(barLength) + ' '.repeat(barWidth - barLength);
  console.log(`${label.padEnd(20)} |${bar}| ${value.toFixed(2)}%`);
}

// Построение графиков (ASCII bar charts) для каждого cover text
coverTexts.forEach(cover => {
  console.log(`\nGraph for Cover Text: ${cover.name} (Increase % vs Secret Length)`);
  console.log('-'.repeat(80));
  secretMessages.forEach(secret => {
    const spaceResult = results.find(r => r.cover === cover.name && r.secret === secret.name && r.method === 'Space');
    const zeroResult = results.find(r => r.cover === cover.name && r.secret === secret.name && r.method === 'Zero-Width');
    
    console.log(`Secret: ${secret.name}`);
    printBar('Space', parseFloat(spaceResult.increase), maxIncrease);
    printBar('Zero-Width', parseFloat(zeroResult.increase), maxIncrease);
    console.log('');
  });
  console.log('-'.repeat(80));
});