// -- IMPORTS

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'parsing.dart';

// -- FUNCTIONS

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

String getDefStringHash(
    String string
    )
{
    return md5.convert( utf8.encode( string ) ).toString();
}

// ~~

String getDefStringUuid(
    String string
    )
{
    if ( string == '' )
    {
        return '';
    }
    else
    {
        var md5_hash = md5.convert( utf8.encode( string ) ).toString();

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

String getDefStringTuid(
    String string
    )
{
    if ( string == '' )
    {
        return '';
    }
    else
    {
        var md5_hash = md5.convert( utf8.encode( string ) ).toString();

        return (
            base64Url.encode( md5.convert( utf8.encode( string ) ).bytes )
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

    return filePathArray;
}

// ~~

dynamic readDefFiles(
    List<String> pathArray,
    ParsingContext context
    )
{
    var folderPath = getDefFolderPath( context.filePath );
    var valueArray = <dynamic>[];

    for ( var path in pathArray )
    {
        if ( path.endsWith( '/' ) )
        {
            var filePathArray = getDefFilePathArray( folderPath + path );

            for ( var filePath in filePathArray )
            {
                if ( filePath.endsWith( '.def' ) )
                {
                    valueArray.add(
                        readDefFile(
                            filePath,
                            stringProcessingQuote: context.stringProcessingQuote,
                            stringProcessingFunction: context.stringProcessingFunction,
                            levelSpaceCount: context.levelSpaceCount
                            )
                        );
                }
            }
        }
        else
        {
            dynamic value =
                readDefFile(
                    folderPath + path,
                    stringProcessingQuote: context.stringProcessingQuote,
                    stringProcessingFunction: context.stringProcessingFunction,
                    levelSpaceCount: context.levelSpaceCount
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
        return getDefStringUuid( string.substring( 1 ) );
    }
    else if ( string.startsWith( '%' ) )
    {
        return getDefStringTuid( string.substring( 1 ) );
    }
    else if ( string.startsWith( '@' ) )
    {
        return readDefFiles( string.substring( 1 ).split( '\n@' ), context );
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
