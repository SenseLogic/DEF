// -- CONSTANTS

export function getDumpText(
    value,
    level = 0,
    levelSpaceCount = 2
    )
{
    if ( value === null )
    {
        return 'null';
    }
    else if ( value === undefined )
    {
        return 'undefined';
    }
    else if ( typeof value === 'boolean'
              || typeof value === 'number' )
    {
        return String( value );
    }
    else if ( typeof value === 'string' )
    {
        return JSON.stringify( value );
    }
    else if ( Array.isArray( value ) )
    {
        if ( value.length === 0 )
        {
            return '[]';
        }
        else
        {
            let text = '[\n';
            let indent = ' '.repeat( ( level + 1 ) * levelSpaceCount );

            for ( let item of value )
            {
                text
                    += indent
                       + getDumpText( item, level + 1, levelSpaceCount )
                       + ',\n';
            }

            text = text.substring( 0, text.length - 2, levelSpaceCount ) + '\n';
            text += ' '.repeat( level * levelSpaceCount ) + ']';

            return text;
        }
    }
    else if ( value instanceof Map )
    {
        if ( value.size === 0 )
        {
            return 'Map(0) {}';
        }
        else
        {
            let text = 'Map(' + value.size + ') {\n';
            let indent = ' '.repeat( ( level + 1 ) * levelSpaceCount );

            for ( let [ key, val ] of value.entries() )
            {
                text
                    += indent
                       + getDumpText( key, level + 1, levelSpaceCount )
                       + ' => '
                       + getDumpText( val, level + 1, levelSpaceCount )
                       + ',\n';
            }

            text = text.substring( 0, text.length - 2 ) + '\n';
            text += ' '.repeat( level * levelSpaceCount ) + '}';

            return text;
        }
    }
    else if ( typeof value === 'object' )
    {
        if ( Object.keys( value ).length === 0 )
        {
            return '{}';
        }
        else
        {
            let text = '{\n';
            let indent = ' '.repeat( ( level + 1 ) * levelSpaceCount );

            for ( let key in value )
            {
                if ( Object.prototype.hasOwnProperty.call( value, key ) )
                {
                    text
                        += indent
                           + JSON.stringify( key )
                           + ': '
                           + getDumpText( value[ key ], level + 1, levelSpaceCount )
                           + ',\n';
                }
            }

            text = text.substring( 0, text.length - 2 ) + '\n';
            text += ' '.repeat( level * levelSpaceCount ) + '}';

            return text;
        }
    }
    else
    {
        return String( value );
    }
}
