// -- IMPORTS

import md5 from 'md5';
import { parseDefText, throwParsingError } from './parsing.js';

// -- FUNCTIONS

export function getNaturalTextComparison(
    firstText,
    secondText
    )
{
    let firstCharacterCount = firstText.length;
    let secondCharacterCount = secondText.length;
    let firstCharacterIndex = 0;
    let secondCharacterIndex = 0;

    while ( firstCharacterIndex < firstCharacterCount
            && secondCharacterIndex < secondCharacterCount )
    {
        let firstCharacter = firstText[ firstCharacterIndex ];
        let secondCharacter = secondText[ secondCharacterIndex ];

        if ( firstCharacter === secondCharacter )
        {
            ++firstCharacterIndex;
            ++secondCharacterIndex;
        }
        else
        {
            if ( firstCharacter >= '0'
                 && firstCharacter <= '9'
                 && secondCharacter >= '0'
                 && secondCharacter <= '9' )
            {
                let firstNumberText = '';
                let secondNumberText = '';

                while ( firstCharacterIndex < firstCharacterCount
                        && firstText[ firstCharacterIndex ] >= '0'
                        && firstText[ firstCharacterIndex ] <= '9' )
                {
                    firstNumberText += firstText[ firstCharacterIndex ];

                    ++firstCharacterIndex;
                }

                while ( secondCharacterIndex < secondCharacterCount
                        && secondText[ secondCharacterIndex ] >= '0'
                        && secondText[ secondCharacterIndex ] <= '9' )
                {
                    secondNumberText += secondText[ secondCharacterIndex ];

                    ++secondCharacterIndex;
                }

                return parseInt( firstNumberText ) - parseInt( secondNumberText );
            }
            else if ( firstCharacter < secondCharacter )
            {
                return -1;
            }
            else
            {
                return 1;
            }
        }
    }

    return firstCharacterCount - secondCharacterCount;
}

// ~~

export function getDefTextHash(
    text
    )
{
    return md5( text );
}

// ~~

export function getDefTextUuid(
    text
    )
{
    if ( text === '' )
    {
        return '';
    }
    else
    {
        let md5_hash = md5( text );

        return (
            md5_hash.slice( 0, 8 )
            + '-'
            + md5_hash.slice( 8, 12 )
            + '-'
            + md5_hash.slice( 12, 16 )
            + '-'
            + md5_hash.slice( 16, 20 )
            + '-'
            + md5_hash.slice( 20, 32 )
            );
    }
}

// ~~

export function getDefTextTuid(
    text
    )
{
    if ( text === '' )
    {
        return '';
    }
    else
    {
        let md5_hash = md5( text );

        return (
            Buffer
                .from( md5_hash, 'hex' )
                .toString( 'base64' )
                .replaceAll( '+', '-' )
                .replaceAll( '/', '_' )
                .replaceAll( '=', '' )
            );
    }
}

// ~~

export function processDefQuotedString(
    string,
    context,
    level
    )
{
    if ( string.startsWith( '#' ) )
    {
        return getDefTextUuid( string.slice( 1 ) );
    }
    else if ( string.startsWith( '%' ) )
    {
        return getDefTextTuid( string.slice( 1 ) );
    }
    else
    {
        return string;
    }
}
