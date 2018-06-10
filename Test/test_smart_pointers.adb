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

with Generic_Smart_Pointers.Get_Count;
with Selected_Counters,
     Selected_Counters_Get_Count;

with Test_Support;
use  Test_Support;

procedure Test_Smart_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   3.1
  -- Date      13 February 2018
  --====================================================================
  -- Test all functionality by checking the hidden count with a definite
  -- type so that Free for the user-defined type is not needed.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    3.1  13.02.2018 Selected_Counters now generic parameter
  --  C.G.    3.0  08.02.2018 is_Tasksafe added
  --  C.G.    2.0  15.05.2016 Renamed Smart_Pointers.Test
  --  C.G.    1.2  27.06.2012 GNAT bug is fixed in GPL 2012
  --  C.G.    1.1  31.05.2011 Added test with uninitialised pointer
  --  C.G.    1.0  01.03.2011 Created
  --====================================================================

  package  Smart_Pointers is new Generic_Smart_Pointers (Selected_Counters);
  function Get_Count      is new Smart_Pointers.Get_Count (Selected_Counters_Get_Count);  -- for test only
  use Smart_Pointers;

  Free_must_be_called: Boolean := False;  -- set to True in appropriate test steps when no pointer is left

  type Int_Data is new Smart_Pointers.Client_Data with record
    I: Integer;
  end record;
  overriding procedure Free (Data: in out Int_Data) is
    -- Actually unneeded in this case. Just to show that it's called.
  begin
    Assert (Condition => Free_must_be_called,
            Message   => "No pointer left: Free is called",
            Only_Report_Error => False);
  end Free;

  P, Q: Smart_Pointer;

