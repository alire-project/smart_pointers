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

  type T (<>) is private;

  with function Deep_Copy (Data: T) return T;    -- only for ...
  with procedure Free (Data: in out T) is null;  -- ... internal use

package Generic_Smart_Pointers.Generic_Indefinite_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   3.0
  -- Date      16 May 2016
  --====================================================================
  -- Like Smart_Pointers, but can hold only objects of type T.
  --
  -- If there is no level of indirection in T, Deep_Copy is just the
  -- identity operation.
  -- Free will be called when the object is finalized; if there is a
  -- level of indirection, it has to clean up.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    3.0  16.05.2016 Made generic
  --  C.G.    2.0  29.06.2012 Ada 2012: implicit dereference;
  --                          bug fix: added Deep_Copy
  --  C.G.    1.1  01.07.2011 Added Free
  --  C.G.    1.0  03.05.2011 Created
  --====================================================================

  type Accessor (Data: access T) is limited private
    with Implicit_Dereference => Data;

  type Smart_Pointer is private;

  function Create (Data: in T) return Smart_Pointer;

  procedure Set (Self: in out Smart_Pointer; Data: in T);
  function  Get (Self: Smart_Pointer) return Accessor;

  procedure Unset (Self: in out Smart_Pointer);

  function is_Null (Self: Smart_Pointer) return Boolean;

private

  -- T is indefinite, so we need an access type to allocate a copy,
  -- which must be controlled so that it is freed when being finalized.

  type Acc_T is access T;

  type Fin_T is new Ada.Finalization.Controlled with record
    T: Acc_T;
  end record;

  overriding procedure Adjust   (X: in out Fin_T);
  overriding procedure Finalize (X: in out Fin_T);

  type T_Client_Data is new Client_Data with record
    Data: Fin_T;
  end record;

  type Smart_Pointer is record
    P: Generic_Smart_Pointers.Smart_Pointer;
  end record;

  -- Generic_Smart_Pointers.Accessor is unconstrained so we must use an access
  -- type to allocate and deallocate when going out of scope.

  type Accessor_Ptr is access Generic_Smart_Pointers.Accessor;

  type Accessor (Data: access T) is new Ada.Finalization.Limited_Controlled with record
    A: Accessor_Ptr;
  end record;

  overriding procedure Finalize (Self: in out Accessor);

end Generic_Smart_Pointers.Generic_Indefinite_Pointers;
