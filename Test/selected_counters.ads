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

with Generic_Counters;

-- with Safe_Counters;
-- use  Safe_Counters;

-- with Simple_Counters;
-- use  Simple_Counters;

package Selected_Counters is new Generic_Counters (is_Tasksafe, Counter);

--====================================================================
-- Author    Christoph Grein
-- Version   2.0
-- Date      13 February 2018
--====================================================================
-- For ease of test:
-- For sequential use, uncomment Simple_Counters.
-- For task safe  use, uncomment Safe_Counters.
--====================================================================
-- History
-- Author Version   Date    Reason for change
--  C.G.    2.0  13.02.2018 Now generic instantiation
--  C.G.    1.0  08.02.2018 Created
--====================================================================
