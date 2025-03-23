// -- IMPORTS

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDefText, getDumpText, haveSameValue, parseDefText } from './index.js';

// -- FUNCTIONS

function getPhysicalFilePath(
    filePath
    )
{
    let fileName = fileURLToPath( import.meta.url );
    let folderName = dirname( fileName );

    return join( folderName, filePath );
}

// ~~

function readFileText(
    filePath
    )
{
    try
    {
        return readFileSync( getPhysicalFilePath( filePath ), 'utf8' );
    }
    catch ( error )
    {
        console.error( error );
        process.exit( 1 );
    }
}

// ~~

function runTests(
    )
{
    let testDataArray = readFileText( "test.txt" ).split( '\n~~~\n' );

    for ( let testDataIndex = 0;
         testDataIndex + 1 < testDataArray.length;
         testDataIndex += 2 )
    {
        let defText = testDataArray[ testDataIndex ];
        let expectedValueText = testDataArray[ testDataIndex + 1 ];

        try
        {
            console.log( "================================" );
            console.log( 'defText:' );
            console.log( defText );
            console.log( 'expectedValueText:' );
            console.log( expectedValueText );

            let expectedValue = ( new Function( `return (${expectedValueText});` ) )();
            console.log( 'expectedValue:' );
            console.log( getDumpText( expectedValue ) );

            let parsedValue = parseDefText( defText );
            console.log( 'parsedValue:' );
            console.log( getDumpText( parsedValue ) );

            if ( !haveSameValue( parsedValue, expectedValue ) )
            {
                console.error( "Invalid parsed value" );
                process.exit( 1 );
            }

            let builtText = buildDefText( expectedValue );
            console.log( 'builtText:' );
            console.log( builtText );

            let reparsedValue = parseDefText( builtText );
            console.log( 'reparsedValue:' );
            console.log( getDumpText( reparsedValue ) );

            if ( !haveSameValue( reparsedValue, expectedValue ) )
            {
                console.error( "Invalid parsed value" );
                process.exit( 1 );
            }
        }
        catch ( error )
        {
            console.error( error );
            process.exit( 1 );
        }
    }

    console.log( "All tests passed!" );
}

// -- STATEMENTS

runTests();
