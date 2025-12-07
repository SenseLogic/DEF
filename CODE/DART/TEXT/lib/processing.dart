// -- IMPORTS

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'parsing.dart';

// -- FUNCTIONS

int getNaturalTextComparison(
    String firstText,
    String secondText
    )
{
    var firstCharacterCount = firstText.length;
    var secondCharacterCount = secondText.length;
    var firstCharacterIndex = 0;
    var secondCharacterIndex = 0;

    while ( firstCharacterIndex < firstCharacterCount
            && secondCharacterIndex < secondCharacterCount )
    {
        var firstCharacter = firstText[ firstCharacterIndex ];
        var secondCharacter = secondText[ secondCharacterIndex ];

        if ( firstCharacter == secondCharacter )
        {
            ++firstCharacterIndex;
            ++secondCharacterIndex;
        }
        else
        {
            var firstCodeUnit = firstCharacter.codeUnitAt( 0 );
            var secondCodeUnit = secondCharacter.codeUnitAt( 0 );

            if ( firstCodeUnit >= 48
                 && firstCodeUnit <= 57
                 && secondCodeUnit >= 48
                 && secondCodeUnit <= 57 )
            {
                var firstNumberText = '';
                var secondNumberText = '';

                while ( firstCharacterIndex < firstCharacterCount
                        && firstText[ firstCharacterIndex ].codeUnitAt( 0 ) >= 48
                        && firstText[ firstCharacterIndex ].codeUnitAt( 0 ) <= 57 )
                {
                    firstNumberText += firstText[ firstCharacterIndex ];

                    ++firstCharacterIndex;
                }

                while ( secondCharacterIndex < secondCharacterCount
                        && secondText[ secondCharacterIndex ].codeUnitAt( 0 ) >= 48
                        && secondText[ secondCharacterIndex ].codeUnitAt( 0 ) <= 57 )
                {
                    secondNumberText += secondText[ secondCharacterIndex ];

                    ++secondCharacterIndex;
                }

                return int.parse( firstNumberText ) - int.parse( secondNumberText );
            }
            else
            {
                return firstCharacter.compareTo( secondCharacter );
            }
        }
    }

    return firstCharacterCount - secondCharacterCount;
}

// ~~

String getDefTextHash(
    String text
    )
{
    return md5.convert( utf8.encode( text ) ).toString();
}

// ~~

String getDefTextUuid(
    String text
    )
{
    if ( text == '' )
    {
        return '';
    }
    else
    {
        var md5_hash = md5.convert( utf8.encode( text ) ).toString();

        return (
            md5_hash.substring( 0, 8 )
            + '-'
            + md5_hash.substring( 8, 12 )
            + '-'
            + md5_hash.substring( 12, 16 )
            + '-'
            + md5_hash.substring( 16, 20 )
            + '-'
            + md5_hash.substring( 20, 32 )
            );
    }
}

// ~~

String getDefTextTuid(
    String text
    )
{
    if ( text == '' )
    {
        return '';
    }
    else
    {
        var md5_hash = md5.convert( utf8.encode( text ) ).bytes;

        return (
            base64Url.encode( md5_hash )
                .replaceAll( '+', '-' )
                .replaceAll( '/', '_' )
                .replaceAll( '=', '' )
            );
    }
}

// ~~

dynamic processDefQuotedString(
    String string,
    ParsingContext context,
    int level
    )
{
    if ( string.startsWith( '#' ) )
    {
        return getDefTextUuid( string.substring( 1 ) );
    }
    else if ( string.startsWith( '%' ) )
    {
        return getDefTextTuid( string.substring( 1 ) );
    }
    else
    {
        return string;
    }
}
