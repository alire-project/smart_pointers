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
-- Copyright (c) 2016 Christoph Karl Walter Grein
-- ---------------------------------------------------------------------

generic
  with function Get_Count (This: Counters.Counter) return Natural;
function Generic_Smart_Pointers.Get_Count (Self: Smart_Pointer) return Natural;

--====================================================================
-- Author    Christoph Grein
-- Version   2.0
-- Date      13 February 2018
--====================================================================
-- Taken out of Smart_Pointers private part to be used for test only.
--====================================================================
-- History
-- Author Version   Date    Reason for change
--  C.G.    2.0  13.02.2018 Generic parameter Get_Count
--  C.G.    1.0  12.05.2016 Created
--====================================================================
