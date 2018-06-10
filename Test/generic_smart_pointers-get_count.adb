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

function Generic_Smart_Pointers.Get_Count (Self: Smart_Pointer) return Natural is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   2.1
  -- Date      13 February 2018
  --====================================================================
  -- Self /= null always in tests so no need to test for null.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    2.1  13.02.2018 Call generic parameter Get_Count
  --  C.G.    2.0  08.02.2018 Selected_Counters_Get_Count
  --  C.G.    1.0  12.05.2016 Created
  --====================================================================

begin

  return Get_Count (Self.Pointer.Count.all);

end Generic_Smart_Pointers.Get_Count;
