# -- IMPORTS

from .constant import undefined;
from .map import Map;

# -- FUNCTIONS

def have_same_value(
    first_value,
    second_value
    ):

    if isinstance( first_value, float ) and isinstance( second_value, float ):

        if first_value != first_value and second_value != second_value:

            return True;

    if first_value == second_value:

        return True;

    elif first_value is None or second_value is None:

        return first_value is second_value;

    elif first_value is undefined or second_value is undefined:

        return first_value is second_value;

    elif isinstance( first_value, Map ) and isinstance( second_value, Map ):

        if first_value.size != second_value.size:

            return False;

        else:

            for first_value_key, first_value_value in first_value.entries():

                entry_was_found = False;

                for second_value_key, second_value_value in second_value.entries():

                    if have_same_value( first_value_key, second_value_key ) and have_same_value(
                        first_value_value, second_value_value
                    ):

                        entry_was_found = True;

                        break;

                if not entry_was_found:

                    return False;

        return True;

    elif isinstance( first_value, list ) and isinstance( second_value, list ):

        if len( first_value ) != len( second_value ):

            return False;

        for value_index in range( len( first_value ) ):

            if not have_same_value( first_value[ value_index ], second_value[ value_index ] ):

                return False;

        return True;

    elif isinstance( first_value, dict ) and isinstance( second_value, dict ):

        first_value_key_array = list( first_value.keys() );
        second_value_key_array = list( second_value.keys() );

        if len( first_value_key_array ) != len( second_value_key_array ):

            return False;

        for key in first_value_key_array:

            if key not in second_value or not have_same_value( first_value[ key ], second_value[ key ] ):

                return False;

        return True;

    else:

        return False;
