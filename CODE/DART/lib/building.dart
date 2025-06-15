// -- IMPORTS

import 'constant.dart';

// -- CONSTANTS

final RegExp
    _decimalRealExpression = RegExp( r'^-?\d+(\.\d+)?$' ),
    _exponentialDecimalRealExpression = RegExp( r'^-?\d+(\.\d+)?[eE][-+]?\d+$' ),
    _hexadecimalIntegerExpression = RegExp( r'^0x[0-9A-Fa-f]+$' );

// -- TYPES

class _Context
{
    // -- ATTRIBUTES

    final int
        levelSpaceCount;
    final String
        quote;
    final List<String>
        lineArray;

    // -- CONSTRUCTORS

    _Context(
        {
            required this.levelSpaceCount,
            required this.quote,
            List<String>? lineArray
        }
        ) : lineArray = lineArray ?? [];
}

// -- FUNCTIONS

void buildDefString(
    dynamic value,
    _Context context,
    int level
    )
{
    var indent = ' ' * ( level * context.levelSpaceCount );

    if ( value == '' )
    {
        context.lineArray.add( indent + '¨' );
    }
    else if ( value == '['
              || value == '{'
              || value == '('
              || value == 'undefined'
              || value == 'false'
              || value == 'true'
              || value == 'null'
              || value == 'NaN'
              || value == '-Infinity'
              || value == 'Infinity'
              || _hexadecimalIntegerExpression.hasMatch( value )
              || _decimalRealExpression.hasMatch( value )
              || _exponentialDecimalRealExpression.hasMatch( value ) )
    {
        context.lineArray.add( indent + value + '¨' );
    }
    else
    {
        var lineArray = value.split( '\n' );
        var lineCount = lineArray.length;
        var quote;

        if ( lineCount == 1 )
        {
            quote = '';
        }
        else
        {
            quote = context.quote;
        }

        for ( int lineIndex = 0; lineIndex < lineCount; ++lineIndex )
        {
            var line =
                lineArray[ lineIndex ]
                    .replaceAll( '\\', '\\\\' )
                    .replaceAll( '\b', '\\b' )
                    .replaceAll( '\f', '\\f' )
                    .replaceAll( '\r', '\\r' )
                    .replaceAll( '\t', '\\t' )
                    .replaceAll( '\v', '\\v' );

            if ( lineCount == 1 )
            {
                if ( line.startsWith( '"' )
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
                    line = line.substring( 0, line.length - 1 ) + '\\¨';
                }
            }
            else
            {
                if ( lineIndex == 0 )
                {
                    line = quote + line;
                }

                if ( lineIndex > 0
                     && lineIndex < lineCount - 1 )
                {
                    if ( line.endsWith( quote ) )
                    {
                        line = line.substring( 0, line.length - 1 ) + '\\' + quote;
                    }
                }

                if ( lineIndex == lineCount - 1 )
                {
                    line += quote;
                }
                else if ( line.endsWith( ' ' ) )
                {
                    line += '¨';
                }
                else if ( line.endsWith( '¨' ) )
                {
                    line = line.substring( 0, line.length - 1 ) + '\\¨';
                }
            }

            context.lineArray.add( indent + line );
        }
    }
}

// ~~

void buildDefValue(
    dynamic value,
    _Context context,
    int level
    )
{
    var indent = ' ' * ( level * context.levelSpaceCount );

    if ( value == undefined )
    {
        context.lineArray.add( indent + 'undefined' );
    }
    else if ( value == null )
    {
        context.lineArray.add( indent + 'null' );
    }
    else if ( value is bool )
    {
        context.lineArray.add( indent + value.toString() );
    }
    else if ( value is num )
    {
        if ( value.isNaN )
        {
            context.lineArray.add( indent + 'NaN' );
        }
        else if ( !value.isFinite )
        {
            context.lineArray.add( indent + ( value > 0 ? 'Infinity' : '-Infinity' ) );
        }
        else
        {
            context.lineArray.add( indent + value.toString() );
        }
    }
    else if ( value is String )
    {
        buildDefString( value, context, level );
    }
    else if ( value is List )
    {
        context.lineArray.add( indent + '[' );

        for ( var item in value )
        {
            buildDefValue( item, context, level + 1 );
        }

        context.lineArray.add( indent + ']' );
    }
    else if ( value is Map<String, dynamic> )
    {
        context.lineArray.add( indent + '{' );

        for ( var key in value.keys )
        {
            if ( value.containsKey( key ) )
            {
                buildDefString( key, context, level + 1 );
                buildDefValue( value[ key ], context, level + 2 );
            }
        }

        context.lineArray.add( indent + '}' );
    }
    else if ( value is Map<dynamic, dynamic> )
    {
        context.lineArray.add( indent + '(' );

        for ( var entry in value.entries )
        {
            buildDefValue( entry.key, context, level + 1 );
            buildDefValue( entry.value, context, level + 2 );
        }

        context.lineArray.add( indent + ')' );
    }
}

// ~~

String buildDefText(
    dynamic value,
    {
        int levelSpaceCount = 4,
        String quote = '´'
    }
    )
{
    var context =
        _Context(
            levelSpaceCount : levelSpaceCount,
            quote : quote
            );

    buildDefValue( value, context, 0 );

    return context.lineArray.join( '\n' );
}
