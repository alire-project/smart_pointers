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
-- Copyright (c) 2016 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

with Test_Support;
use  Test_Support;

with Generic_Smart_Pointers.Generic_Indefinite_Pointers;
with Selected_Counters;

procedure Test_Class_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   1.1
  -- Date      13 February 2018
  --====================================================================
  -- Test dispatching for Generic_Indefinite_Pointers instantiated for
  -- a classwide type.
  -- One concrete type with a level of indirection, the other plain.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    1.1  13.02.2018 Selected_Counters now generic parameter
  --  C.G.    1.0  16.05.2016 Created
  --====================================================================

  package  Smart_Pointers is new Generic_Smart_Pointers (Selected_Counters);

  package Root is

    type My_Root is interface;

    function Deep_Copy (Data: My_Root'Class) return My_Root'Class;
    procedure Free_Class (Data: in out My_Root'Class);

    function Copy (Data: My_Root) return My_Root is abstract;
    procedure Work (X   : in out My_Root) is abstract;
    procedure Free (Data: in out My_Root) is null;

  end Root;
  use Root;

  package My_Pointers is new Smart_Pointers.Generic_Indefinite_Pointers (My_Root'Class, Deep_Copy, Free_Class);
  use My_Pointers;

  package body Root is

    function Deep_Copy (Data: My_Root'Class) return My_Root'Class is
    begin
      Put_Line ("Deep_Copy called.");
      return Copy (Data);
    end Deep_Copy;

    procedure Free_Class (Data: in out My_Root'Class) is
    begin
      Put_Line ("Free_Class called.");
      Free (Data);
    end Free_Class;

  end Root;

  -- First derived type

  type Integer_Pointer is access Integer;

  type Indirection is new My_Root with record
    Pointer: not null Integer_Pointer;
  end record;
  overriding function Copy (Data: Indirection) return Indirection;
  overriding procedure Work (X   : in out Indirection);
  overriding procedure Free (Data: in out Indirection);

  function Copy (Data: Indirection) return Indirection is
    -- A deep copy is needed here.
    -- Pointer is not null, so dereference cannot fail.
  begin
    Put_Line ("Copy of " & Integer'Image (Data.Pointer.all) & " called.");
    return (My_Root with Pointer => new Integer'(Data.Pointer.all));
  end Copy;

  procedure Work (X: in out Indirection) is
  begin
    Put_Line ("Work for " & Integer'Image (X.Pointer.all) & " called.");
  end Work;

  procedure Free (Data: in out Indirection) is
    procedure UD is new Ada.Unchecked_Deallocation (Integer, Integer_Pointer);
    Kill: Integer_Pointer := Data.Pointer;
  begin
    Put_Line ("Pointer to " & Integer'Image (Data.Pointer.all) & " freed.");
    UD (Kill);
  end Free;

  -- Second derived type

  type No_Indirection is new My_Root with record
    Component: Float;
  end record;
  overriding function Copy (Data: No_Indirection) return No_Indirection;
  overriding procedure Work (X: in out No_Indirection);
  -- Free is inherited as null.

  function Copy (Data: No_Indirection) return No_Indirection is
    -- Identity is sufficient here.
  begin
    Put_Line ("Copy of " & Float'Image (Data.Component) & " called.");
    return Data;
  end Copy;

  procedure Work (X: in out No_Indirection) is
  begin
    Put_Line ("Work for " & Float'Image (X.Component) & " called.");
  end Work;

  --

  P, Q: Smart_Pointer;

begin

  Test_Header (Title       => "Test Indefinite_Pointers for classwide type",
               Description => "Instantiate the generic (not on library level).");

  ---

  Test_Step (Title       => "P and Q uninitialized",
             Description => "P and Q must be null");

  Assert (Condition => is_Null (P) and Get (P).Data = null,
          Message   => "P is null");
  Assert (Condition => is_Null (Q) and Get (Q).Data = null,
          Message   => "Q is null");

  ---

  Test_Step (Title       => "Set P to Integer",
             Description => "Query P");

  Set (P, Data => Indirection'(Pointer => new Integer'(1815)));

  Assert (Condition => Indirection (Get (P).Data.all).Pointer.all = 1815,
          Message   => "Dereference");
  Work (Get (P));

  ---

  Test_Step (Title       => "Set Q to Float",
             Description => "Query Q");

  Set (Q, Data => No_Indirection'(Component => 1815.0));

  Assert (Condition => No_Indirection (Get (Q).Data.all).Component = 1815.0,
          Message   => "Dereference");
  Work (Get (P));

  ---

  Test_Step (Title       => "Accessor",
             Description => "P gets new object, Accessor object is removed");

  declare
    A: Accessor renames Get (P);
  begin
    Assert (Condition => Get (P) = A,
            Message   => "same value");
    Work (Get (P));
    Work (   A   );
    P := Create (Indirection'(Pointer => new Integer'(1983)));
    Assert (Condition => Get (P) /= A,
            Message   => "different values");
  end;
  Put_Line ("Check that Free has been called");

  ---

  Test_Step (Title       => "Assignment",
             Description => "P and Q access the same object");

  Work (Get (Q));
  Q := P;
  Assert (Condition => Get (P) = Get (Q),
          Message   => "same value");
  Work (Get (Q));

  ---

  Test_Step (Title       => "Assign via Q",
             Description => "P and Q access the same object");

  Indirection (Get (Q).Data.all).Pointer.all := 95;
  Assert (Condition => Get (P) = Get (Q),
          Message   => "same value");
  Work (Get (P));

  ---

  Test_Step (Title       => "Deallocate via P",
             Description => "Allocate via Q");

  Work (Get (Q));
  declare
    -- Cannot deallocate via Pointer (is not null).
    D: Integer_Pointer := Indirection (Get (P).Data.all).Pointer;
    procedure UD is new Ada.Unchecked_Deallocation (Integer, Integer_Pointer);
  begin
    Put_Line ("Deallocate " & Integer'Image (D.all));
    UD (D);
  end;
  Put_Line ("Two erroneous dereferences follow:");
  Work (Get (P));  -- erroneous!
  Work (Get (Q));  -- erroneous!
  Assert (Condition => Indirection (Get (P).Data.all).Pointer /= null,
          Message   => "P doesn't know (nor does Q)");
  Indirection (Get (Q).Data.all).Pointer := new Integer'(2005);
  Work (Get (P));

  ---

  Test_Step (Title       => "Unset Q then P",
             Description => "Check that Free is called after unsetting P");

  Work (Get (Q));
  Unset (Q);
  Work (Get (P));
  Assert (Condition => is_Null (Q),
          Message   => "not yet freed");

  Unset (P);
  Assert (Condition => is_Null (P),
          Message   => "freed");

  ---

  Test_Result;

end Test_Class_Pointers;
