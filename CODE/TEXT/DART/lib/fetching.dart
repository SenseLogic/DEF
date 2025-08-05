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

Future<List<String>> findMatchingFiles(
    String fileFilter
    ) async
{
    return [ fileFilter ];
}

// ~~

Future<String> fetchDefFile(
    String filePath,
    {
        Future<String> Function( String ) fileFetchingFunction = fetchTextFile,
        Future<List<String>> Function( String ) fileFindingFunction = findMatchingFiles,
        bool hasImportCommands = true,
        RegExp? importCommandRegularExpression
    }
    ) async
{
    var fileText = ( await fileFetchingFunction( filePath ) ).trimRight();

    if ( hasImportCommands )
    {
        if ( importCommandRegularExpression == null )
        {
            importCommandRegularExpression = RegExp( r"^'@(.+\.def)'$" );
        }

        var folderPath = filePath.substring( 0, filePath.lastIndexOf( '/' ) + 1 );
        var lineArray = fileText.split( '\n' );

        for ( int lineIndex = 0;
              lineIndex < lineArray.length;
              ++lineIndex )
        {
            var line = lineArray[ lineIndex ];
            var trimmedLine = line.trim();
            var importCommandMatch = importCommandRegularExpression.firstMatch( trimmedLine );

            if ( importCommandMatch != null )
            {
                var importedFileFilter = importCommandMatch.group( 1 )!;
                var importedFilePathArray = await fileFindingFunction( importedFileFilter );

                for ( var importedFilePath in importedFilePathArray )
                {
                    var importedFileText =
                        await fetchDefFile(
                            folderPath + importedFilePath,
                            fileFetchingFunction: fileFetchingFunction,
                            hasImportCommands: hasImportCommands,
                            importCommandRegularExpression: importCommandRegularExpression
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
