// -- IMPORTS

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'parsing.dart';

// -- FUNCTIONS

int getNaturalTextComparison(
    String firstText,
    String secondText
    )
{
    var firstCharacterCount = firstText.length;
    var secondCharacterCount = secondText.length;
    var firstCharacterIndex = 0;
    var secondCharacterIndex = 0;

    while ( firstCharacterIndex < firstCharacterCount
            && secondCharacterIndex < secondCharacterCount )
    {
        var firstCharacter = firstText[ firstCharacterIndex ];
        var secondCharacter = secondText[ secondCharacterIndex ];

        if ( firstCharacter == secondCharacter )
        {
            ++firstCharacterIndex;
            ++secondCharacterIndex;
        }
        else
        {
            var firstCodeUnit = firstCharacter.codeUnitAt( 0 );
            var secondCodeUnit = secondCharacter.codeUnitAt( 0 );

            if ( firstCodeUnit >= 48
                 && firstCodeUnit <= 57
                 && secondCodeUnit >= 48
                 && secondCodeUnit <= 57 )
            {
                var firstNumberText = '';
                var secondNumberText = '';

                while ( firstCharacterIndex < firstCharacterCount
                        && firstText[ firstCharacterIndex ].codeUnitAt( 0 ) >= 48
                        && firstText[ firstCharacterIndex ].codeUnitAt( 0 ) <= 57 )
                {
                    firstNumberText += firstText[ firstCharacterIndex ];

                    ++firstCharacterIndex;
                }

                while ( secondCharacterIndex < secondCharacterCount
                        && secondText[ secondCharacterIndex ].codeUnitAt( 0 ) >= 48
                        && secondText[ secondCharacterIndex ].codeUnitAt( 0 ) <= 57 )
                {
                    secondNumberText += secondText[ secondCharacterIndex ];

                    ++secondCharacterIndex;
                }

                return int.parse( firstNumberText ) - int.parse( secondNumberText );
            }
            else
            {
                return firstCharacter.compareTo( secondCharacter );
            }
        }
    }

    return firstCharacterCount - secondCharacterCount;
}

// ~~

String getPhysicalFilePath(
    String filePath,
    [
        String baseFolderPath = ''
    ]
    )
{
    return path.join( baseFolderPath, filePath );
}

// ~~

String readFileText(
    String filePath,
    [
        String baseFolderPath = ''
    ]
    )
{
    try
    {
        return File( getPhysicalFilePath( filePath, baseFolderPath ) ).readAsStringSync();
    }
    catch ( error )
    {
        print( error );
        rethrow;
    }
}

// ~~

String getDefTextHash(
    String text
    )
{
    return md5.convert( utf8.encode( text ) ).toString();
}

// ~~

String getDefTextUuid(
    String text
    )
{
    if ( text == '' )
    {
        return '';
    }
    else
    {
        var md5_hash = md5.convert( utf8.encode( text ) ).toString();

        return (
            md5_hash.substring( 0, 8 )
            + '-'
            + md5_hash.substring( 8, 12 )
            + '-'
            + md5_hash.substring( 12, 16 )
            + '-'
            + md5_hash.substring( 16, 20 )
            + '-'
            + md5_hash.substring( 20, 32 )
            );
    }
}

// ~~

String getDefTextTuid(
    String text
    )
{
    if ( text == '' )
    {
        return '';
    }
    else
    {
        var md5_hash = md5.convert( utf8.encode( text ) ).bytes;

        return (
            base64Url.encode( md5_hash )
                .replaceAll( '+', '-' )
                .replaceAll( '/', '_' )
                .replaceAll( '=', '' )
            );
    }
}

// ~~

String getDefFolderPath(
    String filePath
    )
{
    return filePath.substring( 0, filePath.lastIndexOf( '/' ) + 1 );
}

// ~~

