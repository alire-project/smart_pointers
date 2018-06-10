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

private with Ada.Finalization;
with Generic_Counters;

generic

  with package Counters is new Generic_Counters (<>);

package Generic_Smart_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   4.0
  -- Date      13 February 2018
  --====================================================================
  -- A reference counted access type Smart_Pointer:
  -- References to allocated data item are counted. Allocations are
  -- automatically reclaimed when no more references exist.
  -- Override Free when your extension of Client_Data contains
  -- components that need to be reclaimed as well.
  --
  -- Create creates a new smart pointer and allocates the data given.
  --
  -- Set allocates a new data item.
  --
  -- Get returns an accessor to the current data item. Its discriminant
  -- can be used to read and write data (null if there is none), but
  -- cannot be used for deallocation, nor can it become dangling.
  --
  -- Unset severs the connection to the data item.
  --
  -- is_Null returns True if its parameter is a null pointer.
  -- (is_Null (P) returns the same value as Get (P).Data = null.)
  --
  -- There are two variants:
  -- Instantiate Generic_Counters with Simple_Counters for sequential
  -- use; with Safe_Counters for task safe use.
  -- The constant is_Tasksafe indicates which variant is selected.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    4.0  13.02.2018 Counter now generic package parameter
  --  C.G.    3.0  08.02.2018 Make smart pointers optionally tasksafe
  --  C.G.    2.1  15.05.2016 Create added
  --  C.G.    2.0  12.05.2016 Made generic
  --  C.G.    1.1  20.06.2011 Added Free for Client_Data
  --  C.G.    1.0  01.03.2011 Created following AdaCore's Gem #97
  --====================================================================

  type Client_Data is abstract tagged private;

  procedure Free (Data: in out Client_Data) is null;  -- for internal use

  type Accessor (Data: access Client_Data'Class) is limited private;

  ----------------------------------------------------------------------

  type Smart_Pointer is private;

  function Create (Data: in Client_Data'Class) return Smart_Pointer;

  procedure Set (Self: in out Smart_Pointer; Data: in Client_Data'Class);
  function  Get (Self: Smart_Pointer) return Accessor;

  procedure Unset (Self: in out Smart_Pointer);

  function is_Null (Self: Smart_Pointer) return Boolean;

  ----------------------------------------------------------------------

  is_Tasksafe: constant Boolean;

private

  is_Tasksafe: constant Boolean := Counters.is_Tasksafe;

  type Counter_Ptr is access Counters.Counter;

  type Client_Data is abstract tagged record
    Count: Counter_Ptr := new Counters.Counter;  -- the reference count
  end record;

  type Accessor (Data: access Client_Data'Class) is limited record
    Hold: Smart_Pointer;
  end record;

  type Client_Data_Ptr is access Client_Data'Class;

  type Smart_Pointer is new Ada.Finalization.Controlled with record
    Pointer: Client_Data_Ptr;
  end record;

  overriding procedure Adjust   (Self: in out Smart_Pointer);
  overriding procedure Finalize (Self: in out Smart_Pointer);

end Generic_Smart_Pointers;
