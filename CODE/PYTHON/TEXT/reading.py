# -- IMPORTS

import os;
import re;
from functools import cmp_to_key;

from .parsing import parse_def_text;
from .processing import (
    get_natural_text_comparison,
    process_def_quoted_string,
    );

# -- FUNCTIONS

def get_imported_path(
    trimmed_line
    ):

    if trimmed_line.startswith( "'@" ) and trimmed_line.endswith( "'" ):

        return trimmed_line[ 2:-1 ];

    else:

        return "";

# ~~

def get_imported_file_path_array(
    imported_file_filter
    ):

    return get_def_file_path_array( imported_file_filter );

# ~~

def get_physical_file_path(
    file_path,
    base_folder_path=""
    ):

    return os.path.join( base_folder_path, file_path );

# ~~

def read_text_file(
    file_path,
    base_folder_path=""
    ):

    try:

        with open( get_physical_file_path( file_path, base_folder_path ), "r", encoding="utf8" ) as file:

            return file.read();

    except Exception as error:

        print( error );
        raise;

# ~~

def get_def_folder_path(
    file_path
    ):

    return file_path[ : file_path.rfind( "/" ) + 1 ];

# ~~

def get_def_file_path_array(
    file_filter
    ):

    file_filter = file_filter;
    folder_path = get_def_folder_path( file_filter );
    file_filter = file_filter[ len( folder_path ) : ];

    if file_filter == "":

        file_filter = "^.*\\.def$";

    else:

        file_filter = (
            "^"
            + file_filter
                .replace( ".", "\\." )
                .replace( "*", ".*" )
                .replace( "?", "." )
                .replace( "[", "\\[" )
                .replace( "]", "\\]" )
                .replace( "(", "\\(" )
                .replace( ")", "\\)" )
                .replace( "{", "\\{" )
                .replace( "}", "\\}" )
                .replace( "|", "\\|" )
                .replace( "^", "\\^" )
                .replace( "$", "\\$" )
                .replace( "+", "\\+" )
                .replace( "-", "\\-" )
            + "$"
            );

    file_name_regular_expression = re.compile( file_filter );
    file_path_array = [];

    try:

        for file_name in os.listdir( folder_path ):

            if file_name_regular_expression.match( file_name ):

                file_path_array.append( folder_path + file_name.replace( "\\", "/" ) );

    except Exception as error:

        print( error );
        raise;

    file_path_array.sort(
        key=cmp_to_key( lambda first_file_path, second_file_path: get_natural_text_comparison( first_file_path, second_file_path ) )
        );

    return file_path_array;

# ~~

def process_def_file_text(
    file_text,
    options=None
    ):

    if options is None:

        options = {};

    base_folder_path = options.get( "base_folder_path", "" );
    file_path = options.get( "file_path", "" );
    read_text_file_function = options.get( "read_text_file_function", read_text_file );
    has_import_commands = options.get( "has_import_commands", True );
    get_imported_path_function = options.get( "get_imported_path_function", get_imported_path );
    get_imported_file_path_array_function = options.get( "get_imported_file_path_array_function", get_imported_file_path_array );

    if has_import_commands:

        folder_path = file_path[ : file_path.rfind( "/" ) + 1 ];
        line_array = file_text.split( "\n" );

        line_index = 0;

        while line_index < len( line_array ):

            line = line_array[ line_index ];
            trimmed_line = line.strip();
            imported_file_filter = get_imported_path_function( trimmed_line );

            if len( imported_file_filter ) > 0:

                line_array.pop( line_index );
                imported_file_path_array = get_imported_file_path_array_function( folder_path + imported_file_filter );

                for imported_file_path in imported_file_path_array:

                    imported_file_text = read_def_file_text(
                        imported_file_path,
                        {
                            "base_folder_path": base_folder_path,
                            "read_text_file_function": read_text_file_function,
                            "has_import_commands": has_import_commands,
                            "get_imported_path_function": get_imported_path_function,
                            "get_imported_file_path_array_function": get_imported_file_path_array_function,
                        }
                        );

                    indentation = line[ : len( line ) - len( line.lstrip() ) ];
                    indented_line_array = imported_file_text.split( "\n" );

                    for indented_line_index in range( len( indented_line_array ) ):

                        indented_line_array[ indented_line_index ] = indentation + indented_line_array[ indented_line_index ];

                    line_array[ line_index:line_index ] = indented_line_array;
                    line_index += len( indented_line_array );

                line_index -= 1;

            line_index += 1;

        file_text = "\n".join( line_array );

    return file_text;

# ~~

def parse_def_file_text(
    file_text,
    options=None
    ):

    if options is None:

        options = {};

    base_folder_path = options.get( "base_folder_path", "" );
    file_path = options.get( "file_path", "" );
    read_text_file_function = options.get( "read_text_file_function", read_text_file );
    has_import_commands = options.get( "has_import_commands", True );
    get_imported_path_function = options.get( "get_imported_path_function", get_imported_path );
    get_imported_file_path_array_function = options.get( "get_imported_file_path_array_function", get_imported_file_path_array );
    string_processing_quote = options.get( "string_processing_quote", "'" );
    process_quoted_string_function = options.get( "process_quoted_string_function", process_def_quoted_string );
    level_space_count = options.get( "level_space_count", 4 );

    if has_import_commands:

        file_text = process_def_file_text(
            file_text,
            {
                "base_folder_path": base_folder_path,
                "file_path": file_path,
                "read_text_file_function": read_text_file_function,
                "has_import_commands": has_import_commands,
                "get_imported_path_function": get_imported_path_function,
                "get_imported_file_path_array_function": get_imported_file_path_array_function,
            }
            );

    return parse_def_text(
        file_text,
        {
            "base_folder_path": base_folder_path,
            "file_path": file_path,
            "read_text_file_function": read_text_file_function,
            "string_processing_quote": string_processing_quote,
            "process_quoted_string_function": process_quoted_string_function,
            "level_space_count": level_space_count,
        }
        );

