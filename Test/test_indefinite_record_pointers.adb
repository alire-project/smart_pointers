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
-- Copyright (c) 2012, 2016, 2018 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

with Test_Support;
use  Test_Support;

with Generic_Smart_Pointers.Generic_Indefinite_Pointers;
with Selected_Counters;

procedure Test_Indefinite_Record_Pointers is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   2.1
  -- Date      13 February 2018
  --====================================================================
  -- Test Generic_Indefinite_Pointers for an instantiation with a
  -- record of string object and string pointer.
  -- Deep_Copy must be a truely deep copy and Free must clean up the
  -- pointer.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    2.1  13.02.2018 Selected_Counters now generic parameter
  --  C.G.    2.0  18.05.2016 Smart_Pointers now generic
  --  C.G.    1.0  29.06.2012 Created for testing bug fix
  --====================================================================

  package  Smart_Pointers is new Generic_Smart_Pointers (Selected_Counters);

  type String_Ptr is access String;

  type My_Record (Length: Natural) is record
    Text: String (1 .. Length);
    Ptr : String_Ptr;
  end record;

  function Deep_Copy (Data: My_Record) return My_Record;
  procedure Free (Data: in out My_Record);

  package My_Pointers is new Smart_Pointers.Generic_Indefinite_Pointers (My_Record, Deep_Copy, Free);
  use My_Pointers;

  function Deep_Copy (Data: My_Record) return My_Record is
  begin
    Put_Line ("Deep_Copy");
    return X: My_Record := Data do
      if X.Ptr /= null then
        X.Ptr := new String'(X.Ptr.all);
      end if;
    end return;
  end Deep_Copy;

  procedure Free (Data: in out My_Record) is
    procedure Free is new Ada.Unchecked_Deallocation (String, String_Ptr);
  begin
    Put_Line ("Pointer in record with " & Data.Text & " freed: " &
              (if Data.Ptr /= null then Data.Ptr.all else "already null"));
    Free (Data.Ptr);  -- does nothing if null
  end Free;

  procedure Put_Line (Source: String; X: My_Record) is
  begin
    Put_Line (Source & X.Text & (if X.Ptr /= null then ' ' & X.Ptr.all else ", null"));
  end Put_Line;

  P, Q: Smart_Pointer;

begin

  Test_Header (Title       => "Test Indefinite_Pointers with Indirection",
               Description => "Instantiate the generic for a record with pointer component.");

  ---

  Test_Step (Title       => "Set P",
             Description => "Query P");

  Set (P, Data => (Length => 8,
                   Text   => "Lady Ada",
                   Ptr    => new String'("- Oh my dear!")));
  New_Line;

  Assert (Condition => Get (P).Text = "Lady Ada",
          Message   => "Text");
  Assert (Condition => Get (P).Ptr.all = "- Oh my dear!",
          Message   => "Ptr dereferenced");
  Put_Line ("P = ", Get (P));

  ---

  Test_Step (Title       => "Assignment",
             Description => "P and Q access the same object");

  Q := P;
  Assert (Condition => Get (P) = Get (Q),
          Message   => "same value");

  ---

  Test_Step (Title       => "Accessor",
             Description => "P gets new object");

  declare
    A: Accessor renames Get (P);
  begin
    Put_Line ("P = ", Get (P));
    Put_Line ("A = ",    A   );
    Set (P, Data => (Length => 17,
                     Text   => "Simon Tucker Taft",
                     Ptr    => null));
    Put_Line ("P = ", Get (P));
    Put_Line ("A = ",    A   );
  end ;

  ---

  Test_Step (Title       => "Unset Q",
             Description => "Lady Ada is finalized");

  Unset (Q);
  Put_Line ("Check that Free for Lady Ada has been called");

  ---

  Test_Step (Title       => "Test end",
             Description => "P's object is finalized");

  Put_Line ("Check that Free for Simon Tucker Taft has been called" &
            " (will be done after Test_Result).");

  ---

  Test_Result;

end Test_Indefinite_Record_Pointers;
