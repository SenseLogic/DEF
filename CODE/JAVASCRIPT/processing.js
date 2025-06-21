// -- IMPORTS

import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import md5 from 'md5';
import { parseDefText, throwParsingError } from './parsing.js';

// -- FUNCTIONS

export function getPhysicalFilePath(
    filePath
    )
{
    let scriptPath = fileURLToPath( import.meta.url );
    let folderPath = dirname( scriptPath );

    return join( folderPath, filePath );
}

// ~~

export function readFileText(
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
        throw error;
    }
}

// ~~

export function getDefStringHash(
    string
    )
{
    return md5( string );
}

// ~~

export function getDefStringUuid(
    string
    )
{
    if ( string === '' )
    {
        return '';
    }
    else
    {
        let md5_hash = md5( string );

        return (
            md5_hash.slice( 0, 8 )
            + '-'
            + md5_hash.slice( 8, 12 )
            + '-'
            + md5_hash.slice( 12, 16 )
            + '-'
            + md5_hash.slice( 16, 20 )
            + '-'
            + md5_hash.slice( 20, 32 )
            );
    }
}

// ~~

export function getDefStringTuid(
    string
    )
{
    if ( string === '' )
    {
        return '';
    }
    else
    {
        let md5_hash = md5( string );

        return (
            Buffer
                .from( md5_hash, 'hex' )
                .toString( 'base64' )
                .replaceAll( '+', '-' )
                .replaceAll( '/', '_' )
                .replaceAll( '=', '' )
            );
    }
}

// ~~

export function getDefFolderPath(
    filePath
    )
{
    return filePath.slice( 0, filePath.lastIndexOf( '/' ) + 1 );
}

// ~~

export function getDefFilePathArray(
    folderPath
    )
{
    let filePathArray = [];

    for ( let filePath of readdirSync( folderPath ) )
    {
        filePathArray.push( folderPath + filePath.replaceAll( '\\', '/' ) )
    }

    return filePathArray;
}

// ~~

function readDefFiles(
    pathArray,
    context
    )
{
    let folderPath = getDefFolderPath( context.filePath );
    let valueArray = [];

    for ( let path of pathArray )
    {
        if ( path.endsWith( '/' ) )
        {
            let filePathArray = getDefFilePathArray( folderPath + path );

            for ( let filePath of filePathArray )
            {
                if ( filePath.endsWith( '.def' ) )
                {
                    valueArray.push(
                        readDefFile(
                            filePath,
                            context.processDefQuotedStringFunction,
                            context.levelSpaceCount
                            )
                        );
                }
            }
        }
        else
        {
            let value =
                readDefFile(
                    folderPath + path,
                    context.processDefQuotedStringFunction,
                    context.levelSpaceCount
                    );

            if ( pathArray.length === 1 )
            {
                return value;
            }
            else
            {
                valueArray.push( value );
            }
        }
    }

    return valueArray;
}

// ~~

export function processDefQuotedString(
    string,
    context,
    level
    )
{
    if ( string.startsWith( '#' ) )
    {
        return getDefStringUuid( string.slice( 1 ) );
    }
    else if ( string.startsWith( '%' ) )
    {
        return getDefStringTuid( string.slice( 1 ) );
    }
    else if ( string.startsWith( '@' ) )
    {
        return readDefFiles( string.slice( 1 ).split( '\n@' ), context );
    }

    return string;
}

// ~~

export function readDefFile(
    filePath,
    processDefQuotedStringFunction = processDefQuotedString,
    levelSpaceCount = 4
    )
{
    let text = readFileText( filePath );

    return (
        parseDefText(
            text,
            {
                filePath,
                processDefQuotedStringFunction,
                levelSpaceCount
            }
            )
        );
}
