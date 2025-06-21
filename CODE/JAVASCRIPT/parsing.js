// -- CONSTANTS

var
    decimalRealExpression = /^-?\d+(\.\d+)?$/,
    exponentialDecimalRealExpression = /^-?\d+(\.\d+)?[eE][-+]?\d+$/,
    hexadecimalIntegerExpression = /^0x[0-9A-Fa-f]+$/;

// -- FUNCTIONS

function getTokenArray(
    text
    )
{
    let tokenArray = [];
    let characterIndex = 0;

    while ( characterIndex < text.length )
    {
        if ( text[ characterIndex ] === '\\' )
        {
            if ( characterIndex + 1 < text.length )
            {
                tokenArray.push( text[ characterIndex ] + text[ characterIndex + 1 ] );
                characterIndex += 2;
            }
            else
            {
                tokenArray.push( text[ characterIndex ] );
                ++characterIndex;
            }
        }
        else
        {
            let postCharacterIndex = characterIndex;

            while ( postCharacterIndex < text.length
                    && text[ postCharacterIndex ] !== '\\' )
            {
                ++postCharacterIndex;
            }

            tokenArray.push( text.substring( characterIndex, postCharacterIndex ) );
            characterIndex = postCharacterIndex;
        }
    }

    return tokenArray;
}

// ~~

function getUnescapedText(
    tokenArray
    )
{
    let unescapedText = '';

    for ( let token of tokenArray )
    {
        if ( token.length === 2
             && token[ 0 ] === '\\' )
        {
            switch ( token[ 1 ] )
            {
                case 'n':
                    {
                        unescapedText += '\n';
                        break;
                    }

                case 't':
                    {
                        unescapedText += '\t';
                        break;
                    }

                case 'r':
                    {
                        unescapedText += '\r';
                        break;
                    }

                case 'b':
                    {
                        unescapedText += '\b';
                        break;
                    }

                case 'f':
                    {
                        unescapedText += '\f';
                        break;
                    }

                case '0':
                    {
                        unescapedText += '\0';
                        break;
                    }

                default:
                    {
                        unescapedText += token[ 1 ];
                    }
            }
        }
        else
        {
            unescapedText += token;
        }
    }

    return unescapedText;
}

// ~~

export function throwParsingError(
    message,
    context,
    level
    )
{
    message =
        message
        + '\nText :\n'
        + context.text
        + '\nFile : ' + context.filePath
        + '\nLine ' + context.lineIndex + ' @ ' + level;

    if ( context.lineIndex > 0
         && context.lineIndex <= context.lineArray.length )
    {
        message += ' : ' + context.lineArray[ context.lineIndex - 1 ];
    }

    throw new Error( message );
}

// ~~

function parseDefLine(
    context,
    level
    )
{
    let line = context.lineArray[ context.lineIndex ];
    let trimmedLine = line.trimStart();
    let levelSpaceCount = level * context.levelSpaceCount;
    let lineSpaceCount = line.length - trimmedLine.length;

    if ( trimmedLine === '' )
    {
        line = '';
        lineSpaceCount = 0;
    }
    else
    {
        if ( lineSpaceCount < levelSpaceCount )
        {
            throwParsingError( 'Invalid DEF line', context, level );
        }

        line = line.slice( levelSpaceCount ).trimEnd();
        lineSpaceCount -= levelSpaceCount;
    }

    context.lineIndex++;

    return { line, lineSpaceCount };
}

// ~~

function parseDefUnquotedString(
    context,
    level
    )
{
    let string = '';

    while ( context.lineIndex < context.lineArray.length )
    {
        let { line, lineSpaceCount } =
            parseDefLine( context, level );

        let tokenArray = getTokenArray( line );
        let lastToken = ( tokenArray.length > 0 ) ? tokenArray[ tokenArray.length - 1 ] : '';

        if ( lastToken === '\\' )
        {
            tokenArray.pop();

            string += getUnescapedText( tokenArray );
        }
        else
        {
            if ( line.endsWith( '¨' )
                 && lastToken !== '\\¨' )
            {
                tokenArray[ tokenArray.length - 1 ] = lastToken.slice( 0, -1 );
            }

            string += getUnescapedText( tokenArray );

            return string;
        }
    }

    throwParsingError( 'Invalid DEF unquoted string', context, level );
}

// ~~

