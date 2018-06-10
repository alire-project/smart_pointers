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

package Safe_Counters is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   1.0
  -- Date      8 February 2018
  --====================================================================
  -- A task safe counter.
  -- The counter starts with value 1. It must not become negative or
  -- Constraint_Error will be raised.
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    1.0  08.02.2018 Created
  --====================================================================

  type Counter is limited private;  -- non-negative

  procedure Increase (This: in out Counter) with Inline;
  procedure Decrease (This: in out Counter; is_Zero: out Boolean) with Inline;

  is_Tasksafe: constant Boolean := True;

private

  protected type Counter is
    procedure Increase;
    procedure Decrease (is_Zero: out Boolean);
    function Get_Count return Natural;  -- for test only
  private
    Count: Natural := 1;
  end Counter;

end Safe_Counters;
