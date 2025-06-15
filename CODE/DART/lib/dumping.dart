import 'dart:convert';
import 'constant.dart';

// -- FUNCTIONS

String getDumpText(
    dynamic value,
    [
        int level = 0,
        int levelSpaceCount = 2
    ]
    )
{
    if ( value == undefined )
    {
        return 'undefined';
    }
    else if ( value == null )
    {
        return 'null';
    }
    else if ( value is bool
              || value is num )
    {
        return value.toString();
    }
    else if ( value is String )
    {
        return jsonEncode( value );
    }
    else if ( value is List )
    {
        if ( value.isEmpty )
        {
            return '[]';
        }
        else
        {
            var text = '[\n';
            var indent = ' ' * ( ( level + 1 ) * levelSpaceCount );

            for ( var item in value )
            {
                text
                    += indent
                       + getDumpText( item, level + 1, levelSpaceCount )
                       + ',\n';
            }

            text = text.substring( 0, text.length - 2 ) + '\n';
            text += ' ' * ( level * levelSpaceCount ) + ']';

            return text;
        }
    }
    else if ( value is Map<String, dynamic> )
    {
        if ( value.isEmpty )
        {
            return '{}';
        }
        else
        {
            var text = '{\n';
            var indent = ' ' * ( ( level + 1 ) * levelSpaceCount );

            for ( var key in value.keys )
            {
                if ( value.containsKey( key ) )
                {
                    text
                        += indent
                           + jsonEncode( key )
                           + ': '
                           + getDumpText( value[ key ], level + 1, levelSpaceCount )
                           + ',\n';
                }
            }

            text = text.substring( 0, text.length - 2 ) + '\n';
            text += ' ' * ( level * levelSpaceCount ) + '}';

            return text;
        }
    }
    else if ( value is Map<dynamic, dynamic> )
    {
        if ( value.isEmpty )
        {
            return 'Map(0) {}';
        }
        else
        {
            var text = 'Map(' + value.length.toString() + ') {\n';
            var indent = ' ' * ( ( level + 1 ) * levelSpaceCount );

            for ( var entry in value.entries )
            {
                text
                    += indent
                       + getDumpText( entry.key, level + 1, levelSpaceCount )
                       + ' => '
                       + getDumpText( entry.value, level + 1, levelSpaceCount )
                       + ',\n';
            }

            text = text.substring( 0, text.length - 2 ) + '\n';
            text += ' ' * ( level * levelSpaceCount ) + '}';

            return text;
        }
    }
    else
    {
        return value.toString();
    }
}