begin

  Test_Header (Title       => "Test Smart_Pointers",
               Description => "Instantiate the generic (not on library level)" &
                              " and check the internal counter.");

  Put_Line (".---------------------------------" & (if is_Tasksafe then "" else "----") & "----------.");
  Put_Line ("| This Smart_Pointers instance is " & (if is_Tasksafe then "" else "not ") & "tasksafe. |");
  Put_Line ("`---------------------------------" & (if is_Tasksafe then "" else "----") & "----------'");

  ---

  Test_Step (Title       => "P and Q uninitialized",
             Description => "P and Q must be null");

  Assert (Condition => is_Null (P) and Get (P).Data = null,
          Message   => "P is null");
  Assert (Condition => is_Null (Q) and Get (Q).Data = null,
          Message   => "Q is null");

  ---

  Test_Step (Title       => "Set P",
             Description => "One pointer after Set, two pointers with accessor");

  Set (P, Int_Data'(Client_Data with I => -10));

  Assert (Condition => Get_Count (P) = 1,
          Message   => "One pointer");
  Put_Line ("Query P");  -- expected count is number of pointers plus accessors to object
  Put_Line ("P = " & Integer'Image (Int_Data (Get (P).Data.all).I) & Integer'Image (Get_Count (P)));  -- 2
  Assert (Condition => Int_Data (Get (P).Data.all).I = -10 and Get_Count (P) = 2,
          Message   => "Two pointers");
  Assert (Condition => Get_Count (P) = 1,
          Message   => "One pointer again after death of accessor");
  Assert (Condition => is_Null (Q) and Get (Q).Data = null,
          Message   => "Q is still null");

  ---

  Test_Step (Title       => "Accessor renamed",
             Description => "Local accessor increases counter");

  declare
    A: Accessor renames Get (P);  -- GNAT Pro 6.4.0w bug K504-018; GNAT GPL 2012 OK
  begin
    Put_Line ("P = " & Integer'Image (Int_Data (Get (P).Data.all).I) & Integer'Image (Get_Count (P)));  -- 3
    Put_Line ("A = " & Integer'Image (Int_Data (   A   .Data.all).I));
    Assert (Condition => Int_Data (Get (P).Data.all).I = -10 and
                         Int_Data (   A   .Data.all).I = -10 and Get_Count (P) = 3,
            Message   => "Three pointers");
    Set (P, Int_Data'(Client_Data with I => 12345));  -- only one pointer is left (via A)
    Put_Line ("P = " & Integer'Image (Int_Data (Get (P).Data.all).I) & Integer'Image (Get_Count (P)));  -- 2
    Put_Line ("A = " & Integer'Image (Int_Data (   A   .Data.all).I));
    Free_must_be_called := True;  -- now, no pointers are left when A goes out of scope
  end;

  Free_must_be_called := False;  -- must not be called in next steps

  ---

  Test_Step (Title       => "Accessor copied",
             Description => "Same as previous step");

  declare
   A: constant Accessor := Get (P);
  begin
    Put_Line ("P = " & Integer'Image (Int_Data (Get (P).Data.all).I) & Integer'Image (Get_Count (P)));  -- 3
    Put_Line ("A = " & Integer'Image (Int_Data (   A   .Data.all).I));
    Assert (Condition => Int_Data (Get (P).Data.all).I = 12345 and
                         Int_Data (   A   .Data.all).I = 12345 and Get_Count (P) = 3,
            Message   => "Three pointers");
    Set (P, Int_Data'(Client_Data with I => 2012));
    Put_Line ("P = " & Integer'Image (Int_Data (Get (P).Data.all).I) & Integer'Image (Get_Count (P)));  -- 2
    Put_Line ("A = " & Integer'Image (Int_Data (   A   .Data.all).I));
    Free_must_be_called := True;  -- now, no pointers are left when A goes out of scope
  end;

  Free_must_be_called := False;  -- must not be called

  ---

  Test_Step (Title       => "Assignment Q := P;",
             Description => "Counter increased");

  Q := P;

  Assert (Condition => P = Q,
          Message   => "P equals Q");
  Put_Line ("P = " & Integer'Image (Int_Data (Get (P).Data.all).I) & Integer'Image (Get_Count (P)));  -- 3
  Put_Line ("Q = " & Integer'Image (Int_Data (Get (Q).Data.all).I) & Integer'Image (Get_Count (Q)));  -- 3
  Assert (Condition => Int_Data (Get (P).Data.all).I = 2012 and Get_Count (P) = 3,
          Message   => "Three pointers for P");
  Assert (Condition => Int_Data (Get (Q).Data.all).I = 2012 and Get_Count (Q) = 3,
          Message   => "Three pointers for Q");

  ---

  Test_Step (Title       => "Local block",
             Description => "Added local pointer");

  declare
    R: constant Smart_Pointer := Q;
  begin
    Put_Line ("P = " & Integer'Image (Int_Data (Get (P).Data.all).I) & Integer'Image (Get_Count (P)));  -- 4
    Put_Line ("Q = " & Integer'Image (Int_Data (Get (Q).Data.all).I) & Integer'Image (Get_Count (Q)));  -- 4
    Put_Line ("R = " & Integer'Image (Int_Data (Get (R).Data.all).I) & Integer'Image (Get_Count (R)));  -- 4
    Assert (Condition => Int_Data (Get (P).Data.all).I = 2012 and Get_Count (P) = 4,
            Message   => "Four pointers for P");
    Assert (Condition => Int_Data (Get (Q).Data.all).I = 2012 and Get_Count (Q) = 4,
            Message   => "Four pointers for Q");
    Assert (Condition => Int_Data (Get (R).Data.all).I = 2012 and Get_Count (R) = 4,
            Message   => "Four pointers for R");
  end;

  ---

  Test_Step (Title       => "Local block finalized",
             Description => "P and Q must revert to previous state");

  Q := P;

  Assert (Condition => P = Q,
          Message   => "P equals Q");
  Put_Line ("P = " & Integer'Image (Int_Data (Get (P).Data.all).I) & Integer'Image (Get_Count (P)));  -- 3
  Put_Line ("Q = " & Integer'Image (Int_Data (Get (Q).Data.all).I) & Integer'Image (Get_Count (Q)));  -- 3
  Assert (Condition => Int_Data (Get (P).Data.all).I = 2012 and Get_Count (P) = 3,
          Message   => "Three pointers for P");
  Assert (Condition => Int_Data (Get (Q).Data.all).I = 2012 and Get_Count (Q) = 3,
          Message   => "Three pointers for Q");

  ---

  Test_Step (Title       => "Accessor to uninitialised pointer in local block",
             Description => "Check that it is null");

  declare
    R: Smart_Pointer;
  begin
    Assert (Condition => is_Null (R),
            Message   => "is_Null is True");
    Assert (Condition => Get (R).Data = null,
            Message   => "Accessor is null");
  end;

  ---

  Test_Step (Title       => "Assign new value via Q",
             Description => "Check that it P points to new value");

  Int_Data (Get (Q).Data.all).I := 1815;

  Assert (Condition => Int_Data (Get (P).Data.all).I = 1815 and Get_Count (P) = 3,
          Message   => "Three pointers for P");
  Assert (Condition => Int_Data (Get (Q).Data.all).I = 1815 and Get_Count (Q) = 3,
          Message   => "Three pointers for Q");

  ---

  Test_Step (Title       => "Unset Q",
             Description => "Check that P is unaffected and Q is null");

  Unset (Q);

  Assert (Condition => is_Null (Q) and Get (Q).Data = null,
          Message   => "Q is null");
  Assert (Condition => Get_Count (P) = 1,
          Message   => "One pointer for P");
  Assert (Condition => Int_Data (Get (P).Data.all).I = 1815 and Get_Count (P) = 2,
          Message   => "Two pointers for P with accessor");

  ---

  Free_must_be_called := True;  -- now, no pointers are left for last two steps

  Test_Step (Title       => "Unset P",
             Description => "Check that P is null");

  Unset (P);

  Assert (Condition => is_Null (P) and Get (P).Data = null,
          Message   => "P is null");

  ---

  Test_Step (Title       => "Pointer in local block",
             Description => "Check that data is freed when block is left");

  declare
    P: Smart_Pointer := Create (Int_Data'(Client_Data with I => 95));
  begin
    Assert (Condition => Int_Data (Get (P).Data.all).I = 95 and Get_Count (P) = 2,
            Message   => "Two pointers for local P with accessor");
  end;

  ---

  Test_Result;

end Test_Smart_Pointers;
