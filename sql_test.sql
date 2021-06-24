--2.1

SELECT peas.st_id, peas.subject, COUNT(peas.correct), DATE_TRUNC('hour', peas.timest) AS hour_exact
FROM peas 
WHERE (EXTRACT(month FROM peas.timest) = 03 AND EXTRACT(year FROM peas.timest) = 2020) AND peas.correct = TRUE
GROUP BY DATE_TRUNC('hour', peas.timest), peas.st_id, peas.subject
HAVING COUNT(peas.correct)>=20
ORDER BY peas.st_id
;

--2.2

WITH stud_group AS(
	 SELECT peas.st_id, peas.timest, studs.test_grp  
	 FROM studs 
	 left JOIN peas ON studs.st_id = peas.st_id)
SELECT stud_group.test_grp, 
	   avg(checks.money) OVER (PARTITION BY stud_group.test_grp) AS arpu, 
	   avg(checks.money) FILTER (WHERE (EXTRACT(month FROM checks.sale_time) = 10 and EXTRACT(year FROM checks.sale_time ) = 2020)) OVER (PARTITION BY stud_group.test_grp) as arpau,
	   (count(CASE WHEN money>0 THEN 1 ELSE NULL END) / count(checks.st_id)) AS cr, 
	   (count(CASE WHEN money>0 AND (EXTRACT(month FROM checks.sale_time) = 10 AND EXTRACT(year FROM checks.sale_time ) = 2020) THEN 1 ELSE NULL END) / count(checks.st_id)) as cr_act,
	   (count(CASE WHEN money>0 AND checks.subject = 'math' THEN 1 ELSE NULL END) / count(stud_group.test_grp)) as cr_math
FROM checks
left JOIN stud_group ON stud_group.st_id = checks.st_id
GROUP BY stud_group.test_grp, checks.money, checks.sale_time
;
