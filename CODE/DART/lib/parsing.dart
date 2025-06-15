import 'dart:convert';
import 'constant.dart';

// -- CONSTANTS

final RegExp
    _decimalRealExpression = RegExp( r'^-?\d+(\.\d+)?$' ),
    _exponentialDecimalRealExpression = RegExp( r'^-?\d+(\.\d+)?[eE][-+]?\d+$' ),
    _hexadecimalIntegerExpression = RegExp( r'^0x[0-9A-Fa-f]+$' );

// -- TYPES

class _Line
{
    // -- ATTRIBUTES

    final String
        line;
    final int
        lineSpaceCount;

    // -- CONSTRUCTORS

    _Line(
        {
            required this.line,
            required this.lineSpaceCount,
        }
        );
}

// ~~

class _Context
{
    // -- ATTRIBUTES

    final String
        text;
    final List<String>
        lineArray;
    int
        lineIndex;
    final int
        levelSpaceCount;

    // -- CONSTRUCTORS

    _Context(
        {
            required this.text,
            required this.lineArray,
            this.lineIndex = 0,
            required this.levelSpaceCount
        }
        );
}

// -- FUNCTIONS

List<String> getTokenArray(
    String text
    )
{
    var tokenArray = <String>[];
    var characterIndex = 0;

    while ( characterIndex < text.length )
    {
        if ( text[ characterIndex ] == '\\' )
        {
            if ( characterIndex + 1 < text.length )
            {
                tokenArray.add( text.substring( characterIndex, characterIndex + 2 ) );
                characterIndex += 2;
            }
            else
            {
                tokenArray.add( text[ characterIndex ] );
                ++characterIndex;
            }
        }
        else
        {
            var postCharacterIndex = characterIndex;

            while ( postCharacterIndex < text.length
                    && text[ postCharacterIndex ] != '\\' )
            {
                ++postCharacterIndex;
            }

            tokenArray.add( text.substring( characterIndex, postCharacterIndex ) );
            characterIndex = postCharacterIndex;
        }
    }

    return tokenArray;
}

// ~~

