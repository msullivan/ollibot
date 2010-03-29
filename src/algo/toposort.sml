functor TopoSort (Key : ORD_KEY) :> TOPOSORT where type member = Key.ord_key =
struct

    structure Map = SplayMapFn(Key)

    type member = Key.ord_key
    datatype constraint = 
         HARD of member * member
       | SOFT of member * member    
    type result = int Map.map

    exception TopoSort of member * member

    val constraint_lt = HARD
    val constraint_leq = SOFT

    val sort = 
        foldr (fn (HARD (a,b), map) => Map.insert(Map.insert(map,a,1),b,1)
                | (SOFT (a,b), map) => Map.insert(Map.insert(map,a,1),b,1))
              Map.empty

    val get_all = Map.listItemsi
    val get = Map.lookup

end
