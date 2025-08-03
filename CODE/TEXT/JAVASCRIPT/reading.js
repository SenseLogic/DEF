// -- FUNCTIONS

export async function fetchTextFile(
    filePath
    )
{
    let response = await fetch( filePath );
    let fileText = await response.text();

    return fileText;
}

// ~~

export async function readDefFile(
    filePath,
    {
        fileReadingFunction = fetchTextFile,
        fileIsTrimmed = true,
        fileHasImports = false,
        importPrefix = '@\'',
        importSuffix = '\''
    } = {}
    )
{
    let fileText = await fileReadingFunction( filePath );

    if ( fileIsTrimmed )
    {
        fileText = fileText.trimEnd();
    }   

    if ( fileHasImports
         && ( importPrefix !== ''
              || importSuffix !== '' ) )
    {
        let folderPath = filePath.slice( 0, filePath.lastIndexOf( '/' ) + 1 );
        let lineArray = fileText.split( '\n' );

        for ( let lineIndex = 0;
              lineIndex < lineArray.length;
              ++lineIndex )
        {
            let line = lineArray[ lineIndex ];
            let trimmedLine = line.trim();

            if ( trimmedLine.length > importPrefix.length + importSuffix.length
                 && trimmedLine.startsWith( importPrefix )
                 && trimmedLine.endsWith( importSuffix ) )
            {
                let importedFilePath = trimmedLine.slice( importPrefix.length, trimmedLine.length - importSuffix.length );
                let importedFileText = 
                    await readDefFile( 
                        folderPath + importedFilePath, 
                        {
                            fileReadingFunction,
                            fileHasImports,
                            importPrefix, 
                            importSuffix 
                        }
                        );

                let indentation = line.slice( 0, line.length - line.trimStart().length );
                let indentedLineArray = importedFileText.split( '\n' );

                for ( let indentedLineIndex = 0;
                      indentedLineIndex < indentedLineArray.length;
                      ++indentedLineIndex )
                {
                    indentedLineArray[ indentedLineIndex ] = indentation + indentedLineArray[ indentedLineIndex ];
                }

                lineArray.splice( lineIndex, 1, ...indentedLineArray );
                lineIndex += indentedLineArray.length - 1;
            }
        }

        fileText = lineArray.join( '\n' );
    }

    return fileText;
}
