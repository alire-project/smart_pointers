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

with Generic_Smart_Pointers.Generic_Indefinite_Pointers;
with Selected_Counters;

procedure Test_Indefinite_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   3.1
  -- Date      13 February 2018
  --====================================================================
  -- Test Generic_Indefinite_Pointers for an instantiation with String.
  -- String objects allocated are deallocated internally.
  -- Deep_Copy is a normal copy; a truely deep copy and Free would only
  -- be needed if there were a further indirection in the actual generic
  -- type.
  -- (The test algorithm is the same as in Test_Definite_Pointers.)
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    3.1  13.02.2018 Selected_Counters now generic parameter
  --  C.G.    3.0  16.05.2016 Smart_Pointers now generic
  --  C.G.    2.0  28.06.2012 Ada 2012
  --  C.G.    1.1  05.07.2011 My_Smart_Indefinite_String_Pointers chgd.
  --  C.G.    1.0  04.05.2011 Created
  --====================================================================

  package  Smart_Pointers is new Generic_Smart_Pointers (Selected_Counters);

  function Deep_Copy (Data: String) return String;
  procedure Free (Data: in out String);
  package My_Pointers is new Smart_Pointers.Generic_Indefinite_Pointers (String, Deep_Copy, Free);
  use My_Pointers;

  function Deep_Copy (Data: String) return String is
    -- Identity operation in this case.
  begin
    Put_Line ("Deep_Copy of " & Data & " called.");  -- Just to show that it's called.
    return Data;
  end Deep_Copy;

  procedure Free (Data: in out String) is
    -- Actually unneeded in this case. Just to show that it's called.
  begin
    Put_Line ("Pointer to " & Data & " freed.");
  end Free;

  P, Q: Smart_Pointer;

begin

  Test_Header (Title       => "Test Indefinite_Pointers",
               Description => "Instantiate the generic for string;" &
                              " no nested indirection.");

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

  Set (P, Data => "Lady Ada");

  Assert (Condition => Get (P).Data.all = "Lady Ada",
          Message   => " the old way");
  Assert (Condition => Get (P) = "Lady Ada",
          Message   => " the Ada 2012 way");

  ---

  Test_Step (Title       => "Accessor",
             Description => "P gets new object, Accessor object is removed");

  declare
    A: Accessor renames Get (P);
    --A: constant Accessor := Get (P);
  begin
    Assert (Condition => Get (P) = A,
            Message   => "Compare the Ada 2012 way");
    Put_Line ("P = " & Get (P));
    Put_Line ("A = " &    A   );
    Set (P, Data => "Simon Tucker Taft");
    Assert (Condition => Get (P) = "Simon Tucker Taft",
            Message   => "new value");
    Assert (Condition => A = "Lady Ada",
            Message   => "old value");
  end;
  Put_Line ("Check that Free for Lady Ada has been called");

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
    Put_Line ("P = " & Get (P));
    Put_Line ("Q = " & Get (Q));
    Put_Line ("R = " & Get (R));
    R := Create ("Jean Ichbiah");
  end;
  Put_Line ("Check that Free for Jean Ichbiah has been called");

 ---

  Test_Step (Title       => "Assign via Q",
             Description => "P and Q access the same object");

  Get (Q) := "Robert Dewar, ACT";
  Assert (Condition => Get (P) = Get (Q).Data.all and Get (P) = "Robert Dewar, ACT",
          Message   => "same value");

  ---

  Test_Step (Title       => "Unset Q then P",
             Description => "Check that Free is called after unsetting P");

  Unset (Q);
  Assert (Condition => Get (P) = "Robert Dewar, ACT" and is_Null (Q),
          Message   => "not yet freed");

  Unset (P);
  Assert (Condition => is_Null (P),
          Message   => "freed");

  ---

  Test_Result;

end Test_Indefinite_Pointers;
