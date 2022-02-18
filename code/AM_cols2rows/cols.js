const { createHash } = require('crypto');
const { readdirSync, readFileSync, writeFileSync } = require('fs');
const { join } = require('path');

const inputDir = join(__dirname, '/input');

function getZscoreData() {
  // Load z score data
  const file = join(inputDir, '/zscores.csv');
  const data = readFileSync(file).toString().trim();

  // Determine rows and columns of csv
  const rows = data.split('\n').map((r) => r.trim().split(/[,\t]/gm));
  const headerColumns = rows[0];

  // Create a mapping of id -> experiment -> zscores
  let output = {};

  // Go through each row (excluding header) to build the maping (2 at a time)
  rows.slice(1).forEach((r) => {
    for (let i = 1; i < r.length - 1; i += 2) {
      output[r[0]] = output[r[0]] || {};

      // Determine experiment name based off of the header column name
      const experiement = headerColumns[i].replace(/\sR[\d]/, '').trim();
      output[r[0]][experiement] = output[r[0]][experiement] || {};

      // Use data from both rows as the r1 + r2 values - expects correctly ordered columns
      output[r[0]][experiement].R1 = r[i];
      output[r[0]][experiement].R2 = r[i + 1];
    }
  });

  return output;
}

// Get z score data
const zScores = getZscoreData();

// Prepare output
let output = [];

// Find all files in input/ that are the the zscore file
const files = readdirSync(inputDir).filter((f) => f.endsWith('.csv') && f.indexOf('zscores.csv') === -1);
files.forEach((f, i) => {
  // Load each file
  const file = join(inputDir, '/', f);
  const data = readFileSync(file).toString().trim();

  // Determine rows and columns of csv
  const rows = data.split('\n').map((r) => r.trim().split(/[,\t]/gm));

  // Get experiment name from file
  const experiment = f.replace('.csv', '');

  // Add some extra columns to the header row
  rows[0].push(...['screen', 'zscore r1', 'zscore r2', 'uuid']);

  // Go through each row after header and append new zscore data
  rows.slice(1).forEach((r) => {
    const id = r[0];

    // Generate a "UUID" - for this case it is perfectly fine. A number from 0-9999999 that is consistent across runs based off of gene id
    const uuid = createHash('md5').update(id).digest('hex').replace(/\D/g, '').substring(0, 7);

    r.push(...[experiment, zScores[id][experiment].R1, zScores[id][experiment].R2, uuid]);
  });

  // Add header column for first file
  if (i === 0) output.push(rows[0]);

  // Add all rows in the file to the final output array
  output.push(...rows.slice(1));
});

// Write the merged data
const outFile = join(__dirname, 'output.csv');
const outData = output.map((r) => r.join(',')).join('\n');

writeFileSync(outFile, outData);