List<String> getDefFilePathArray(
    String fileFilter
    )
{
    fileFilter = fileFilter;
    var folderPath = getDefFolderPath( fileFilter );
    fileFilter = fileFilter.substring( folderPath.length );

    if ( fileFilter == '' )
    {
        fileFilter = "^.*\\.def\$";
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
                  .replaceAll( '\$', '\\\$' )
                  .replaceAll( '+', '\\+' )
                  .replaceAll( '-', '\\-' )
            + '\$';
    }

    var fileNameRegularExpression = RegExp( fileFilter );
    var filePathArray = <String>[];

    try
    {
        for ( FileSystemEntity entity in Directory( getPhysicalFilePath( folderPath ) ).listSync() )
        {
            var fileName = path.basename( entity.path );

            if ( fileNameRegularExpression.hasMatch( fileName ) )
            {
                filePathArray.add( folderPath + fileName.replaceAll( '\\', '/' ) );
            }
        }
    }
    catch ( error )
    {
        print( error );
        rethrow;
    }

    filePathArray.sort(
        ( firstFilePath, secondFilePath ) => getNaturalTextComparison( firstFilePath, secondFilePath )
        );

    return filePathArray;
}

// ~~

dynamic readDefFiles(
    List<String> pathArray,
    {
        String baseFolderPath = '',
        String filePath = '',
        String Function( String, [String] )? fileReadingFunction = readFileText,
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? stringProcessingFunction = processDefQuotedString,
        int levelSpaceCount = 4
    }
    )
{
    var scriptFolderPath = getDefFolderPath( filePath );
    var valueArray = <dynamic>[];

    for ( var path in pathArray )
    {
        if ( path.endsWith( '/' )
             || path.contains( '*' )
             || path.contains( '?' ) )
        {
            var folderFilePathArray = getDefFilePathArray( scriptFolderPath + path );

            for ( var folderFilePath in folderFilePathArray )
            {
                valueArray.add(
                    readDefFile(
                        folderFilePath,
                        baseFolderPath: baseFolderPath,
                        fileReadingFunction: fileReadingFunction,
                        stringProcessingQuote: stringProcessingQuote,
                        stringProcessingFunction: stringProcessingFunction,
                        levelSpaceCount: levelSpaceCount
                        )
                    );
            }
        }
        else
        {
            dynamic value =
                readDefFile(
                    scriptFolderPath + path,
                    baseFolderPath: baseFolderPath,
                    fileReadingFunction: fileReadingFunction,
                    stringProcessingQuote: stringProcessingQuote,
                    stringProcessingFunction: stringProcessingFunction,
                    levelSpaceCount: levelSpaceCount
                    );

            if ( pathArray.length == 1 )
            {
                return value;
            }
            else
            {
                valueArray.add( value );
            }
        }
    }

    return valueArray;
}

// ~~

dynamic processDefQuotedString(
    String string,
    ParsingContext context,
    int level
    )
{
    if ( string.startsWith( '#' ) )
    {
        return getDefTextUuid( string.substring( 1 ) );
    }
    else if ( string.startsWith( '%' ) )
    {
        return getDefTextTuid( string.substring( 1 ) );
    }
    else if ( string.startsWith( '@' ) )
    {
        return (
            readDefFiles(
                string.substring( 1 ).split( '\n@' ),
                baseFolderPath: context.baseFolderPath,
                filePath: context.filePath,
                fileReadingFunction: context.fileReadingFunction,
                stringProcessingQuote: context.stringProcessingQuote,
                stringProcessingFunction: context.stringProcessingFunction,
                levelSpaceCount: context.levelSpaceCount
                )
            );
    }

    return string;
}

// ~~

dynamic readDefFile(
    String filePath,
    {
        String baseFolderPath = '',
        String Function( String, [String] )? fileReadingFunction = readFileText,
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? stringProcessingFunction = processDefQuotedString,
        int levelSpaceCount = 4
    }
    )
{
    var text = readFileText( filePath );

    return (
        parseDefText(
            text,
            baseFolderPath: baseFolderPath,
            filePath: filePath,
            fileReadingFunction: fileReadingFunction,
            stringProcessingQuote: stringProcessingQuote,
            stringProcessingFunction: stringProcessingFunction,
            levelSpaceCount: levelSpaceCount
            )
        );
}
