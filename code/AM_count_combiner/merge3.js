// Import libraries
const fs = require('fs');
const { join } = require('path');

const { countThreshold, thresholdExclusions } = require('./config');

// Mapping of excel dates errors to valid names
const dateErrorMapping = {
  MARCH: '-Mar',
  MARC: '-Mar',
  SEPT: '-Sep',
  SEP: '-Sep',
  DEC: '-Dec',
};
const fixExcelDates = true;

// Find folder to process - either from argument in command, or hardcoded value
const folder = process.argv[2] || 'input';

// Find all text files in the data dir
const files = fs.readdirSync(join(__dirname, folder)).filter((v) => v.endsWith('.txt'));
console.log('Running analysis on input files:', files);

// Keep track of all headers encountered in the input files
const allHeaders = new Set();

// Make stage 1 dictionary - sgRNA -> values
const sgrnaCounts = {};

// Loop through each count data file, make a mapping of sgRNA -> counts
files.forEach((f) => {
  // Read the file
  const file = join(__dirname, folder, f);
  const data = fs.readFileSync(file);

  // Split the file into rows
  const rows = data.toString().trim().split('\n');

  // Get the header row column names
  const headers = rows[0].split(/[,\t]/gm);
  headers.forEach((h) => allHeaders.add(h.trim()));

  // Iterate through each row
  rows.forEach((row, rowIndex) => {
    // Skip first row
    if (rowIndex > 0) {
      const cols = row.trim().split(/[,\t]/gm);

      // sgRNA is always cols[0], make sure the dictionary for the row data exists
      const sgRNA = cols[0].trim();

      // Attempt to fix weird names from excel being promiscious (auto-dating)
      if (fixExcelDates) {
        const errorEntries = Object.entries(dateErrorMapping);
        for (let i = 0; i < errorEntries.length; i++) {
          const m = errorEntries[i];
          if (sgRNA.indexOf(m[0]) !== -1) {
            cols.forEach((c, j) => {
              if (c.indexOf(m[1]) !== -1) {
                cols[j] = m[0] + c.replace(m[1], '');
                // console.log(c, cols);
              }
            });
            break;
          }
        }
      }

      sgrnaCounts[sgRNA] = sgrnaCounts[sgRNA] || {};

      // Iterate through each column value and set the trimmedNTC to the column value
      cols.forEach((value, colIndex) => {
        // Skip "NA" values
        if (value.toLowerCase() !== 'na') {
          const colName = headers[colIndex].trim();
          sgrnaCounts[sgRNA][colName] = value;
        }
      });
    }
  });
});

// Make stage 2 dictionary - guide -> counts
const guideCounts = {};

// Make an array of sgRNA + guides
const library = [];

// Find the library files
const libraryFiles = fs.readdirSync(join(__dirname, folder)).filter((v) => v.endsWith('.csv'));
console.log('Using library files:', libraryFiles);

// Append missing sgRNA rows to the data from the library file
libraryFiles.forEach((f) => {
  // Read the file
  const file = join(__dirname, folder, f);
  const data = fs.readFileSync(file);

  // Split the file into rows
  const rows = data.toString().trim().split('\n');

  // Iterate through each row
  rows.forEach((row, rowIndex) => {
    // Skip first row
    if (rowIndex > 0) {
      // Split the row by commas
      const cols = row.trim().split(/[,\t]/gm);

      // sgRNA is always cols[0]
      const sgRNA = cols[0];

      // Attempt to fix weird names from excel being promiscious (auto-dating)
      if (fixExcelDates) {
        const errorEntries = Object.entries(dateErrorMapping);
        for (let i = 0; i < errorEntries.length; i++) {
          const m = errorEntries[i];
          if (sgRNA.indexOf(m[0]) !== -1) {
            cols.forEach((c, j) => {
              if (c.indexOf(m[1]) !== -1) {
                cols[j] = m[0] + c.replace(m[1], '');
                // console.log(c, cols);
              }
            });
            break;
          }
        }
      }

      // guide is always cols[1]
      const guide = cols[1];
      // gene is always cols[2]
      const Gene = cols[2];

      // Add counts for the given guide
      if (sgrnaCounts[sgRNA]) {
        guideCounts[guide] = sgrnaCounts[sgRNA];
      }

      // Add this guide to the library array
      library.push({ guide, sgRNA, Gene });
    }
  });
});

// Fill in missing data in the library
library.forEach((l, i) => {
  if (!guideCounts[l.guide]) {
    // console.log(l.guide);
  }

  library[i] = { ...guideCounts[l.guide], ...library[i] };
});

// Set up the final data string that will be written to file
let finalData = '';

// Make an Array from the Header Set
const headerArray = Array.from(allHeaders.values());

// Append header row to the final output
headerArray.forEach((h, i) => (finalData += `${h}${i < headerArray.length - 1 ? '\t' : ''}`));
finalData += '\n';

// Append each row to the final output
library.forEach((row) => {
  // Only append row if non-empty
  if (row) {
    // Check that all required columns are in the final data, exclude if data is missing
    let excludeRow = false;
    headerArray.forEach((h) => {
      if (!row[h]) excludeRow = true;
    });

    thresholdExclusions.forEach((c) => {
      if (row[c] < countThreshold) {
        excludeRow = true;
        console.log(`Removing row since it does not meet threshold: ${row[headerArray[0]]}, [${c}: ${row[c]}]`);
      }
    });

    // If all data needed is present, add the row to final data
    if (!excludeRow) {
      // Add each column from the combined headers to the row (this ensures that ordering is consistent across rows and missing values exist)
      headerArray.forEach((h, i) => (finalData += `${row[h] || ''}${i < headerArray.length - 1 ? '\t' : ''}`));

      // New line after the row
      finalData += '\n';
    }
  }
});

// Write the output file
const output = join(__dirname, 'counts_all.txt');
fs.writeFileSync(output, finalData);