function parseDefQuotedString(
    context,
    level
    )
{
    let firstLineIndex = context.lineIndex + 1;
    let string = '';
    let quote = '';
    let escapedQuote = '';

    while ( context.lineIndex < context.lineArray.length )
    {
        let { line, lineSpaceCount } = parseDefLine( context, level );

        if ( context.lineIndex === firstLineIndex )
        {
            quote = line[ 0 ];
            line = line.slice( 1 );
            escapedQuote = '\\' + quote;
        }

        let tokenArray = getTokenArray( line );
        let lastToken = ( tokenArray.length > 0 ) ? tokenArray[ tokenArray.length - 1 ] : '';

        if ( lastToken === '\\' )
        {
            tokenArray.pop();

            string += getUnescapedText( tokenArray );
        }
        else if ( lastToken.endsWith( quote )
                  && lastToken !== escapedQuote )
        {
            tokenArray[ tokenArray.length - 1 ] = lastToken.slice( 0, -1 );

            string += getUnescapedText( tokenArray );

            if ( quote === context.stringProcessingQuote
                 && context.stringProcessingFunction !== null )
            {
                return context.stringProcessingFunction( string, context, level );
            }
            else
            {
                return string;
            }
        }
        else
        {
            if ( lastToken.endsWith( '¨' )
                 && lastToken !== '\\¨' )
            {
                tokenArray[ tokenArray.length - 1 ] = lastToken.slice( 0, -1 );
            }

            string += getUnescapedText( tokenArray ) + '\n';
        }
    }

    throwParsingError( 'Invalid DEF quoted string', context, level );
}

// ~~

function parseDefArray(
    context,
    level
    )
{
    let array = [];

    while ( context.lineIndex < context.lineArray.length )
    {
        let { line, lineSpaceCount } =
            parseDefLine( context, level );

        if ( lineSpaceCount === 0
             && line === ']' )
        {
            return array;
        }
        else
        {
            context.lineIndex--;

            let value = parseDefValue( context, level + 1 );
            array.push( value );
        }
    }

    throwParsingError( 'Invalid DEF array', context, level );
}

// ~~

function parseDefObject(
    context,
    level
    )
{
    let object = {};

    while ( context.lineIndex < context.lineArray.length )
    {
        let { line, lineSpaceCount } =
            parseDefLine( context, level );

        if ( lineSpaceCount === 0
             && line === '}' )
        {
            return object;
        }
        else
        {
            context.lineIndex--;

            let key = parseDefValue( context, level + 1 );
            let value = parseDefValue( context, level + 2 );

            if ( typeof key === 'object'
                 && key !== null )
            {
                object[ JSON.stringify( key ) ] = value;
            }
            else
            {
                object[ String( key ) ] = value;
            }
        }
    }

    throwParsingError( 'Invalid DEF object', context, level );
}

// ~~

function parseDefMap(
    context,
    level
    )
{
    let map = new Map();

    while ( context.lineIndex < context.lineArray.length )
    {
        let { line, lineSpaceCount } =
            parseDefLine( context, level );

        if ( lineSpaceCount === 0
             && line === ')' )
        {
            return map;
        }
        else
        {
            context.lineIndex--;

            let key = parseDefValue( context, level + 1 );
            let value = parseDefValue( context, level + 2 );

            map.set( key, value );
        }
    }

    throwParsingError( 'Invalid DEF map', context, level );
}

// ~~

function parseDefValue(
    context,
    level
    )
{
    if ( context.lineIndex < context.lineArray.length )
    {
        let { line, lineSpaceCount } =
            parseDefLine( context, level );

        if ( line === '[' )
        {
            return parseDefArray( context, level );
        }
        else if ( line === '{' )
        {
            return parseDefObject( context, level );
        }
        else if ( line === '(' )
        {
            return parseDefMap( context, level );
        }
        else if ( line.startsWith( '\'' )
                  || line.startsWith( '"' )
                  || line.startsWith( '`' )
                  || line.startsWith( '´' ) )
        {
            context.lineIndex--;

            return parseDefQuotedString( context, level );
        }
        else
        {
            let tokenArray = getTokenArray( line );

            if ( tokenArray.length === 1 && tokenArray[ 0 ] === line.trim() )
            {
                if ( line === 'undefined' )
                {
                    return undefined;
                }
                else if ( line === 'null' )
                {
                    return null;
                }
                else if ( line === 'false' )
                {
                    return false;
                }
                else if ( line === 'true' )
                {
                    return true;
                }
                else if ( line === 'NaN' )
                {
                    return NaN;
                }
                else if ( line === '-Infinity' )
                {
                    return -Infinity;
                }
                else if ( line === 'Infinity' )
                {
                    return Infinity;
                }
                else if ( hexadecimalIntegerExpression.test( line )
                          || decimalRealExpression.test( line )
                          || exponentialDecimalRealExpression.test( line ) )
                {
                    let number = Number( line );

                    if ( !isNaN( number ) )
                    {
                        return number;
                    }
                }
            }

            context.lineIndex--;

            return parseDefUnquotedString( context, level );
        }
    }
    else
    {
        throwParsingError( 'Invalid DEF value', context, level );
    }
}

// ~~

export function parseDefText(
    text,
    {
        filePath = '',
        stringProcessingQuote = '\'',
        stringProcessingFunction = null,
        levelSpaceCount = 4
    } = {}
    )
{
    let lineArray =
        text
            .replaceAll( '\t', ' '.repeat( levelSpaceCount ) )
            .replaceAll( '\r', '' )
            .split( '\n' );

    let context =
        {
            filePath,
            stringProcessingQuote,
            stringProcessingFunction,
            levelSpaceCount,
            text,
            lineArray,
            lineIndex: 0
        };

    return parseDefValue( context, 0 );
}