String getUnescapedText(
    List<String> tokenArray
    )
{
    var unescapedText = '';

    for ( var token in tokenArray )
    {
        if ( token.length == 2
             && token[ 0 ] == '\\' )
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

void throwParsingError(
    String message,
    _Context context,
    int level
    )
{
    message =
        message
        + '\nText:\n'
        + context.text
        + '\nLine ' + context.lineIndex.toString() + ' @ ' + level.toString();

    if ( context.lineIndex > 0
         && context.lineIndex <= context.lineArray.length )
    {
        message += ' : ' + context.lineArray[ context.lineIndex - 1 ];
    }

    throw Exception( message );
}

// ~~

_Line parseDefLine(
    _Context context,
    int level
    )
{
    var line = context.lineArray[ context.lineIndex ];
    var trimmedLine = line.trimLeft();
    var levelSpaceCount = level * context.levelSpaceCount;
    var lineSpaceCount = line.length - trimmedLine.length;

    if ( trimmedLine == '' )
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

        line = line.substring( levelSpaceCount ).trimRight();
        lineSpaceCount -= levelSpaceCount;
    }

    context.lineIndex++;

    return _Line( line: line, lineSpaceCount: lineSpaceCount );
}

// ~~

String parseDefUnquotedString(
    _Context context,
    int level
    )
{
    var string = '';

    while ( context.lineIndex < context.lineArray.length )
    {
        var _Line( :line, :lineSpaceCount )
            = parseDefLine( context, level );

        var tokenArray = getTokenArray( line );
        var lastToken = tokenArray.isNotEmpty ? tokenArray.last : '';

        if ( lastToken == '\\' )
        {
            tokenArray.removeLast();
            string += getUnescapedText( tokenArray );
        }
        else
        {
            if ( line.endsWith( '¨' )
                 && lastToken != '\\¨' )
            {
                tokenArray[ tokenArray.length - 1 ] = lastToken.substring( 0, lastToken.length - 1 );
            }

            string += getUnescapedText( tokenArray );

            return string;
        }
    }

    throwParsingError( 'Invalid DEF unquoted string', context, level );

    return '';
 }

// ~~

String parseDefQuotedString(
    _Context context,
    int level
    )
{
    var firstLineIndex = context.lineIndex + 1;
    var string = '';
    var quote = '';
    var escapedQuote = '';

    while ( context.lineIndex < context.lineArray.length )
    {
        var _Line( :line, :lineSpaceCount )
            = parseDefLine( context, level );

        if ( context.lineIndex == firstLineIndex )
        {
            quote = line[ 0 ];
            line = line.substring( 1 );
            escapedQuote = '\\' + quote;
        }

        var tokenArray = getTokenArray( line );
        var lastToken = tokenArray.isNotEmpty ? tokenArray.last : '';

        if ( lastToken == '\\' )
        {
            tokenArray.removeLast();

            string += getUnescapedText( tokenArray );
        }
        else if ( lastToken.endsWith( quote )
                  && lastToken != escapedQuote )
        {
            tokenArray[ tokenArray.length - 1 ] = lastToken.substring( 0, lastToken.length - 1 );

            string += getUnescapedText( tokenArray );

            return string;
        }
        else
        {
            if ( lastToken.endsWith( '¨' )
                 && lastToken != '\\¨' )
            {
                tokenArray[ tokenArray.length - 1 ] = lastToken.substring( 0, lastToken.length - 1 );
            }

            string += getUnescapedText( tokenArray ) + '\n';
        }
    }

    throwParsingError( 'Invalid DEF quoted string', context, level );

    return '';
 }

// ~~

List<dynamic> parseDefArray(
    _Context context,
    int level
    )
{
    var array = <dynamic>[];

    while ( context.lineIndex < context.lineArray.length )
    {
        var _Line( :line, :lineSpaceCount )
            = parseDefLine( context, level );

        if ( lineSpaceCount == 0
             && line == ']' )
        {
            return array;
        }
        else
        {
            context.lineIndex--;

            var value = parseDefValue( context, level + 1 );
            array.add( value );
        }
    }

    throwParsingError( 'Invalid DEF array', context, level );

    return [];
 }

// ~~

Map<String, dynamic> parseDefObject(
    _Context context,
    int level
    )
{
    var object = <String, dynamic>{};

    while ( context.lineIndex < context.lineArray.length )
    {
        var _Line( :line, :lineSpaceCount )
            = parseDefLine( context, level );

        if ( lineSpaceCount == 0
             && line == '}' )
        {
            return object;
        }
        else
        {
            context.lineIndex--;

            var key = parseDefValue( context, level + 1 );
            var value = parseDefValue( context, level + 2 );

            if ( key == undefined )
            {
                object[ 'undefined' ] = value;
            }
            else if ( key is Map
                      || key is List
                      || key is bool
                      || key is num )
            {
                object[ jsonEncode( key ) ] = value;
            }
            else
            {
                object[ key.toString() ] = value;
            }
        }
    }

    throwParsingError( 'Invalid DEF object', context, level );

    return {};
 }

// ~~

Map<dynamic, dynamic> parseDefMap(
    _Context context,
    int level
    )
{
    var map = <dynamic, dynamic>{};

    while ( context.lineIndex < context.lineArray.length )
    {
        var _Line( :line, :lineSpaceCount )
            = parseDefLine( context, level );

        if ( lineSpaceCount == 0
             && line == ')' )
        {
            return map;
        }
        else
        {
            context.lineIndex--;

            var key = parseDefValue( context, level + 1 );
            var value = parseDefValue( context, level + 2 );

            map[ key ] = value;
        }
    }

    throwParsingError( 'Invalid DEF map', context, level );

    return {};
}

// ~~

dynamic parseDefValue(
    _Context context,
    int level
    )
{
    if ( context.lineIndex < context.lineArray.length )
    {
        var _Line( :line, :lineSpaceCount )
            = parseDefLine( context, level );

        if ( line == '[' )
        {
            return parseDefArray( context, level );
        }
        else if ( line == '{' )
        {
            return parseDefObject( context, level );
        }
        else if ( line == '(' )
        {
            return parseDefMap( context, level );
        }
        else if ( line.startsWith( '"' )
                  || line.startsWith( '`' )
                  || line.startsWith( '´' ) )
        {
            context.lineIndex--;

            return parseDefQuotedString( context, level );
        }
        else
        {
            var tokenArray = getTokenArray( line );

            if ( tokenArray.length == 1
                 && tokenArray[ 0 ] == line.trim() )
            {
                if ( line == 'undefined' )
                {
                    return undefined;
                }
                else if ( line == 'null' )
                {
                    return null;
                }
                else if ( line == 'false' )
                {
                    return false;
                }
                else if ( line == 'true' )
                {
                    return true;
                }
                else if ( line == 'NaN' )
                {
                    return double.nan;
                }
                else if ( line == '-Infinity' )
                {
                    return double.negativeInfinity;
                }
                else if ( line == 'Infinity' )
                {
                    return double.infinity;
                }
                else if ( _hexadecimalIntegerExpression.hasMatch( line ) ||
                        _decimalRealExpression.hasMatch( line ) ||
                        _exponentialDecimalRealExpression.hasMatch( line ) )
                {
                    num? number = num.tryParse( line );

                    if ( number != null
                         && !number.isNaN )
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

dynamic parseDefText(
    String text,
    {
        int levelSpaceCount = 4
    }
    )
{
    var lineArray =
        text
            .replaceAll( '\t', ' ' * levelSpaceCount )
            .replaceAll( '\r', '' )
            .split( '\n' );

    var context =
        _Context(
            text : text,
            lineArray : lineArray,
            levelSpaceCount : levelSpaceCount
            );

    return parseDefValue( context, 0 );
}
