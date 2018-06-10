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
-- Copyright (c) 2018 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

generic

  is_Tasksafe: Boolean;

  type Counter is limited private;  -- non-negative

  with procedure Increase (This: in out Counter) is <>;
  with procedure Decrease (This: in out Counter; is_Zero: out Boolean) is <>;

package Generic_Counters is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   1.0
  -- Date      13 February 2018
  --====================================================================
  -- A deliberately empty signature package.
  -- Instantiate with either
  -- Simple_Counters for sequential use or
  -- Safe_Counters for task safe  use.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    1.0  13.02.2018 Created
  --====================================================================

end Generic_Counters;
