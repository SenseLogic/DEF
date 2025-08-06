// -- FUNCTIONS

import 'dart:io';

// -- FUNCTIONS

Future<String> fetchTextFile(
    String filePath,
    ) async
{
    var file = File( filePath );
    var fileText = await file.readAsString();

    return fileText;
}

// ~~

Future<List<String>> getImportedFilePathArray(
    String importedFileFilter
    ) async
{
    return [ importedFileFilter ];
}

// ~~

String getImportedPath(
    String trimmedLine
    )
{
    if ( trimmedLine.startsWith( '\'@' )
         && trimmedLine.endsWith( '.def\'' ) )
    {
        return trimmedLine.substring( 2, trimmedLine.length - 1 );
    }
    else
    {
        return '';
    }
}

// ~~

Future<String> fetchDefFile(
    String filePath,
    {
        Future<String> Function( String ) fetchTextFileFunction = fetchTextFile,
        bool hasImportCommands = true,
        String Function( String ) getImportedPathFunction = getImportedPath,
        Future<List<String>> Function( String ) getImportedFilePathArrayFunction = getImportedFilePathArray
    }
    ) async
{
    var fileText = ( await fetchTextFileFunction( filePath ) ).trimRight();

    if ( hasImportCommands )
    {
        var folderPath = filePath.substring( 0, filePath.lastIndexOf( '/' ) + 1 );
        var lineArray = fileText.split( '\n' );

        for ( int lineIndex = 0;
              lineIndex < lineArray.length;
              ++lineIndex )
        {
            var line = lineArray[ lineIndex ];
            var trimmedLine = line.trim();
            var importedFilePath = getImportedPathFunction( trimmedLine );

            if ( importedFilePath.length > 0 )
            {
                var importedFilePathArray = await getImportedFilePathArrayFunction( importedFilePath );

                for ( var importedFilePath in importedFilePathArray )
                {
                    var importedFileText =
                        await fetchDefFile(
                            folderPath + importedFilePath,
                            fetchTextFileFunction: fetchTextFileFunction,
                            hasImportCommands: hasImportCommands,
                            getImportedPathFunction: getImportedPathFunction,
                            getImportedFilePathArrayFunction: getImportedFilePathArrayFunction
                            );

                    var indentation = line.substring( 0, line.length - line.trimLeft().length );
                    var indentedLineArray = importedFileText.split( '\n' );

                    for ( int indentedLineIndex = 0;
                        indentedLineIndex < indentedLineArray.length;
                        ++indentedLineIndex )
                    {
                        indentedLineArray[ indentedLineIndex ] = indentation + indentedLineArray[ indentedLineIndex ];
                    }

                    lineArray.removeAt( lineIndex );
                    lineArray.insertAll( lineIndex, indentedLineArray );
                    lineIndex += indentedLineArray.length - 1;
                }
            }
        }

        fileText = lineArray.join( '\n' );
    }

    return fileText;
}
