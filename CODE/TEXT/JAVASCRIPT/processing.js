// -- IMPORTS

import md5 from 'md5';
import { parseDefText, throwParsingError } from './parsing.js';

// -- CONSTANTS

const
    isBrowser = ( typeof window !== 'undefined' && typeof window.document !== 'undefined' );

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
        let hash = md5( text );

        return (
            hash.slice( 0, 8 )
            + '-'
            + hash.slice( 8, 12 )
            + '-'
            + hash.slice( 12, 16 )
            + '-'
            + hash.slice( 16, 20 )
            + '-'
            + hash.slice( 20, 32 )
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
        let hash = md5( text );
        let tuid = '';

        if ( isBrowser )
        {
            let buffer = '';

            for ( let byteIndex = 0; byteIndex < hash.length; byteIndex += 2 )
            {
                buffer += String.fromCharCode( parseInt( hash.slice( byteIndex, byteIndex + 2 ), 16 ) );
            }
            
            tuid = btoa( buffer );
        }
        else
        {
            tuid = Buffer.from( hash, 'hex' ).toString( 'base64' );
        }
    
        return (
            tuid
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
