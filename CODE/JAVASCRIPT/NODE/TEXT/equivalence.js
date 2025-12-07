// -- CONSTANTS

export function haveSameValue(
    firstValue,
    secondValue
    )
{
    if ( firstValue !== firstValue
         && secondValue !== secondValue )    // NaN
    {
        return true;
    }
    else if ( firstValue === secondValue )
    {
        return true;
    }
    else if ( firstValue == null
              || secondValue == null )
    {
        return firstValue === secondValue;
    }
    else if ( firstValue instanceof Map
              && secondValue instanceof Map )
    {
        if ( firstValue.size !== secondValue.size )
        {
            return false;
        }
        else
        {
            for ( let [ firstValueKey, firstValueValue ] of firstValue.entries() )
            {
                let entryWasFound = false;

                for ( let [ secondValueKey, secondValueValue ] of secondValue.entries() )
                {
                    if ( haveSameValue( firstValueKey, secondValueKey )
                         && haveSameValue( firstValueValue, secondValueValue ) )
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
        }

        return true;
    }
    else if ( Array.isArray( firstValue )
              && Array.isArray( secondValue ) )
    {
        if ( firstValue.length !== secondValue.length )
        {
            return false;
        }

        for ( let valueIndex = 0;
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
    else if ( typeof firstValue === 'object'
              && typeof secondValue === 'object' )
    {
        let firstValueKeyArray = Object.keys( firstValue );
        let secondValueKeyArray = Object.keys( secondValue );

        if ( firstValueKeyArray.length !== secondValueKeyArray.length )
        {
            return false;
        }

        for ( let key of firstValueKeyArray )
        {
            if ( !Object.prototype.hasOwnProperty.call( secondValue, key )
                 || !haveSameValue( firstValue[ key ], secondValue[ key ] ) )
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
