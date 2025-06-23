// -- IMPORTS

import { buildDefText } from './building.js';
import { getDumpText } from './dumping.js';
import { haveSameValue } from './equivalence.js';
import { parseDefText } from './parsing.js';
import {
    getDefFilePathArray,
    getDefFolderPath,
    getDefTextHash,
    getDefTextTuid,
    getDefTextUuid,
    getNaturalTextComparison,
    processDefQuotedString,
    readDefFile,
    readFileText
    } from './processing.js';

// -- EXPORTS

export {
    buildDefText,
    getDefFilePathArray,
    getDefFolderPath,
    getDefTextHash,
    getDefTextTuid,
    getDefTextUuid,
    getDumpText,
    getNaturalTextComparison,
    haveSameValue,
    parseDefText,
    processDefQuotedString,
    readDefFile,
    readFileText
    };
