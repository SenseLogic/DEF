// -- IMPORTS

import { buildDefText } from './building.js';
import { getDumpText } from './dumping.js';
import { haveSameValue } from './equivalence.js';
import { parseDefText } from './parsing.js';
import {
    getDefTextHash,
    getDefTextTuid,
    getDefTextUuid,
    getNaturalTextComparison,
    processDefQuotedString,
    } from './processing.js';
import { fetchTextFile, readDefFile } from './reading.js';

// -- EXPORTS

export {
    buildDefText,
    getDefTextHash,
    getDefTextTuid,
    getDefTextUuid,
    getDumpText,
    getNaturalTextComparison,
    haveSameValue,
    parseDefText,
    processDefQuotedString,
    fetchTextFile,
    readDefFile
    };
