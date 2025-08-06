// -- IMPORTS

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, basename, extname } from 'node:path';
import {
    getNaturalTextComparison,
    parseDefText,
    processDefQuotedString
    } from 'senselogic-def';

// -- FUNCTIONS

export function getPhysicalFilePath(
    filePath,
    baseFolderPath = ''
    )
{
    return join( baseFolderPath, filePath );
}

// ~~

export function readTextFile(
    filePath,
    baseFolderPath = ''
    )
{
    try
    {
        return readFileSync( getPhysicalFilePath( filePath, baseFolderPath ), 'utf8' );
    }
    catch ( error )
    {
        console.error( error );
        throw error;
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
    fileFilter
    )
{
    fileFilter = fileFilter;
    let folderPath = getDefFolderPath( fileFilter );
    fileFilter = fileFilter.slice( folderPath.length );

    if ( fileFilter === '' )
    {
        fileFilter = "^.*\\.def$";
    }
    else
    {
        fileFilter =
            '^'
            + fileFilter
                  .replaceAll( '.', '\\.' )
                  .replaceAll( '*', '.*' )
                  .replaceAll( '?', '.' )
                  .replaceAll( '[', '\\[' )
                  .replaceAll( ']', '\\]' )
                  .replaceAll( '(', '\\(' )
                  .replaceAll( ')', '\\)' )
                  .replaceAll( '{', '\\{' )
                  .replaceAll( '}', '\\}' )
                  .replaceAll( '|', '\\|' )
                  .replaceAll( '^', '\\^' )
                  .replaceAll( '$', '\\$' )
                  .replaceAll( '+', '\\+' )
                  .replaceAll( '-', '\\-' )
            + '$';
    }

    let fileNameRegularExpression = new RegExp( fileFilter );
    let filePathArray = [];

    try
    {
        for ( let fileName of readdirSync( folderPath ) )
        {
            if ( fileNameRegularExpression.test( fileName ) )
            {
                filePathArray.push( folderPath + fileName.replaceAll( '\\', '/' ) );
            }
        }
    }
    catch ( error )
    {
        console.error( error );
        throw error;
    }

    filePathArray.sort(
        ( firstFilePath, secondFilePath ) => getNaturalTextComparison( firstFilePath, secondFilePath )
        );

    return filePathArray;
}

// ~~

export function readDefFiles(
    pathArray,
    {
        baseFolderPath = '',
        filePath = '',
        readTextFileFunction = readTextFile,
        stringProcessingQuote = '\'',
        processQuotedStringFunction = processDefFileQuotedString,
        levelSpaceCount = 4
    } = {}
    )
{
    let scriptFolderPath = getDefFolderPath( filePath );
    let valueArray = [];

    for ( let path of pathArray )
    {
        if ( path.endsWith( '/' )
             || path.includes( '*' )
             || path.includes( '?' ) )
        {
            let folderFilePathArray = getDefFilePathArray( scriptFolderPath + path );

            for ( let folderFilePath of folderFilePathArray )
            {
                valueArray.push(
                    readDefFile(
                        folderFilePath,
                        {
                            baseFolderPath,
                            readTextFileFunction,
                            stringProcessingQuote,
                            processQuotedStringFunction,
                            levelSpaceCount
                        }
                        )
                    );
            }
        }
        else
        {
            let value =
                readDefFile(
                    scriptFolderPath + path,
                    {
                        baseFolderPath,
                        readTextFileFunction,
                        stringProcessingQuote,
                        processQuotedStringFunction,
                        levelSpaceCount
                    }
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

export function readDefFile(
    filePath,
    {
        baseFolderPath = '',
        readTextFileFunction = readTextFile,
        stringProcessingQuote = '\'',
        processQuotedStringFunction = processDefFileQuotedString,
        levelSpaceCount = 4
    } = {}
    )
{
    let text = readTextFileFunction( filePath, baseFolderPath );

    return (
        parseDefText(
            text,
            {
                baseFolderPath,
                filePath,
                readTextFileFunction,
                stringProcessingQuote,
                processQuotedStringFunction,
                levelSpaceCount
            }
            )
        );
}

// ~~

export function processDefFileQuotedString(
    string,
    context,
    level
    )
{
    if ( string.startsWith( '@' ) )
    {
        return (
            readDefFiles(
                string.slice( 1 ).split( '\n@' ),
                {
                    baseFolderPath: context.baseFolderPath,
                    filePath: context.filePath,
                    readTextFileFunction: context.readTextFileFunction,
                    stringProcessingQuote: context.stringProcessingQuote,
                    processQuotedStringFunction: context.processQuotedStringFunction,
                    levelSpaceCount: context.levelSpaceCount
                }
                )
            );
    }
    else
    {
        return processDefQuotedString( string, context, level );
    }
}

// ~~

export function parseDefFileText(
    text,
    {
        baseFolderPath = '',
        filePath = '',
        readTextFileFunction = readTextFile,
        stringProcessingQuote = '\'',
        processQuotedStringFunction = processDefFileQuotedString,
        levelSpaceCount = 4
    } = {}
    )
{
    return (
        parseDefText(
            text,
            {
                baseFolderPath,
                filePath,
                readTextFileFunction,
                stringProcessingQuote,
                processQuotedStringFunction,
                levelSpaceCount
            }
            )
        );
}
