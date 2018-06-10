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
-- Copyright (c) 2011, 2016, 2018 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

package body Generic_Smart_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   4.0
  -- Date      13 February 2018
  --====================================================================
  --
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    4.0  13.02.2018 Counter now generic package parameter
  --  C.G.    3.0  08.02.2018 Make smart pointers optionally tasksafe
  --  C.G.    2.1  15.05.2016 Create added
  --  C.G.    2.0  12.05.2016 Made generic
  --  C.G.    1.1  31.05.2011 Code for Get slightly simplified
  --  C.G.    1.0  01.03.2011 Created following AdaCore's Gem #97
  --====================================================================

  procedure Free is new Ada.Unchecked_Deallocation (Client_Data'Class, Client_Data_Ptr);
  procedure Free is new Ada.Unchecked_Deallocation (Counters.Counter , Counter_Ptr);

  procedure Set (Self: in out Smart_Pointer; Data: in Client_Data'Class) is
    -- Note: The aggregate will be finalized, so the initial value of the counter
    --       needs to be 1. And even if the compiler optimizes the aggregate away
    --       and builds in place, the count will then be correct.
  begin
    Self := (Ada.Finalization.Controlled with Pointer => new Client_Data'Class'(Data));
  end Set;

  procedure Unset (Self: in out Smart_Pointer) renames Finalize;

  function Create (Data: in Client_Data'Class) return Smart_Pointer is
  begin
    return (Ada.Finalization.Controlled with Pointer => new Client_Data'Class'(Data));
  end Create;

  function Get (Self: Smart_Pointer) return Accessor is
    -- Store a copy of Self in Hold so that the lifetime of the object
    -- accessed is at least as long as that of Accessor.
  begin
    return Accessor'(Data => Self.Pointer, Hold => Self);
  end Get;

  procedure Adjust (Self: in out Smart_Pointer) is
  begin
    if Self.Pointer /= null then
      Counters.Increase (Self.Pointer.Count.all);
    end if;
  end Adjust;

  procedure Finalize (Self: in out Smart_Pointer) is
    Pointer: Client_Data_Ptr := Self.Pointer;
    is_Zero: Boolean;
  begin
    Self.Pointer := null;  -- idempotence
    if Pointer /= null then
      Counters.Decrease (Pointer.Count.all, is_Zero);
      if is_Zero then
        Free (Pointer.Count);
        Free (Pointer.all);
        Free (Pointer);
      end if;
    end if;
  end Finalize;

  function is_Null (Self: Smart_Pointer) return Boolean is
  begin
    return Self.Pointer = null;
  end is_Null;

end Generic_Smart_Pointers;
