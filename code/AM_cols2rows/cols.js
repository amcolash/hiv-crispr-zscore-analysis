const { readFileSync, writeFileSync } = require('fs');
const { join } = require('path');

const file = join(__dirname, process.argv[2] || 'zscores.csv');
const data = readFileSync(file).toString();

const rows = data.split('\n').map((r) => r.trim().split(/[,\t]/gm));
const headerColumns = rows[0];

let output = [];
output.push(['id', 'Z-Score R1', 'Z-Score R2', 'Experiment']);

rows.slice(1).forEach((r) => {
  const newRows = [];

  for (let i = 1; i < r.length - 1; i += 2) {
    newRows.push([r[0], r[i], r[i + 1], headerColumns[i].replace(/\sR[\d]/, '')]);
  }

  output.push(...newRows);
});

const outFile = join(__dirname, process.argv[2] || 'output.csv');
const outData = output.map((r) => r.join(',')).join('\n');

writeFileSync(outFile, outData);
