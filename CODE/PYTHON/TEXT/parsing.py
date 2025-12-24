# -- IMPORTS

import re;

from .constant import undefined;
from .map import Map;
from .processing import process_def_quoted_string;

# -- CONSTANTS

decimal_real_expression = re.compile( r"^-?\d+(\.\d+)?$" );
exponential_decimal_real_expression = re.compile( r"^-?\d+(\.\d+)?[eE][-+]?\d+$" );
hexadecimal_integer_expression = re.compile( r"^0x[0-9A-Fa-f]+$" );

# -- FUNCTIONS

def get_key_text(
    key
    ):

    if key is not None and isinstance( key, dict ):

        import json;

        return json.dumps( key );

    else:

        return str( key );

# ~~

def get_token_array(
    text
    ):

    token_array = [];
    character_index = 0;

    while character_index < len( text ):

        if text[ character_index ] == "\\":

            if character_index + 1 < len( text ):

                token_array.append( text[ character_index ] + text[ character_index + 1 ] );
                character_index += 2;
            else:

                token_array.append( text[ character_index ] );
                character_index += 1;

        else:

            post_character_index = character_index;

            while post_character_index < len( text ) and text[ post_character_index ] != "\\":

                post_character_index += 1;

            token_array.append( text[ character_index:post_character_index ] );
            character_index = post_character_index;

    return token_array;

# ~~

def get_unescaped_text(
    token_array
    ):

    unescaped_text = "";

    for token in token_array:

        if len( token ) == 2 and token[ 0 ] == "\\":

            if token[ 1 ] == "n":

                unescaped_text += "\n";

            elif token[ 1 ] == "t":

                unescaped_text += "\t";

            elif token[ 1 ] == "r":

                unescaped_text += "\r";

            elif token[ 1 ] == "b":

                unescaped_text += "\b";

            elif token[ 1 ] == "f":

                unescaped_text += "\f";

            elif token[ 1 ] == "0":

                unescaped_text += "\0";

            else:

                unescaped_text += token[ 1 ];

        else:

            unescaped_text += token;

    return unescaped_text;

# ~~

def get_object_key_text( key ):

    if key is undefined:

        return "undefined";

    if key is None:

        return "null";

    if key is True:

        return "true";

    if key is False:

        return "false";

    if isinstance( key, float ):

        if key != key:

            return "NaN";

        if key == float( "inf" ):

            return "Infinity";

        if key == float( "-inf" ):

            return "-Infinity";

    return str( key );

# ~~

def throw_parsing_error(
    message,
    context,
    level
    ):

    message = (
        message
        + "\nText :\n"
        + context[ "text" ]
        + "\nFile : "
        + context[ "file_path" ]
        + "\nLine "
        + str( context[ "line_index" ] )
        + " @ "
        + str( level )
        );

    if context[ "line_index" ] > 0 and context[ "line_index" ] <= len( context[ "line_array" ] ):

        message += " : " + context[ "line_array" ][ context[ "line_index" ] - 1 ];

    raise Exception( message );

# ~~

def parse_def_line(
    context,
    level
    ):

    line = context[ "line_array" ][ context[ "line_index" ] ];
    trimmed_line = line.lstrip();
    level_space_count = level * context[ "level_space_count" ];
    line_space_count = len( line ) - len( trimmed_line );

    if trimmed_line == "":

        line = "";
        line_space_count = 0;

    else:

        if line_space_count < level_space_count:

            throw_parsing_error( "Invalid DEF line", context, level );

        line = line[ level_space_count: ].rstrip();
        line_space_count -= level_space_count;

    context[ "line_index" ] += 1;

    return { "line": line, "line_space_count": line_space_count };

# ~~

def parse_def_unquoted_string(
    context,
    level
    ):

    string = "";

    while context[ "line_index" ] < len( context[ "line_array" ] ):

        parsed_line = parse_def_line( context, level );
        line = parsed_line[ "line" ];
        line_space_count = parsed_line[ "line_space_count" ];

        token_array = get_token_array( line );
        last_token = token_array[ len( token_array ) - 1 ] if len( token_array ) > 0 else "";

        if last_token == "\\":

            token_array.pop();

            string += get_unescaped_text( token_array );

        else:

            if line.endswith( "¨" ) and last_token != "\\¨":

                token_array[ len( token_array ) - 1 ] = last_token[ : len( last_token ) - 1 ];

            string += get_unescaped_text( token_array );

            return string;

    throw_parsing_error( "Invalid DEF unquoted string", context, level );

