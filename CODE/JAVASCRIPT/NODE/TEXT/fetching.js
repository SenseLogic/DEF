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

export async function getImportedFilePathArray(
    importedFileFilter
    )
{
    return [ importedFileFilter ];
}

// ~~

export function getImportedPath(
    trimmedLine
    )
{
    if ( trimmedLine.startsWith( '\'@' )
         && trimmedLine.endsWith( '.def\'' ) )
    {
        return trimmedLine.slice( 2, -1 );
    }
    else
    {
        return '';
    }
}

// ~~

export async function fetchDefFile(
    filePath,
    {
        fetchTextFileFunction = fetchTextFile,
        hasImportCommands = true,
        getImportedPathFunction = getImportedPath,
        getImportedFilePathArrayFunction = getImportedFilePathArray
    } = {}
    )
{
    let fileText = ( await fetchTextFileFunction( filePath ) ).trimEnd();

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
            let importedFileFilter = getImportedPathFunction( trimmedLine );

            if ( importedFileFilter.length > 0 )
            {
                let importedFilePathArray = await getImportedFilePathArrayFunction( importedFileFilter );

                for ( let importedFilePath of importedFilePathArray )
                {
                    let importedFileText =
                        await fetchDefFile(
                            folderPath + importedFilePath,
                            {
                                fetchTextFileFunction,
                                hasImportCommands,
                                getImportedPathFunction,
                                getImportedFilePathArrayFunction
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
