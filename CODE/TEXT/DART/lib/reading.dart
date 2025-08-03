// -- FUNCTIONS

import 'dart:io';

// -- FUNCTIONS

Future<String> readTextFile(
    String filePath,
    ) async
{
    var file = File( filePath );
    var fileText = await file.readAsString();

    return fileText;
}

// ~~

Future<String> readDefFile(
    String filePath,
    {
        Future<String> Function( String ) fileReadingFunction = readTextFile,
        bool fileIsTrimmed = true,
        bool fileHasImports = false,
        String importPrefix = '@\'',
        String importSuffix = '\''
    }
    ) async
{
    var fileText = await fileReadingFunction( filePath );

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
                var importedFilePath = trimmedLine.substring( importPrefix.length, trimmedLine.length - importSuffix.length );
                var importedFileText = 
                    await readDefFile( 
                        folderPath + importedFilePath, 
                        fileReadingFunction: fileReadingFunction,
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

        fileText = lineArray.join( '\n' );
    }

    return fileText;
}
