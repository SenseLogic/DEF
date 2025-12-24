# -- TYPES

class Map:

    # -- CONSTRUCTORS

    def __init__(
        self,
        entries=None
        ):

        self._entries = [];

        if entries is not None:

            for key, value in entries:

                self.set( key, value );

    # -- INQUIRIES

    @property
    def size( self ):

        return len( self._entries );

    # ~~

    def entries( self ):

        return list( self._entries );

    # ~~

    def __iter__( self ):

        return iter( self._entries );

    # ~~

    def __len__( self ):

        return len( self._entries );

    # ~~

    def __repr__( self ):

        return f"Map( {self._entries!r} )";

    # -- OPERATIONS

    def set(
        self,
        key,
        value
        ):

        for index, ( entry_key, _ ) in enumerate( self._entries ):

            if entry_key is key:

                self._entries[ index ] = ( key, value );
                return;

        self._entries.append( ( key, value ) );
