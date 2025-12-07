// -- FUNCTIONS

bool haveSameValue(
    dynamic firstValue,
    dynamic secondValue
    )
{
    if ( firstValue != firstValue
         && secondValue != secondValue )    // NaN
    {
        return true;
    }
    else if ( firstValue == secondValue )
    {
        return true;
    }
    else if ( firstValue == null
              || secondValue == null )
    {
        return firstValue == secondValue;
    }
    else if ( firstValue is Map<String, dynamic>
              && secondValue is Map<String, dynamic> )
    {
        var firstValueKeyArray = firstValue.keys.toList();
        var secondValueKeyArray = secondValue.keys.toList();

        if ( firstValueKeyArray.length != secondValueKeyArray.length )
        {
            return false;
        }

        for ( var key in firstValueKeyArray )
        {
            if ( !secondValue.containsKey( key )
                 || !haveSameValue( firstValue[ key ], secondValue[ key ] ) )
            {
                return false;
            }
        }

        return true;
    }
    else if ( firstValue is Map<dynamic, dynamic>
              && secondValue is Map<dynamic, dynamic> )
    {
        if ( firstValue.length != secondValue.length )
        {
            return false;
        }
        else
        {
            for ( var firstValueEntry in firstValue.entries )
            {
                var entryWasFound = false;

                for ( var secondValueEntry in secondValue.entries )
                {
                    if ( haveSameValue( firstValueEntry.key, secondValueEntry.key )
                         && haveSameValue( firstValueEntry.value, secondValueEntry.value ) )
                    {
                        entryWasFound = true;

                        break;
                    }
                }

                if ( !entryWasFound )
                {
                    return false;
                }
            }

            return true;
        }
    }
    else if ( firstValue is List
              && secondValue is List )
    {
        if ( firstValue.length != secondValue.length )
        {
            return false;
        }

        for ( int valueIndex = 0;
              valueIndex < firstValue.length;
              ++valueIndex )
        {
            if ( !haveSameValue( firstValue[ valueIndex ], secondValue[ valueIndex ] ) )
            {
                return false;
            }
        }

        return true;
    }
    else
    {
        return false;
    }
}
