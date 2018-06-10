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
-- Copyright (c) 2011, 2012, 2016, 2018 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

with Test_Support;
use  Test_Support;

with Generic_Smart_Pointers.Generic_Definite_Pointers;
with Selected_Counters;

procedure Test_Definite_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   3.1
  -- Date      13 February 2018
  --====================================================================
  -- Test Generic_Definite_Pointers for an instantiation with Integer.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    3.1  13.02.2018 Selected_Counters now generic parameter
  --  C.G.    3.0  15.05.2016 Smart_Pointers now generic
  --  C.G.    2.1  27.06.2012 GNAT bug is fixed in GPL 2012
  --  C.G.    2.0  09.07.2011 Ada 2012
  --  C.G.    1.1  22.06.2011 My_Smart_Definite_Integer_Pointers changed
  --  C.G.    1.0  04.05.2011 Created
  --====================================================================

  package  Smart_Pointers is new Generic_Smart_Pointers (Selected_Counters);

  procedure Free (I: in out Integer);
  package My_Pointers is new Smart_Pointers.Generic_Definite_Pointers (Integer, Free);
  use My_Pointers;

  procedure Free (I: in out Integer) is
    -- Actually unneeded in this case. Just to show that it's called.
  begin
    Put_Line ("Pointer to " & Integer'Image (I) & " freed.");
  end Free;

  P, Q: Smart_Pointer;

begin

  Test_Header (Title       => "Test Definite_Pointers",
               Description => "Instantiate the generic (not on library level).");

  ---

  Test_Step (Title       => "P and Q uninitialized",
             Description => "P and Q must be null");

  Assert (Condition => is_Null (P) and Get (P).Data = null,
          Message   => "P is null");
  Assert (Condition => is_Null (Q) and Get (Q).Data = null,
          Message   => "Q is null");

  ---

  Test_Step (Title       => "Set P",
             Description => "Query P");

  Set (P, Data => -10);

  Assert (Condition => Get (P).Data.all = -10,
          Message   => " the old way");
  Assert (Condition => Get (P) = -10,
          Message   => " the Ada 2012 way");

  ---

  Test_Step (Title       => "Accessor",
             Description => "P gets new object, Accessor object is removed");

  declare
    A: Accessor renames Get (P);
    --A: constant Accessor := Get (P);
  begin
    -- Accessors are limited, so cannot be compared.
    -- Hence this must be the impleicit dereference:
    Assert (Condition => Get (P) = A,
            Message   => "Compare the Ada 2012 way");
    Set (P, Data => 2005);
    Assert (Condition => Get (P) = 2005,
            Message   => "new value");
    Assert (Condition => A = -10,
            Message   => "old value");
  end;
  Put_Line ("Check that Free for -10 has been called");

  ---

  Test_Step (Title       => "Assignment",
             Description => "P and Q access the same object");

  Q := P;
  Assert (Condition => Get (P) = Get (Q),
          Message   => "same value");

  ---

  Test_Step (Title       => "Local block",
             Description => "P, Q and R access the same object;" &
                            " R gets new object and is freed");

  declare
    R: Smart_Pointer := Q;
  begin
    Put_Line ("P = " & Integer'Image (Get (P)));
    Put_Line ("Q = " & Integer'Image (Get (Q)));
    Put_Line ("R = " & Integer'Image (Get (R)));
    R := Create (1815);
  end;
  Put_Line ("Check that Free for 1815 has been called");

  ---

  Test_Step (Title       => "Assign via Q",
             Description => "P and Q access the same object");

  Get (Q).Data.all := 35;  -- the old way
  Assert (Condition => Get (P) = Get (Q).Data.all and Get (P) = 35,
          Message   => "same value");
  Get (Q) := 135;  -- the Ada 2012 way (GNAT GPL 2011 rejects this line, GPL 2012 OK)
  Assert (Condition => Get (P).Data.all = Get (Q) and Get (Q) = 135,
          Message   => "same value");

  ---

  Test_Step (Title       => "Unset Q then P",
             Description => "Check that Free is called after unsetting P");

  Unset (Q);
  Assert (Condition => Get (P) = 135 and is_Null (Q),
          Message   => "not yet freed");

  Unset (P);
  Assert (Condition => is_Null (P),
          Message   => "freed");

  ---

  Test_Result;

end Test_Definite_Pointers;
