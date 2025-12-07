// -- IMPORTS

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, basename, extname } from 'node:path';
import {
    getNaturalTextComparison,
    parseDefText,
    processDefQuotedString
    } from 'senselogic-def';

// -- FUNCTIONS

export function getImportedPath(
    trimmedLine
    )
{
    if ( trimmedLine.startsWith( '\'@' )
         && trimmedLine.endsWith( '\'' ) )
    {
        return trimmedLine.slice( 2, -1 );
    }
    else
    {
        return '';
    }
}

// ~~

export function getImportedFilePathArray(
    importedFileFilter
    )
{
    return getDefFilePathArray( importedFileFilter );
}

// ~~

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

export function processDefFileText(
    fileText,
    {
        baseFolderPath = '',
        filePath = '',
        readTextFileFunction = readTextFile,
        hasImportCommands = true,
        getImportedPathFunction = getImportedPath,
        getImportedFilePathArrayFunction = getImportedFilePathArray
    } = {}
    )
{
    if ( hasImportCommands )
    {
        let folderPath = filePath.slice( 0, filePath.lastIndexOf( '/' ) + 1 );
        let lineArray = fileText.split( '\n' );

        for ( let lineIndex = 0;
              lineIndex < lineArray.length;
              ++lineIndex )
        {
            let line = lineArray[ lineIndex ];
            let trimmedLine = line.trim();
            let importedFileFilter = getImportedPathFunction( trimmedLine );

            if ( importedFileFilter.length > 0 )
            {
                lineArray.splice( lineIndex, 1 );
                let importedFilePathArray = getImportedFilePathArrayFunction( folderPath + importedFileFilter );

                for ( let importedFilePath of importedFilePathArray )
                {
                    let importedFileText =
                        readDefFileText(
                            importedFilePath,
                            {
                                baseFolderPath,
                                readTextFileFunction,
                                hasImportCommands,
                                getImportedPathFunction,
                                getImportedFilePathArrayFunction
                            }
                            );

                    let indentation = line.slice( 0, line.length - line.trimStart().length );
                    let indentedLineArray = importedFileText.split( '\n' );

                    for ( let indentedLineIndex = 0;
                          indentedLineIndex < indentedLineArray.length;
                          ++indentedLineIndex )
                    {
                        indentedLineArray[ indentedLineIndex ] = indentation + indentedLineArray[ indentedLineIndex ];
                    }

                    lineArray.splice( lineIndex, 0, ...indentedLineArray );
                    lineIndex += indentedLineArray.length;
                }

                --lineIndex;
            }
        }

        fileText = lineArray.join( '\n' );
    }

    return fileText;
}

// ~~

export function parseDefFileText(
    fileText,
    {
        baseFolderPath = '',
        filePath = '',
        readTextFileFunction = readTextFile,
        hasImportCommands = true,
        stringProcessingQuote = '\'',
        processQuotedStringFunction = processDefQuotedString,
        levelSpaceCount = 4,
        getImportedPathFunction = getImportedPath,
        getImportedFilePathArrayFunction = getImportedFilePathArray
    } = {}
    )
{
    if ( hasImportCommands )
    {
        fileText =
            processDefFileText(
                fileText,
                {
                    baseFolderPath,
                    filePath,
                    readTextFileFunction,
                    hasImportCommands,
                    getImportedPathFunction,
                    getImportedFilePathArrayFunction
                }
                );
    }

    return (
        parseDefText(
            fileText,
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

export function readDefFileText(
    filePath,
    {
        baseFolderPath = '',
        readTextFileFunction = readTextFile,
        hasImportCommands = true,
        getImportedPathFunction = getImportedPath,
        getImportedFilePathArrayFunction = getImportedFilePathArray
    } = {}
    )
{
    let fileText = readTextFileFunction( filePath, baseFolderPath ).trimEnd();

    if ( hasImportCommands )
    {
        fileText =
            processDefFileText(
                fileText,
                {
                    baseFolderPath,
                    filePath,
                    readTextFileFunction,
                    hasImportCommands,
                    getImportedPathFunction,
                    getImportedFilePathArrayFunction
                }
                );
    }

    return fileText;
}

// ~~

export function readDefFile(
    filePath,
    {
        baseFolderPath = '',
        readTextFileFunction = readTextFile,
        stringProcessingQuote = '\'',
        processQuotedStringFunction = processDefQuotedString,
        levelSpaceCount = 4,
        hasImportCommands = true,
        getImportedPathFunction = getImportedPath,
        getImportedFilePathArrayFunction = getImportedFilePathArray
    } = {}
    )
{
    let text = readDefFileText(
        filePath,
        {
            baseFolderPath,
            readTextFileFunction,
            hasImportCommands,
            getImportedPathFunction,
            getImportedFilePathArrayFunction
        }
        );

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

export function readDefFiles(
    pathArray,
    {
        baseFolderPath = '',
        filePath = '',
        readTextFileFunction = readTextFile,
        stringProcessingQuote = '\'',
        processQuotedStringFunction = processDefQuotedString,
        levelSpaceCount = 4,
        hasImportCommands = true,
        getImportedPathFunction = getImportedPath,
        getImportedFilePathArrayFunction = getImportedFilePathArray
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
                            levelSpaceCount,
                            hasImportCommands,
                            getImportedPathFunction,
                            getImportedFilePathArrayFunction
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
                        levelSpaceCount,
                        hasImportCommands,
                        getImportedPathFunction,
                        getImportedFilePathArrayFunction
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
