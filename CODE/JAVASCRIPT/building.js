// -- CONSTANTS

var
    decimalRealExpression = /^-?\d+(\.\d+)?$/,
    exponentialDecimalRealExpression = /^-?\d+(\.\d+)?[eE][-+]?\d+$/,
    hexadecimalIntegerExpression = /^0x[0-9A-Fa-f]+$/;

// -- FUNCTIONS

function buildDefString(
    value,
    context,
    level
    )
{
    let indent = ' '.repeat( level * context.levelSpaceCount );

    if ( value === '' )
    {
        context.lineArray.push( indent + '¨' );
    }
    else if ( value === '['
              || value === '{'
              || value === '('
              || value === 'undefined'
              || value === 'null'
              || value === 'false'
              || value === 'true'
              || value === 'NaN'
              || value === '-Infinity'
              || value === 'Infinity'
              || hexadecimalIntegerExpression.test( value )
              || decimalRealExpression.test( value )
              || exponentialDecimalRealExpression.test( value ) )
    {
        context.lineArray.push( indent + value + '¨' );
    }
    else
    {
        let lineArray = value.split( '\n' );
        let lineCount = lineArray.length;
        let quote;

        if ( lineCount === 1 )
        {
            quote = '';
        }
        else
        {
            quote = context.quote;
        }

        for ( let lineIndex = 0;
              lineIndex < lineCount;
              ++lineIndex )
        {
            let line =
                lineArray[ lineIndex ]
                    .replaceAll( '\\', '\\\\' )
                    .replaceAll( '\b', '\\b' )
                    .replaceAll( '\f', '\\f' )
                    .replaceAll( '\r', '\\r' )
                    .replaceAll( '\t', '\\t' )
                    .replaceAll( '\v', '\\v' );

            if ( lineCount === 1 )
            {
                if ( line.startsWith( '\'' )
                     || line.startsWith( '"' )
                     || line.startsWith( '`' )
                     || line.startsWith( '´' ) )
                {
                    line = '\\' + line;
                }

                if ( line.endsWith( ' ' ) )
                {
                    line += '¨';
                }
                else if ( line.endsWith( '¨' ) )
                {
                    line = line.slice( 0, -1 ) + '\\¨';
                }
            }
            else
            {
                if ( lineIndex === 0 )
                {
                    line = quote + line;
                }

                if ( lineIndex > 0
                     && lineIndex < lineCount - 1 )
                {
                    if ( line.endsWith( quote ) )
                    {
                        line = line.slice( 0, -1 ) + '\\' + quote;
                    }
                }

                if ( lineIndex === lineCount - 1 )
                {
                    line += quote;
                }
                else if ( line.endsWith( ' ' ) )
                {
                    line += '¨';
                }
                else if ( line.endsWith( '¨' ) )
                {
                    line = line.slice( 0, -1 ) + '\\¨';
                }
            }

            context.lineArray.push( indent + line );
        }
    }
}

// ~~

function buildDefValue(
    value,
    context,
    level
    )
{
    let indent = ' '.repeat( level * context.levelSpaceCount );

    if ( value === undefined )
    {
        context.lineArray.push( indent + 'undefined' );
    }
    else if ( value === null )
    {
        context.lineArray.push( indent + 'null' );
    }
    else if ( typeof value === 'boolean' )
    {
        context.lineArray.push( indent + value );
    }
    else if ( typeof value === 'number' )
    {
        if ( isNaN( value ) )
        {
            context.lineArray.push( indent + 'NaN' );
        }
        else if ( !isFinite( value ) )
        {
            context.lineArray.push( indent + ( value > 0 ? 'Infinity' : '-Infinity' ) );
        }
        else
        {
            context.lineArray.push( indent + value );
        }
    }
    else if ( typeof value === 'string' )
    {
        buildDefString( value, context, level );
    }
    else if ( Array.isArray( value ) )
    {
        context.lineArray.push( indent + '[' );

        for ( let item of value )
        {
            buildDefValue( item, context, level + 1 );
        }

        context.lineArray.push( indent + ']' );
    }
    else if ( value instanceof Map )
    {
        context.lineArray.push( indent + '(' );

        for ( let [ key, val ] of value.entries() )
        {
            buildDefValue( key, context, level + 1 );
            buildDefValue( val, context, level + 2 );
        }

        context.lineArray.push( indent + ')' );
    }
    else if ( typeof value === 'object' )
    {
        context.lineArray.push( indent + '{' );

        for ( let key in value )
        {
            if ( Object.prototype.hasOwnProperty.call( value, key ) )
            {
                buildDefString( key, context, level + 1 );
                buildDefValue( value[ key ], context, level + 2 );
            }
        }

        context.lineArray.push( indent + '}' );
    }
}

// ~~

export function buildDefText(
    value,
    {
        levelSpaceCount = 4,
        quote = '´'
    } = {}
    )
{
    let context =
        {
            levelSpaceCount,
            quote,
            lineArray: []
        };

    buildDefValue( value, context, 0 );

    return context.lineArray.join( '\n' );
}
