SELECT * 
FROM Overwatch;

-- 									* Cleaning Data *
-- Renaming table 
RENAME TABLE overwatch_project_original TO Overwatch;

-- Deleting Date column as data wasn't imported properly and all data was recorded on the same date anyway
ALTER TABLE Overwatch 
DROP COLUMN `Date`;

-- Changing data type for Role column
UPDATE Overwatch 
SET `Role` = 'O'
WHERE `Role` IN ('OFFENSE', 'DEFENSE');

UPDATE Overwatch 
SET `Role` = 'T'
WHERE `Role` = 'TANK';

UPDATE Overwatch 
SET `Role` = 'S'
WHERE `Role` = 'SUPPORT';

ALTER TABLE Overwatch
MODIFY `Role` Char(1);

-- Standardizing and changing data type for Platform column
SELECT substring(Platform, 1, 2)
FROM Overwatch;

UPDATE overwatch
SET Platform = 'P5'
WHERE Platform = 'PS';

UPDATE Overwatch
SET Platform = substring(Platform, 1, 2);

Alter TABLE overwatch
MODIFY Platform CHAR(2);

-- 											* Analyzing Data * 
-- Finding the lowest picked by role and platform accross all Platforms
SELECT Hero, `Role`, Pick_rate, Platform
FROM (
SELECT *,   
RANK() OVER(PARTITION BY `Role`, Platform ORDER BY Pick_rate) AS Ranker
FROM overwatch
WHERE `Rank` = 'All' ) AS Sorter
WHERE Ranker = 1;

-- Comparing the Win_rate accross all Platforms and all Ranks 
-- I added a rank to better tell where the characters stand on each platform.
SELECT opc.Hero, opc.Win_rate AS PC_Win_Rate, PC_Rank,
op5.Win_rate AS P5_Win_Rate, P5_Rank,
 oxb.Win_rate AS XB_Win_Rate, XB_Rank
FROM ( 
SELECT *, RANK() OVER(ORDER BY Win_rate DESC) AS PC_Rank
FROM overwatch 
WHERE Platform = 'PC' AND `Rank` = 'All'
ORDER BY Hero ) AS opc
JOIN (
SELECT *, RANK() OVER(ORDER BY Win_rate DESC) AS P5_Rank
FROM overwatch 
WHERE Platform = 'P5' AND `Rank` = 'All'
ORDER BY Hero) AS op5
	ON opc.Hero = op5.Hero
JOIN (
SELECT *, RANK() OVER(ORDER BY Win_rate DESC) AS XB_Rank
FROM overwatch 
WHERE Platform = 'XB' AND `Rank` = 'All'
ORDER BY Hero ) AS oxb
	ON opc.Hero = oxb.Hero;
    
-- I would like to see the top 6 heros with the highest win rate by platforms
SELECT Hero, Win_rate, Platform
FROM (
SELECT *,   
RANK() OVER(PARTITION BY `Rank`, Platform ORDER BY Win_rate DESC) AS Ranker
FROM overwatch
WHERE `Rank` = 'All' ) AS Sorter
WHERE Ranker = 1;

-- I wanted to see if ther on fire rate corresponded to there win rate
SELECT Hero, Win_rate, Fire_Rank, Platform
FROM (
SELECT *,   
RANK() OVER(PARTITION BY `Rank`, Platform ORDER BY Win_rate DESC) AS Win_Rank,
RANK() OVER(PARTITION BY `Rank`, Platform ORDER BY On_fire DESC) AS Fire_Rank
FROM overwatch
WHERE `Rank` = 'All' ) AS Sorter
WHERE Win_Rank = 1;