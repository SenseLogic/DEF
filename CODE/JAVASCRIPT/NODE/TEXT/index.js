// -- IMPORTS

import { buildDefText } from './building.js';
import { getDumpText } from './dumping.js';
import { haveSameValue } from './equivalence.js';
import { fetchDefFile, fetchTextFile } from './fetching.js';
import { parseDefText } from './parsing.js';
import {
    getDefTextHash,
    getDefTextTuid,
    getDefTextUuid,
    getNaturalTextComparison,
    processDefQuotedString,
    } from './processing.js';

// -- EXPORTS

export {
    buildDefText,
    fetchDefFile,
    fetchTextFile,
    getDefTextHash,
    getDefTextTuid,
    getDefTextUuid,
    getDumpText,
    getNaturalTextComparison,
    haveSameValue,
    parseDefText,
    processDefQuotedString
    };
