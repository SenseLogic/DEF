# -- IMPORTS

import re;

from .constant import undefined;
from .map import Map;

# -- CONSTANTS

decimal_real_expression = re.compile( r"^-?\d+(\.\d+)?$" );
exponential_decimal_real_expression = re.compile( r"^-?\d+(\.\d+)?[eE][-+]?\d+$" );
hexadecimal_integer_expression = re.compile( r"^0x[0-9A-Fa-f]+$" );

# -- FUNCTIONS

def build_def_string(
    value,
    context,
    level
    ):

    indent = " " * ( level * context[ "level_space_count" ] );

    if value == "":

        context[ "line_array" ].append( indent + "¨" );

    elif (
        value == "["
        or value == "{"
        or value == "("
        or value == "undefined"
        or value == "null"
        or value == "false"
        or value == "true"
        or value == "NaN"
        or value == "-Infinity"
        or value == "Infinity"
        or hexadecimal_integer_expression.match( value )
        or decimal_real_expression.match( value )
        or exponential_decimal_real_expression.match( value )
        ):

        context[ "line_array" ].append( indent + value + "¨" );

    else:

        line_array = value.split( "\n" );
        line_count = len( line_array );
        quote = None;

        if line_count == 1:

            quote = "";

        else:

            quote = context[ "quote" ];

        for line_index in range( line_count ):

            line = (
                line_array[ line_index ]
                .replace( "\\", "\\\\" )
                .replace( "\b", "\\b" )
                .replace( "\f", "\\f" )
                .replace( "\r", "\\r" )
                .replace( "\t", "\\t" )
                .replace( "\v", "\\v" )
            );

            if line_count == 1:

                if (
                    line.startswith( "'" )
                    or line.startswith( '"' )
                    or line.startswith( "`" )
                    or line.startswith( "´" )
                ):

                    line = "\\" + line;

                if line.endswith( " " ):

                    line += "¨";
                elif line.endswith( "¨" ):

                    line = line[ :-1 ] + "\\¨";
            else:

                if line_index == 0:

                    line = quote + line;

                if line_index > 0 and line_index < line_count - 1:

                    if line.endswith( quote ):

                        line = line[ :-1 ] + "\\" + quote;

                if line_index == line_count - 1:

                    line += quote;
                elif line.endswith( " " ):

                    line += "¨";
                elif line.endswith( "¨" ):

                    line = line[ :-1 ] + "\\¨";

            context[ "line_array" ].append( indent + line );

# ~~

def build_def_value(
    value,
    context,
    level
    ):

    indent = " " * ( level * context[ "level_space_count" ] );

    if value is undefined:

        context[ "line_array" ].append( indent + "undefined" );

    elif value is None:

        context[ "line_array" ].append( indent + "null" );

    elif value is True or value is False:

        context[ "line_array" ].append( indent + str( value ).lower() );

    elif isinstance( value, float ) and value != value:

        context[ "line_array" ].append( indent + "NaN" );

    elif isinstance( value, float ) and value == float( "inf" ):

        context[ "line_array" ].append( indent + "Infinity" );

    elif isinstance( value, float ) and value == float( "-inf" ):

        context[ "line_array" ].append( indent + "-Infinity" );

    elif isinstance( value, ( int, float ) ):

        context[ "line_array" ].append( indent + str( value ) );

    elif isinstance( value, str ):

        build_def_string( value, context, level );

    elif isinstance( value, list ):

        context[ "line_array" ].append( indent + "[" );

        for item in value:

            build_def_value( item, context, level + 1 );

        context[ "line_array" ].append( indent + "]" );

    elif isinstance( value, Map ):

        context[ "line_array" ].append( indent + "(" );

        for key, val in value.entries():

            build_def_value( key, context, level + 1 );
            build_def_value( val, context, level + 2 );

        context[ "line_array" ].append( indent + ")" );

    elif isinstance( value, dict ):

        context[ "line_array" ].append( indent + "{" );

        for key in value:

            build_def_string( key, context, level + 1 );
            build_def_value( value[ key ], context, level + 2 );

        context[ "line_array" ].append( indent + "}" );

    elif value is ...:

        context[ "line_array" ].append( indent + "undefined" );

# ~~

def build_def_text(
    value,
    options=None
    ):

    if options is None:

        options = {};

    level_space_count = options.get( "level_space_count", 4 );
    quote = options.get( "quote", "´" );

    context = {
        "level_space_count": level_space_count,
        "quote": quote,
        "line_array": []
        };

    build_def_value( value, context, 0 );

    return "\n".join( context[ "line_array" ] );
