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

with Test_Support;
use  Test_Support;

with Generic_Smart_Pointers;
with Selected_Counters;

procedure Test_Dispatching is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   2.1
  -- Date      13 February 2018
  --====================================================================
  -- Test dispatching calls.
  -- To be dispatching, Work must be defined in a package spec.
  --
  -- Attention: For some reason or another, on Windows 8.1, the
  --            executable name must not contain the string "dispatch".
  --            Rename it so something else like "test_dispat".
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    2.1  13.02.2018 Selected_Counters now generic parameter
  --  C.G.    2.0  15.05.2016 Smart_Pointers now generic
  --  C.G.    1.0  15.09.2011 Created
  --====================================================================

  package  Smart_Pointers is new Generic_Smart_Pointers (Selected_Counters);
  use Smart_Pointers;

  ----------------------------------------------------------------
  package Root is
    type My_Root is abstract new Client_Data with null record;
    not overriding procedure Work (X: in out My_Root) is abstract;
  end Root;
  use Root;
  ----------------------------------------------------------------
  type Int_Data is new My_Root with record
    I: Integer;
  end record;

  overriding procedure Work (X: in out Int_Data);

  ----------------------------------------------------------------
  type Flt_Data is new My_Root with record
    F: Float;
  end record;

  overriding procedure Work (X: in out Flt_Data);

  ----------------------------------------------------------------
  procedure Work (X: in out Int_Data) is
  begin
    Put_Line ("Work Int_Data" & Integer'Image (X.I));
  end Work;

  procedure Work (X: in out Flt_Data) is
  begin
    Put_Line ("Work Flt_Data" & Float'Image (X.F));
  end Work;

  ----------------------------------------------------------------
  P, R: Smart_Pointer;

begin

  Test_Header (Title       => "Test Dispatching",
               Description => "Dereference and call Work once via static binding,"&
               " once via dispatching.");

  Test_Step (Title       => "Set P and Q",
             Description => "");

  Put_Line ("Set P");
  Set (P, Int_Data'(Client_Data with I => 42));

  Put_Line ("Set R");
  Set (R, Flt_Data'(Client_Data with F => 42.0E-10));

  ----------------------------------------------------------------
  Test_Step (Title       => "Call with static binding",
             Description => "");

  Work (Int_Data (Get (P).Data.all));
  Flt_Data (Get (R).Data.all).Work;
  New_Line;

  ----------------------------------------------------------------
  Test_Step (Title       => "Call with dispatching",
             Description => "");

  Work (My_Root'Class (Get (P).Data.all));
  My_Root'Class (Get (R).Data.all).Work;
  New_Line;

  Assert (Condition => True,
          Message   => "no exception occurred");

  Test_Result;

exception
  when others =>
    Assert (Condition => False,
            Message   => "unexpected exception occurred");
    Test_Result;

end Test_Dispatching;
