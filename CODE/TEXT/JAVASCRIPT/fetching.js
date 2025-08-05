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

export async function findMatchingFiles(
    fileFilter
    )
{
    return [ fileFilter ];
}

// ~~

export async function fetchDefFile(
    filePath,
    {
        fileFetchingFunction = fetchTextFile,
        fileFindingFunction = findMatchingFiles,
        hasImportCommands = true,
        importCommandRegularExpression = /^'@(.+\.def)'$/
    } = {}
    )
{
    let fileText = ( await fileFetchingFunction( filePath ) ).trimEnd();

    if ( hasImportCommands )
    {
        let folderPath = filePath.slice( 0, filePath.lastIndexOf( '/' ) + 1 );
        let lineArray = fileText.split( '\n' );

        for ( let lineIndex = 0;
              lineIndex < lineArray.length;
              ++lineIndex )
        {
            let line = lineArray[ lineIndex ];
            let trimmedLine = line.trim();
            let importCommandMatch = trimmedLine.match( importCommandRegularExpression );

            if ( importCommandMatch )
            {
                let importedFileFilter = importCommandMatch[ 1 ];
                let importedFilePathArray = await fileFindingFunction( importedFileFilter );

                for ( let importedFilePath of importedFilePathArray )
                {
                    let importedFileText =
                        await fetchDefFile(
                            folderPath + importedFilePath,
                            {
                                fileFetchingFunction,
                                hasImportCommands,
                                importCommandRegularExpression
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
        }

        fileText = lineArray.join( '\n' );
    }

    return fileText;
}
