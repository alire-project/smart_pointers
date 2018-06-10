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
-- Copyright (c) 2011, 2016 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

package body Generic_Smart_Pointers.Generic_Definite_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   2.1
  -- Date      15 May 2016
  --====================================================================
  --
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    2.1  15.05.2016 Create added
  --  C.G.    2.0  14.05.2016 Smart_Pointers made generic
  --  C.G.    1.1  22.06.2011 Added Free
  --  C.G.    1.0  03.05.2011 Created
  --====================================================================

  overriding procedure Free (Data: in out T_Client_Data) is
  begin
    Free (Data.Data);
  end Free;

  function Create (Data: in T) return Smart_Pointer is
  begin
    return (P => Create (T_Client_Data'(Client_Data with Data)));
  end Create;

  procedure Set (Self: in out Smart_Pointer; Data: in T) is
  begin
    Set (Self.P, T_Client_Data'(Client_Data with Data));
  end Set;

  procedure Free is new Ada.Unchecked_Deallocation (Generic_Smart_Pointers.Accessor, Accessor_Ptr);

  procedure Finalize (Self: in out Accessor) is
  begin
    Free (Self.A);
  end Finalize;

  function Get (Self: Smart_Pointer) return Accessor is
  begin
    if Self.P.Pointer = null then
      return Accessor'(Ada.Finalization.Limited_Controlled with Data => null, A => <>);
    else
      return Accessor'(Ada.Finalization.Limited_Controlled with
                       Data => T_Client_Data (Get (Self.P).Data.all).Data'Access,
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

end Generic_Smart_Pointers.Generic_Definite_Pointers;
