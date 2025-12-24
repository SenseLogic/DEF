# -- IMPORTS

import hashlib;
import os;

# -- CONSTANTS

is_browser = False;

# -- FUNCTIONS

def get_natural_text_comparison(
    first_text,
    second_text
    ):

    first_character_count = len( first_text );
    second_character_count = len( second_text );
    first_character_index = 0;
    second_character_index = 0;

    while first_character_index < first_character_count and second_character_index < second_character_count:

        first_character = first_text[ first_character_index ];
        second_character = second_text[ second_character_index ];

        if first_character == second_character:

            first_character_index += 1;
            second_character_index += 1;

        else:

            if (
                first_character >= "0"
                and first_character <= "9"
                and second_character >= "0"
                and second_character <= "9"
                ):

                first_number_text = "";
                second_number_text = "";

                while (
                    first_character_index < first_character_count
                    and first_text[ first_character_index ] >= "0"
                    and first_text[ first_character_index ] <= "9"
                    ):

                    first_number_text += first_text[ first_character_index ];

                    first_character_index += 1;

                while (
                    second_character_index < second_character_count
                    and second_text[ second_character_index ] >= "0"
                    and second_text[ second_character_index ] <= "9"
                    ):

                    second_number_text += second_text[ second_character_index ];

                    second_character_index += 1;

                return int( first_number_text ) - int( second_number_text );

            elif first_character < second_character:

                return -1;

            else:

                return 1;

    return first_character_count - second_character_count;

# ~~

def get_def_text_hash(
    text
    ):

    return hashlib.md5( text.encode( "utf8" ) ).hexdigest();

# ~~

def get_def_text_uuid(
    text
    ):

    if text == "":

        return "";

    else:

        hash_value = hashlib.md5( text.encode( "utf8" ) ).hexdigest();

        return (
            hash_value[ 0:8 ]
            + "-"
            + hash_value[ 8:12 ]
            + "-"
            + hash_value[ 12:16 ]
            + "-"
            + hash_value[ 16:20 ]
            + "-"
            + hash_value[ 20:32 ]
        );

# ~~

def get_def_text_tuid(
    text
    ):

    if text == "":

        return "";

    else:

        hash_value = hashlib.md5( text.encode( "utf8" ) ).hexdigest();

        import base64;

        tuid = base64.b64encode( bytes.fromhex( hash_value ) ).decode( "utf8" );

        return tuid.replace( "+", "-" ).replace( "/", "_" ).replace( "=", "" );

# ~~

def process_def_quoted_string(
    string,
    context,
    level
    ):

    if string.startswith( "#" ):

        return get_def_text_uuid( string[ 1: ] );

    elif string.startswith( "%" ):

        return get_def_text_tuid( string[ 1: ] );

    else:

        return string;