# ~~

def parse_def_quoted_string(
    context,
    level
    ):

    first_line_index = context[ "line_index" ] + 1;
    string = "";
    quote = "";
    escaped_quote = "";

    while context[ "line_index" ] < len( context[ "line_array" ] ):

        parsed_line = parse_def_line( context, level );
        line = parsed_line[ "line" ];
        line_space_count = parsed_line[ "line_space_count" ];

        if context[ "line_index" ] == first_line_index:

            quote = line[ 0 ];
            line = line[ 1: ];
            escaped_quote = "\\" + quote;

        token_array = get_token_array( line );
        last_token = token_array[ len( token_array ) - 1 ] if len( token_array ) > 0 else "";

        if last_token == "\\":

            token_array.pop();

            string += get_unescaped_text( token_array );

        elif last_token.endswith( quote ) and last_token != escaped_quote:

            token_array[ len( token_array ) - 1 ] = last_token[ : len( last_token ) - 1 ];

            string += get_unescaped_text( token_array );

            if quote == context[ "string_processing_quote" ] and context[ "process_quoted_string_function" ] is not None:

                return context[ "process_quoted_string_function" ]( string, context, level );

            else:

                return string;

        else:

            if last_token.endswith( "¨" ) and last_token != "\\¨":

                token_array[ len( token_array ) - 1 ] = last_token[ : len( last_token ) - 1 ];

            string += get_unescaped_text( token_array ) + "\n";

    throw_parsing_error( "Invalid DEF quoted string", context, level );

# ~~

def parse_def_array(
    context,
    level
    ):

    array = [];

    while context[ "line_index" ] < len( context[ "line_array" ] ):

        parsed_line = parse_def_line( context, level );
        line = parsed_line[ "line" ];
        line_space_count = parsed_line[ "line_space_count" ];

        if line_space_count == 0 and line == "]":

            return array;

        elif line_space_count == 0 and line == "]{}":

            if len( array ) == 0:

                return [];

            else:

                if isinstance( array[ 0 ], list ):

                    if len( array ) == 1:

                        return [];

                    else:

                        key_array = [];

                        for key in array[ 0 ]:

                            key_array.append( get_key_text( key ) );

                        key_count = len( key_array );
                        object_array = [];
                        object_count = len( array ) - 1;

                        for object_index in range( object_count ):

                            value_array = array[ object_index + 1 ];

                            if isinstance( value_array, list ) and len( value_array ) == key_count:

                                obj = {};

                                for key_index in range( key_count ):

                                    obj[ key_array[ key_index ] ] = value_array[ key_index ];

                                object_array.append( obj );

                            else:

                                throw_parsing_error( "Invalid DEF object array", context, level );

                        return object_array;
                else:

                    throw_parsing_error( "Invalid DEF object array", context, level );

        elif line_space_count == 0 and line == "]()":

            if len( array ) == 0:

                return [];

            else:

                if isinstance( array[ 0 ], list ):

                    if len( array ) == 1:

                        return [];

                    else:

                        key_array = [];

                        for key in array[ 0 ]:

                            key_array.append( get_key_text( key ) );

                        key_count = len( key_array );
                        map_array = [];
                        map_count = len( array ) - 1;

                        for map_index in range( map_count ):

                            value_array = array[ map_index + 1 ];

                            if isinstance( value_array, list ) and len( value_array ) == key_count:

                                map_value = Map();

                                for key_index in range( key_count ):

                                    map_value.set( key_array[ key_index ], value_array[ key_index ] );

                                map_array.append( map_value );

                            else:

                                throw_parsing_error( "Invalid DEF map array", context, level );

                        return map_array;

                else:

                    throw_parsing_error( "Invalid DEF map array", context, level );

        else:

            context[ "line_index" ] -= 1;

            value = parse_def_value( context, level + 1 );
            array.append( value );

    throw_parsing_error( "Invalid DEF array", context, level );

