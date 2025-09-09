// -- IMPORTS

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:senselogic_def/senselogic_def.dart';

// -- FUNCTIONS

String getImportedPath(
    String trimmedLine
    )
{
    if ( trimmedLine.startsWith( '\'@' )
         && trimmedLine.endsWith( '\'' ) )
    {
        return trimmedLine.substring( 2, trimmedLine.length - 1 );
    }
    else
    {
        return '';
    }
}

// ~~

List<String> getImportedFilePathArray(
    String importedFileFilter
    )
{
    return getDefFilePathArray( importedFileFilter );
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

String processDefFileText(
    String fileText,
    {
        String baseFolderPath = '',
        String filePath = '',
        String Function( String, [String] )? readTextFileFunction = readTextFile,
        bool hasImportCommands = true,
        String Function( String )? getImportedPathFunction = getImportedPath,
        List<String> Function( String )? getImportedFilePathArrayFunction = getImportedFilePathArray
    }
    )
{
    if ( hasImportCommands )
    {
        var folderPath = filePath.substring( 0, filePath.lastIndexOf( '/' ) + 1 );
        var lineArray = fileText.split( '\n' );

        for ( var lineIndex = 0;
              lineIndex < lineArray.length;
              ++lineIndex )
        {
            var line = lineArray[ lineIndex ];
            var trimmedLine = line.trim();
            var importedFileFilter = getImportedPathFunction!( trimmedLine );

            if ( importedFileFilter.isNotEmpty )
            {
                lineArray.removeAt( lineIndex );
                var importedFilePathArray = getImportedFilePathArrayFunction!( folderPath + importedFileFilter );

                for ( var importedFilePath in importedFilePathArray )
                {
                    var importedFileText =
                        readDefFileText(
                            importedFilePath,
                            baseFolderPath: baseFolderPath,
                            readTextFileFunction: readTextFileFunction,
                            hasImportCommands: hasImportCommands,
                            getImportedPathFunction: getImportedPathFunction,
                            getImportedFilePathArrayFunction: getImportedFilePathArrayFunction
                            );

                    var indentation = line.substring( 0, line.length - line.trimLeft().length );
                    var indentedLineArray = importedFileText.split( '\n' );

                    for ( var indentedLineIndex = 0;
                          indentedLineIndex < indentedLineArray.length;
                          ++indentedLineIndex )
                    {
                        indentedLineArray[ indentedLineIndex ] = indentation + indentedLineArray[ indentedLineIndex ];
                    }

                    lineArray.insertAll( lineIndex, indentedLineArray );
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

dynamic parseDefFileText(
    String fileText,
    {
        String baseFolderPath = '',
        String filePath = '',
        String Function( String, [String] )? readTextFileFunction = readTextFile,
        bool hasImportCommands = true,
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? processQuotedStringFunction = processDefQuotedString,
        int levelSpaceCount = 4,
        String Function( String )? getImportedPathFunction = getImportedPath,
        List<String> Function( String )? getImportedFilePathArrayFunction = getImportedFilePathArray
    }
    )
{
    if ( hasImportCommands )
    {
        fileText =
            processDefFileText(
                fileText,
                baseFolderPath: baseFolderPath,
                filePath: filePath,
                readTextFileFunction: readTextFileFunction,
                hasImportCommands: hasImportCommands,
                getImportedPathFunction: getImportedPathFunction,
                getImportedFilePathArrayFunction: getImportedFilePathArrayFunction
                );
    }

    return (
        parseDefText(
            fileText,
            baseFolderPath: baseFolderPath,
            filePath: filePath,
            readTextFileFunction: readTextFileFunction,
            stringProcessingQuote: stringProcessingQuote,
            processQuotedStringFunction: processQuotedStringFunction,
            levelSpaceCount: levelSpaceCount
            )
        );
}

// ~~

String readDefFileText(
    String filePath,
    {
        String baseFolderPath = '',
        String Function( String, [String] )? readTextFileFunction = readTextFile,
        bool hasImportCommands = true,
        String Function( String )? getImportedPathFunction = getImportedPath,
        List<String> Function( String )? getImportedFilePathArrayFunction = getImportedFilePathArray
    }
    )
{
    var fileText = readTextFileFunction!( filePath, baseFolderPath ).trimRight();

    if ( hasImportCommands )
    {
        fileText =
            processDefFileText(
                fileText,
                baseFolderPath: baseFolderPath,
                filePath: filePath,
                readTextFileFunction: readTextFileFunction,
                hasImportCommands: hasImportCommands,
                getImportedPathFunction: getImportedPathFunction,
                getImportedFilePathArrayFunction: getImportedFilePathArrayFunction
                );
    }

    return fileText;
}

// ~~

dynamic readDefFile(
    String filePath,
    {
        String baseFolderPath = '',
        String Function( String, [String] )? readTextFileFunction = readTextFile,
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? processQuotedStringFunction = processDefQuotedString,
        int levelSpaceCount = 4,
        bool hasImportCommands = true,
        String Function( String )? getImportedPathFunction = getImportedPath,
        List<String> Function( String )? getImportedFilePathArrayFunction = getImportedFilePathArray
    }
    )
{
    var text = readDefFileText(
        filePath,
        baseFolderPath: baseFolderPath,
        readTextFileFunction: readTextFileFunction,
        hasImportCommands: hasImportCommands,
        getImportedPathFunction: getImportedPathFunction,
        getImportedFilePathArrayFunction: getImportedFilePathArrayFunction
        );

    return (
        parseDefText(
            text,
            baseFolderPath: baseFolderPath,
            filePath: filePath,
            readTextFileFunction: readTextFileFunction,
            stringProcessingQuote: stringProcessingQuote,
            processQuotedStringFunction: processQuotedStringFunction,
            levelSpaceCount: levelSpaceCount
            )
        );
}

// ~~

dynamic readDefFiles(
    List<String> pathArray,
    {
        String baseFolderPath = '',
        String filePath = '',
        String Function( String, [String] )? readTextFileFunction = readTextFile,
        String stringProcessingQuote = '\'',
        dynamic Function( String, ParsingContext, int )? processQuotedStringFunction = processDefQuotedString,
        int levelSpaceCount = 4,
        bool hasImportCommands = true,
        String Function( String )? getImportedPathFunction = getImportedPath,
        List<String> Function( String )? getImportedFilePathArrayFunction = getImportedFilePathArray
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
                        readTextFileFunction: readTextFileFunction,
                        stringProcessingQuote: stringProcessingQuote,
                        processQuotedStringFunction: processQuotedStringFunction,
                        levelSpaceCount: levelSpaceCount,
                        hasImportCommands: hasImportCommands,
                        getImportedPathFunction: getImportedPathFunction,
                        getImportedFilePathArrayFunction: getImportedFilePathArrayFunction
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
                    readTextFileFunction: readTextFileFunction,
                    stringProcessingQuote: stringProcessingQuote,
                    processQuotedStringFunction: processQuotedStringFunction,
                    levelSpaceCount: levelSpaceCount,
                    hasImportCommands: hasImportCommands,
                    getImportedPathFunction: getImportedPathFunction,
                    getImportedFilePathArrayFunction: getImportedFilePathArrayFunction
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
