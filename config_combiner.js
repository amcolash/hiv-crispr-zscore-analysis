// Counts less than (not including) this value will be excluded
const countThreshold = 10;

// Count exclusion will only happen for these columns (the entire row will be excluded)
const thresholdExclusions = ['LAI_gDNA1', 'LAI_gDNA2'];

// Make these values available in other places
module.exports = { countThreshold, thresholdExclusions };
