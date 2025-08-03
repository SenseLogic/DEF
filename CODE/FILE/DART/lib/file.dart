// -- IMPORTS

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:senselogic_def/senselogic_def.dart';

// -- FUNCTIONS

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

String readTextFile(
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
        String Function( String, [String] )? fileReadingFunction = readTextFile,
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? stringProcessingFunction = processDefFileQuotedString,
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

dynamic readDefFile(
    String filePath,
    {
        String baseFolderPath = '',
        String Function( String, [String] )? fileReadingFunction = readTextFile,
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? stringProcessingFunction = processDefFileQuotedString,
        int levelSpaceCount = 4
    }
    )
{
    var text = readTextFile( filePath );

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

// ~~

dynamic processDefFileQuotedString(
    String string,
    ParsingContext context,
    int level
    )
{
    if ( string.startsWith( '@' ) )
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
    else
    {
        return processDefQuotedString( string, context, level );
    }
}

// ~~

dynamic parseDefFileText(
    String text,
    {
        String baseFolderPath = '',
        String filePath = '',
        String Function( String, [String] )? fileReadingFunction = readTextFile,
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? stringProcessingFunction = processDefFileQuotedString,
        int levelSpaceCount = 4
    }
    )
{
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
