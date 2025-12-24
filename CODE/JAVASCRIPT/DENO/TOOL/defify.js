// -- IMPORTS

import { buildDefText } from 'npm:senselogic-def';
import { walk } from 'https://deno.land/std@0.208.0/fs/walk.ts';
import { join, relative, dirname } from 'https://deno.land/std@0.208.0/path/mod.ts';

// -- FUNCTIONS

async function getJsonFilePathArray(
    inputFolderPath
    )
{
    let jsonFilePathArray = [];

    for await ( let inputFolderEntry of walk( inputFolderPath, { exts: [ '.json' ] } ) )
    {
        if ( inputFolderEntry.isFile )
        {
            jsonFilePathArray.push( inputFolderEntry.path );
        }
    }

    return jsonFilePathArray;
}

// ~~

async function processJsonFile(
    jsonFilePath,
    inputFolderPath,
    outputFolderPath
    )
{
    try
    {
        console.log( `Reading file : ${ jsonFilePath }` );
        let jsonText = await Deno.readTextFile( jsonFilePath );
        let jsonValue = JSON.parse( jsonText );
        let defText = buildDefText( jsonValue );

        let relativeJsonFilePath = relative( inputFolderPath, jsonFilePath );
        let defFilePath = join( outputFolderPath, relativeJsonFilePath.replace( /\.json$/, '.def' ) );
        let defFolderPath = dirname( defFilePath );

        await Deno.mkdir( defFolderPath, { recursive: true } );
        await Deno.writeTextFile( defFilePath, defText );

        console.log( `Writing file : ${ defFilePath }` );
    }
    catch ( error )
    {
        console.error( `Error processing file : ${ jsonFilePath }` );
        console.error( error.message );
    }
}

// ~~

async function main(
    )
{
    let args = Deno.args;

    if ( args.length !== 2
         || !args[ 0 ].endsWith( '/' )
         || !args[ 1 ].endsWith( '/' ) )
    {
        console.error( 'Error : Invalid arguments' );
        console.error( 'Usage : deno defify.js IN/ OUT/' );
        Deno.exit( 1 );
    }
    else
    {
        let inputFolderPath = args[ 0 ];
        let outputFolderPath = args[ 1 ];

        let jsonFilePathArray = await getJsonFilePathArray( inputFolderPath );

        for ( let jsonFilePath of jsonFilePathArray )
        {
            await processJsonFile( jsonFilePath, inputFolderPath, outputFolderPath );
        }

        console.log( 'Done.' );
    }
}

// -- STATEMENTS

if ( import.meta.main )
{
    await main();
}