# ~~

def parse_def_object(
    context,
    level
    ):

    obj = {};

    while context[ "line_index" ] < len( context[ "line_array" ] ):

        parsed_line = parse_def_line( context, level );
        line = parsed_line[ "line" ];
        line_space_count = parsed_line[ "line_space_count" ];

        if line_space_count == 0 and line == "}":

            return obj;

        else:

            context[ "line_index" ] -= 1;

            key = parse_def_value( context, level + 1 );
            value = parse_def_value( context, level + 2 );

            if key is not None and isinstance( key, dict ):

                import json;

                obj[ json.dumps( key ) ] = value;

            else:

                obj[ get_object_key_text( key ) ] = value;

    throw_parsing_error( "Invalid DEF object", context, level );

# ~~

def parse_def_map(
    context,
    level
    ):

    map_value = Map();

    while context[ "line_index" ] < len( context[ "line_array" ] ):

        parsed_line = parse_def_line( context, level );
        line = parsed_line[ "line" ];
        line_space_count = parsed_line[ "line_space_count" ];

        if line_space_count == 0 and line == ")":

            return map_value;

        else:

            context[ "line_index" ] -= 1;

            key = parse_def_value( context, level + 1 );
            value = parse_def_value( context, level + 2 );

            map_value.set( key, value );

    throw_parsing_error( "Invalid DEF map", context, level );

# ~~

def parse_def_value(
    context,
    level
    ):

    if context[ "line_index" ] < len( context[ "line_array" ] ):

        parsed_line = parse_def_line( context, level );
        line = parsed_line[ "line" ];
        line_space_count = parsed_line[ "line_space_count" ];

        if line == "[":

            return parse_def_array( context, level );

        elif line == "{":

            return parse_def_object( context, level );

        elif line == "(":

            return parse_def_map( context, level );

        elif (
            line.startswith( "'" )
            or line.startswith( '"' )
            or line.startswith( "`" )
            or line.startswith( "´" )
            ):

            context[ "line_index" ] -= 1;

            return parse_def_quoted_string( context, level );

        else:

            token_array = get_token_array( line );

            if len( token_array ) == 1 and token_array[ 0 ] == line.strip():

                if line == "undefined":

                    return undefined;

                elif line == "null":

                    return None;

                elif line == "false":

                    return False;

                elif line == "true":

                    return True;

                elif line == "NaN":

                    return float( "nan" );

                elif line == "-Infinity":

                    return float( "-inf" );

                elif line == "Infinity":

                    return float( "inf" );

                elif hexadecimal_integer_expression.match( line ):

                    try:

                        return int( line, 0 );

                    except ValueError:

                        pass;

                elif decimal_real_expression.match( line ) or exponential_decimal_real_expression.match( line ):

                    try:

                        number = float( line );

                        if number == int( number ):

                            return int( number );
                        else:

                            return number;

                    except ValueError:

                        pass;

            context[ "line_index" ] -= 1;

            return parse_def_unquoted_string( context, level );

    else:

        throw_parsing_error( "Invalid DEF value", context, level );

# ~~

def parse_def_text(
    text,
    options=None
    ):

    if options is None:

        options = {};

    base_folder_path = options.get( "base_folder_path", "" );
    file_path = options.get( "file_path", "" );
    read_text_file_function = options.get( "read_text_file_function", None );
    string_processing_quote = options.get( "string_processing_quote", "'" );
    process_quoted_string_function = options.get( "process_quoted_string_function", process_def_quoted_string );
    level_space_count = options.get( "level_space_count", 4 );

    line_array = (
        text.rstrip()
        .replace( "\t", " " * level_space_count )
        .replace( "\r", "" )
        .split( "\n" )
        );

    context = {
        "base_folder_path": base_folder_path,
        "file_path": file_path,
        "read_text_file_function": read_text_file_function,
        "string_processing_quote": string_processing_quote,
        "process_quoted_string_function": process_quoted_string_function,
        "level_space_count": level_space_count,
        "text": text,
        "line_array": line_array,
        "line_index": 0
        };

    return parse_def_value( context, 0 );
