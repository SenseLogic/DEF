# -- IMPORTS

from .constant import undefined;
from .map import Map;

# -- FUNCTIONS

def get_dump_text(
    value,
    level=0,
    level_space_count=2
    ):

    if value is undefined:

        return "undefined";

    elif value is None:

        return "null";

    elif isinstance( value, bool ) or isinstance( value, ( int, float ) ):

        if isinstance( value, bool ):

            return "true" if value else "false";

        elif isinstance( value, float ) and value != value:

            return "NaN";

        elif isinstance( value, float ) and value == float( "inf" ):

            return "Infinity";

        elif isinstance( value, float ) and value == float( "-inf" ):

            return "-Infinity";

        else:

            return str( value );

    elif isinstance( value, str ):

        import json;

        return json.dumps( value );

    elif isinstance( value, list ):

        if len( value ) == 0:

            return "[]";

        else:

            text = "[\n";
            indent = " " * ( ( level + 1 ) * level_space_count );

            for item in value:

                text += (
                    indent
                    + get_dump_text( item, level + 1, level_space_count )
                    + ",\n"
                );

            text = text[ : len( text ) - 2 ] + "\n";
            text += " " * ( level * level_space_count ) + "]";

            return text;

    elif isinstance( value, Map ):

        if value.size == 0:

            return "Map(0) {}";

        else:

            text = "Map(" + str( value.size ) + ") {\n";
            indent = " " * ( ( level + 1 ) * level_space_count );

            for entry_key, entry_value in value.entries():

                text += (
                    indent
                    + get_dump_text( entry_key, level + 1, level_space_count )
                    + " => "
                    + get_dump_text( entry_value, level + 1, level_space_count )
                    + ",\n"
                );

            text = text[ : len( text ) - 2 ] + "\n";
            text += " " * ( level * level_space_count ) + "}";

            return text;

    elif isinstance( value, dict ):

        if len( value.keys() ) == 0:

            return "{}";

        else:

            text = "{\n";
            indent = " " * ( ( level + 1 ) * level_space_count );

            for key in value:

                text += (
                    indent
                    + __import__( "json" ).dumps( key )
                    + ": "
                    + get_dump_text( value[ key ], level + 1, level_space_count )
                    + ",\n"
                );

            text = text[ : len( text ) - 2 ] + "\n";
            text += " " * ( level * level_space_count ) + "}";

            return text;

    else:

        return str( value );
