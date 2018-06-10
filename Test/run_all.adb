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
-- Copyright (c) 2016, 2018 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

with Test_Support;
use  Test_Support;

with Test_Smart_Pointers,
     Test_Definite_Pointers,
     Test_Indefinite_Pointers,
     Test_Indefinite_Record_Pointers;
with Test_Dispatching,
     Test_Class_Pointers;

procedure Run_All is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   1.1
  -- Date      8 February 2018
  --====================================================================
  -- Run all tests.
  -- In Selected_Counters_Get_Count, Simple_Counters respectively
  -- Safe_Counters have to be uncommented in accordance with the
  -- selection in Selected_Counters.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    1.1  08.02.2018 Add comments about how to use
  --  C.G.    1.0  17.05.2016 Created
  --====================================================================

begin

  Test_Smart_Pointers;
  Test_Definite_Pointers;
  Test_Indefinite_Pointers;
  Test_Indefinite_Record_Pointers;

  Test_Dispatching;
  Test_Class_Pointers;

  Global_Result;

end Run_All;
