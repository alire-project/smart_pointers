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

with Ada.Unchecked_Deallocation;

package body Generic_Smart_Pointers.Generic_Indefinite_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   3.0
  -- Date      16 May 2016
  --====================================================================
  --
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    3.0  16.05.2016 Made generic
  --  C.G.    2.0  29.06.2012 bug fix: added Deep_Copy
  --  C.G.    1.1  01.07.2011 Added Free for type T
  --  C.G.    1.0  05.05.2011 Created
  --====================================================================

  function Create (Data: in T) return Smart_Pointer is
  begin
    return (P => Create (T_Client_Data'(Client_Data with
                                        Fin_T'(Ada.Finalization.Controlled with T => new T'(Data)))));
  end Create;

  procedure Set (Self: in out Smart_Pointer; Data: in T) is
  begin
    Set (Self.P, T_Client_Data'(Client_Data with
                                Fin_T'(Ada.Finalization.Controlled with T => new T'(Data))));
    -- The aggregate will now be finalized, so we need Adjust (see below) to keep
    -- the newly allocated Data. (This is the only place where Adjust will be called.)
  end Set;

  function Get (Self: Smart_Pointer) return Accessor is
  begin
    if Self.P.Pointer = null then
      return Accessor'(Ada.Finalization.Limited_Controlled with Data => null, A => <>);
    else
      return Accessor'(Ada.Finalization.Limited_Controlled with
                       Data => T_Client_Data (Get (Self.P).Data.all).Data.T,
                       A    => new Generic_Smart_Pointers.Accessor'(Get (Self.P)));
    end if;
  end Get;

  procedure Unset (Self: in out Smart_Pointer) is
  begin
    Unset (Self.P);
  end Unset;

  function is_Null (Self: Smart_Pointer) return Boolean is
  begin
    return is_Null (Self.P);
  end is_Null;

  procedure Free is new Ada.Unchecked_Deallocation (T, Acc_T);

  procedure Adjust (X: in out Fin_T) is
    -- See Set above.
  begin
    X.T := new T'(Deep_Copy (X.T.all));
  end Adjust;

  procedure Finalize (X: in out Fin_T) is
  begin
    Free (X.T.all);
    Free (X.T);
  end Finalize;

  procedure Free is new Ada.Unchecked_Deallocation (Generic_Smart_Pointers.Accessor, Accessor_Ptr);

  procedure Finalize (Self: in out Accessor) is
  begin
    Free (Self.A);
  end Finalize;

end Generic_Smart_Pointers.Generic_Indefinite_Pointers;