# ~~

def read_def_file_text(
    file_path,
    options=None
    ):

    if options is None:

        options = {};

    base_folder_path = options.get( "base_folder_path", "" );
    read_text_file_function = options.get( "read_text_file_function", read_text_file );
    has_import_commands = options.get( "has_import_commands", True );
    get_imported_path_function = options.get( "get_imported_path_function", get_imported_path );
    get_imported_file_path_array_function = options.get( "get_imported_file_path_array_function", get_imported_file_path_array );

    file_text = read_text_file_function( file_path, base_folder_path ).rstrip();

    if has_import_commands:

        file_text = process_def_file_text(
            file_text,
            {
                "base_folder_path": base_folder_path,
                "file_path": file_path,
                "read_text_file_function": read_text_file_function,
                "has_import_commands": has_import_commands,
                "get_imported_path_function": get_imported_path_function,
                "get_imported_file_path_array_function": get_imported_file_path_array_function,
            }
            );

    return file_text;

# ~~

def read_def_file(
    file_path,
    options=None
    ):

    if options is None:

        options = {};

    base_folder_path = options.get( "base_folder_path", "" );
    read_text_file_function = options.get( "read_text_file_function", read_text_file );
    string_processing_quote = options.get( "string_processing_quote", "'" );
    process_quoted_string_function = options.get( "process_quoted_string_function", process_def_quoted_string );
    level_space_count = options.get( "level_space_count", 4 );
    has_import_commands = options.get( "has_import_commands", True );
    get_imported_path_function = options.get( "get_imported_path_function", get_imported_path );
    get_imported_file_path_array_function = options.get( "get_imported_file_path_array_function", get_imported_file_path_array );

    text = read_def_file_text(
        file_path,
        {
            "base_folder_path": base_folder_path,
            "read_text_file_function": read_text_file_function,
            "has_import_commands": has_import_commands,
            "get_imported_path_function": get_imported_path_function,
            "get_imported_file_path_array_function": get_imported_file_path_array_function,
        }
        );

    return parse_def_text(
        text,
        {
            "base_folder_path": base_folder_path,
            "file_path": file_path,
            "read_text_file_function": read_text_file_function,
            "string_processing_quote": string_processing_quote,
            "process_quoted_string_function": process_quoted_string_function,
            "level_space_count": level_space_count,
        }
        );

# ~~

def read_def_files(
    path_array,
    options=None
    ):

    if options is None:

        options = {};

    base_folder_path = options.get( "base_folder_path", "" );
    file_path = options.get( "file_path", "" );
    read_text_file_function = options.get( "read_text_file_function", read_text_file );
    string_processing_quote = options.get( "string_processing_quote", "'" );
    process_quoted_string_function = options.get( "process_quoted_string_function", process_def_quoted_string );
    level_space_count = options.get( "level_space_count", 4 );
    has_import_commands = options.get( "has_import_commands", True );
    get_imported_path_function = options.get( "get_imported_path_function", get_imported_path );
    get_imported_file_path_array_function = options.get( "get_imported_file_path_array_function", get_imported_file_path_array );

    script_folder_path = get_def_folder_path( file_path );
    value_array = [];

    for path in path_array:

        if path.endswith( "/" ) or "*" in path or "?" in path:

            folder_file_path_array = get_def_file_path_array( script_folder_path + path );

            for folder_file_path in folder_file_path_array:

                value_array.append(
                    read_def_file(
                        folder_file_path,
                        {
                            "base_folder_path": base_folder_path,
                            "read_text_file_function": read_text_file_function,
                            "string_processing_quote": string_processing_quote,
                            "process_quoted_string_function": process_quoted_string_function,
                            "level_space_count": level_space_count,
                            "has_import_commands": has_import_commands,
                            "get_imported_path_function": get_imported_path_function,
                            "get_imported_file_path_array_function": get_imported_file_path_array_function,
                        }
                        )
                    );

        else:

            value = read_def_file(
                script_folder_path + path,
                {
                    "base_folder_path": base_folder_path,
                    "read_text_file_function": read_text_file_function,
                    "string_processing_quote": string_processing_quote,
                    "process_quoted_string_function": process_quoted_string_function,
                    "level_space_count": level_space_count,
                    "has_import_commands": has_import_commands,
                    "get_imported_path_function": get_imported_path_function,
                    "get_imported_file_path_array_function": get_imported_file_path_array_function,
                }
                );

            if len( path_array ) == 1:

                return value;

            else:

                value_array.append( value );

    return value_array;

# -- EXPORTS

__all__ = [
    "get_imported_path",
    "get_imported_file_path_array",
    "get_physical_file_path",
    "read_text_file",
    "get_def_folder_path",
    "get_def_file_path_array",
    "process_def_file_text",
    "parse_def_file_text",
    "read_def_file_text",
    "read_def_file",
    "read_def_files",
    ];
