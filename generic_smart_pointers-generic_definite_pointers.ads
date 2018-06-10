-- ---------------------------------------------------------------------
-- This software is provided as is in the hope that it might be found
-- useful.
-- You may use and modify it freely provided you keep this copyright
-- notice unchanged and mark modifications appropriately.
--
-- Bug reports and proposals for improvements are welcome. Please send
-- them to the eMail address below.
--
-- Christoph Karl Walter Grein
-- Hauptstr. 42
-- D-86926 Greifenberg
-- Germany
--
-- eMail:    Christ-Usch.Grein@T-Online.de
-- Internet: http://www.christ-usch-grein.homepage.t-online.de/
--
-- Copyright (c) 2011, 2012, 2016 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

generic

  type T is private;

  with procedure Free (Data: in out T) is null;  -- only for internal use

package Generic_Smart_Pointers.Generic_Definite_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   3.1
  -- Date      15 May 2016
  --====================================================================
  -- Like Smart_Pointers, but can hold only objects of type T.
  -- The generic parameter procedure Free should be supplied only if
  -- T holds components that need to be freed when an object of T is
  -- freed.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    3.1  15.05.2016 Create added
  --  C.G.    3.0  14.05.2016 Smart_Pointers made generic
  --  C.G.    2.1  16.02.2012 RO_Accessor added (commented)
  --  C.G.    2.0  09.07.2011 Ada 2012: implicit dereference
  --  C.G.    1.1  22.06.2011 Added Free
  --  C.G.    1.0  03.05.2011 Created
  --====================================================================

  --type RO_Accessor (Data: access constant T) is limited private
  --  with Implicit_Dereference => Data;
  type Accessor (Data: access T) is limited private
    with Implicit_Dereference => Data;

  type Smart_Pointer is private;

  function Create (Data: in T) return Smart_Pointer;

  procedure Set (Self: in out Smart_Pointer; Data: in T);
  --function  Get (Self: Smart_Pointer) return RO_Accessor;
  function  Get (Self: Smart_Pointer) return Accessor;

  procedure Unset (Self: in out Smart_Pointer);

  function is_Null (Self: Smart_Pointer) return Boolean;

private

  type T_Client_Data is new Client_Data with record
    Data: aliased T;
  end record;

  overriding procedure Free (Data: in out T_Client_Data);

  type Smart_Pointer is record
    P: Generic_Smart_Pointers.Smart_Pointer;
  end record;

  -- Smart_Pointers.Accessor is limited so we must use a pointer to allocate
  -- and deallocate when going out of scope.

  type Accessor_Ptr is access Generic_Smart_Pointers.Accessor;

  --type RO_Accessor (Data: access constant T) is new Ada.Finalization.Limited_Controlled with record
  --  A: Accessor_Ptr;
  --end record;
  type Accessor (Data: access T) is new Ada.Finalization.Limited_Controlled with record
    A: Accessor_Ptr;
  end record;

  overriding procedure Finalize (Self: in out Accessor);

end Generic_Smart_Pointers.Generic_Definite_Pointers;
