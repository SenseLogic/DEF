// -- IMPORTS

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, basename, extname } from 'node:path';
import md5 from 'md5';
import { parseDefText, throwParsingError } from './parsing.js';

// -- FUNCTIONS

export function getNaturalTextComparison(
    firstText,
    secondText
    )
{
    let firstCharacterCount = firstText.length;
    let secondCharacterCount = secondText.length;
    let firstCharacterIndex = 0;
    let secondCharacterIndex = 0;

    while ( firstCharacterIndex < firstCharacterCount
            && secondCharacterIndex < secondCharacterCount )
    {
        let firstCharacter = firstText[ firstCharacterIndex ];
        let secondCharacter = secondText[ secondCharacterIndex ];

        if ( firstCharacter === secondCharacter )
        {
            ++firstCharacterIndex;
            ++secondCharacterIndex;
        }
        else
        {
            if ( firstCharacter >= '0'
                 && firstCharacter <= '9'
                 && secondCharacter >= '0'
                 && secondCharacter <= '9' )
            {
                let firstNumberText = '';
                let secondNumberText = '';

                while ( firstCharacterIndex < firstCharacterCount
                        && firstText[ firstCharacterIndex ] >= '0'
                        && firstText[ firstCharacterIndex ] <= '9' )
                {
                    firstNumberText += firstText[ firstCharacterIndex ];

                    ++firstCharacterIndex;
                }

                while ( secondCharacterIndex < secondCharacterCount
                        && secondText[ secondCharacterIndex ] >= '0'
                        && secondText[ secondCharacterIndex ] <= '9' )
                {
                    secondNumberText += secondText[ secondCharacterIndex ];

                    ++secondCharacterIndex;
                }

                return parseInt( firstNumberText ) - parseInt( secondNumberText );
            }
            else if ( firstCharacter < secondCharacter )
            {
                return -1;
            }
            else
            {
                return 1;
            }
        }
    }

    return firstCharacterCount - secondCharacterCount;
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

export function readFileText(
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

export function getDefTextHash(
    text
    )
{
    return md5( text );
}

// ~~

export function getDefTextUuid(
    text
    )
{
    if ( text === '' )
    {
        return '';
    }
    else
    {
        let md5_hash = md5( text );

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

export function getDefTextTuid(
    text
    )
{
    if ( text === '' )
    {
        return '';
    }
    else
    {
        let md5_hash = md5( text );

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
        fileReadingFunction = readFileText,
        stringProcessingQuote = '\'',
        stringProcessingFunction = processDefQuotedString,
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
                            fileReadingFunction,
                            stringProcessingQuote,
                            stringProcessingFunction,
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
                        fileReadingFunction,
                        stringProcessingQuote,
                        stringProcessingFunction,
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

export function processDefQuotedString(
    string,
    context,
    level
    )
{
    if ( string.startsWith( '#' ) )
    {
        return getDefTextUuid( string.slice( 1 ) );
    }
    else if ( string.startsWith( '%' ) )
    {
        return getDefTextTuid( string.slice( 1 ) );
    }
    else if ( string.startsWith( '@' ) )
    {
        return (
            readDefFiles(
                string.slice( 1 ).split( '\n@' ),
                {
                    baseFolderPath: context.baseFolderPath,
                    filePath: context.filePath,
                    fileReadingFunction: context.fileReadingFunction,
                    stringProcessingQuote: context.stringProcessingQuote,
                    stringProcessingFunction: context.stringProcessingFunction,
                    levelSpaceCount: context.levelSpaceCount
                }
                )
            );
    }

    return string;
}

// ~~

export function readDefFile(
    filePath,
    {
        baseFolderPath = '',
        fileReadingFunction = readFileText,
        stringProcessingQuote = '\'',
        stringProcessingFunction = processDefQuotedString,
        levelSpaceCount = 4
    } = {}
    )
{
    let text = fileReadingFunction( filePath, baseFolderPath );

    return (
        parseDefText(
            text,
            {
                baseFolderPath,
                filePath,
                fileReadingFunction,
                stringProcessingQuote,
                stringProcessingFunction,
                levelSpaceCount
            }
            )
        );
}
