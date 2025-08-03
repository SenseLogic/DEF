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
        bool fileIsTrimmed = true,
        bool fileHasImports = false,
        String importPrefix = '\'@',
        String importSuffix = '\''
    }
    ) async
{
    var fileText = await fileFetchingFunction( filePath );

    if ( fileIsTrimmed )
    {
        fileText = fileText.trimRight();
    }

    if ( fileHasImports
         && ( importPrefix != ''
              || importSuffix != '' ) )
    {
        var folderPath = filePath.substring( 0, filePath.lastIndexOf( '/' ) + 1 );
        var lineArray = fileText.split( '\n' );

        for ( int lineIndex = 0;
              lineIndex < lineArray.length;
              ++lineIndex )
        {
            var line = lineArray[ lineIndex ];
            var trimmedLine = line.trim();

            if ( trimmedLine.length > importPrefix.length + importSuffix.length
                 && trimmedLine.startsWith( importPrefix )
                 && trimmedLine.endsWith( importSuffix ) )
            {
                var importedFileFilter = trimmedLine.substring( importPrefix.length, trimmedLine.length - importSuffix.length );
                var importedFilePathArray = await fileFindingFunction( importedFileFilter );

                for ( var importedFilePath in importedFilePathArray )
                {
                    var importedFileText =
                        await fetchDefFile(
                            folderPath + importedFilePath,
                            fileFetchingFunction: fileFetchingFunction,
                            fileHasImports: fileHasImports,
                            importPrefix: importPrefix,
                            importSuffix: importSuffix
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
