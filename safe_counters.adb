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

package body Safe_Counters is

  --====================================================================
  -- Author    Christoph Grein
  -- Version   1.0
  -- Date      8 February 2018
  --====================================================================
  --
  --====================================================================
  -- History
  -- Author Version   Date    Reason for change
  --  C.G.    1.0  08.02.2018 Created
  --====================================================================

  procedure Increase (This: in out Counter) is
  begin
    This.Increase;
  end Increase;

  procedure Decrease (This: in out Counter; is_Zero: out Boolean) is
  begin
    This.Decrease (is_Zero);
  end Decrease;

  protected body Counter is

    procedure Increase is
    begin
      Count := Count + 1;
    end Increase;

    procedure Decrease (is_Zero: out Boolean) is
    begin
      Count   := Count - 1;
      is_Zero := Count = 0;
    end Decrease;

    function Get_Count return Natural is
    begin
      return Count;
    end Get_Count;

  end Counter;

end Safe_Counters;
