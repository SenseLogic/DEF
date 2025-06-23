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
    String filePath
    )
{
    var scriptPath = Platform.script.toFilePath();
    var folderPath = path.dirname( scriptPath );

    return path.join( folderPath, filePath );
}

// ~~

String readFileText(
    String filePath
    )
{
    try
    {
        return File( getPhysicalFilePath( filePath ) ).readAsStringSync();
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
    String folderPath
    )
{
    var filePathArray = <String>[];

    for ( FileSystemEntity entity in Directory( getPhysicalFilePath( folderPath ) ).listSync() )
    {
        filePathArray.add( path.join( folderPath, entity.path.replaceAll( '\\', '/' ) ) );
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
        String scriptFilePath = '',
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? stringProcessingFunction = processDefQuotedString,
        int levelSpaceCount = 4
    }
    )
{
    var scriptFolderPath = getDefFolderPath( scriptFilePath );
    var valueArray = <dynamic>[];

    for ( var path in pathArray )
    {
        if ( path.endsWith( '/' ) )
        {
            var filePathArray = getDefFilePathArray( scriptFolderPath + path );

            for ( var filePath in filePathArray )
            {
                if ( filePath.endsWith( '.def' ) )
                {
                    valueArray.add(
                        readDefFile(
                            filePath,
                            stringProcessingQuote: stringProcessingQuote,
                            stringProcessingFunction: stringProcessingFunction,
                            levelSpaceCount: levelSpaceCount
                            )
                        );
                }
            }
        }
        else
        {
            dynamic value =
                readDefFile(
                    scriptFolderPath + path,
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
                scriptFilePath: context.filePath,
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
            filePath: filePath,
            stringProcessingQuote: stringProcessingQuote,
            stringProcessingFunction: stringProcessingFunction,
            levelSpaceCount: levelSpaceCount
            )
        );
}
