-- Team-year efficiency aggregate (Batting + Salaries)
-- Rationale:
-- 1) Double counting: Batting is aggregated once at teamID, yearID across all players/stints.
-- 2) Idempotency: Deterministic GROUP BY + ORDER BY yields stable output; no non-deterministic ops.
-- 3) Performance: Group only needed columns; join after aggregation to reduce shuffle.
-- 4) Edge cases: Guard against NULL/zero AB and missing payroll with COALESCE.
-- 5) Incremental strategy: If warehoused, partition by yearID and rebuild by year.

-- Expected inputs:
-- batting(playerID, yearID, teamID, AB, H, 2B, 3B, HR, ...)
-- salaries(playerID, yearID, teamID, salary, ...)

WITH batting_team_year AS (
  SELECT
    CAST(yearID AS INT) AS yearID,
    CAST(teamID AS STRING) AS teamID,
    SUM(CAST(AB AS BIGINT)) AS AB,
    SUM(CAST(H AS BIGINT)) AS H,
    SUM(CAST("2B" AS BIGINT)) AS doubles,
    SUM(CAST("3B" AS BIGINT)) AS triples,
    SUM(CAST(HR AS BIGINT)) AS HR
  FROM batting
  WHERE yearID IS NOT NULL AND teamID IS NOT NULL
  GROUP BY CAST(yearID AS INT), CAST(teamID AS STRING)
),

salaries_team_year AS (
  SELECT
    CAST(yearID AS INT) AS yearID,
    CAST(teamID AS STRING) AS teamID,
    SUM(CAST(salary AS BIGINT)) AS total_payroll
  FROM salaries
  WHERE yearID IS NOT NULL AND teamID IS NOT NULL
  GROUP BY CAST(yearID AS INT), CAST(teamID AS STRING)
)

SELECT
  b.teamID,
  b.yearID,
  COALESCE(s.total_payroll, 0) AS total_payroll,
  b.AB,
  b.HR,
  CASE WHEN b.AB > 0 THEN CAST(b.H AS DOUBLE) / b.AB ELSE NULL END AS BA,
  CASE
    WHEN b.AB > 0 THEN CAST(b.H + b.doubles + (2 * b.triples) + (3 * b.HR) AS DOUBLE) / b.AB
    ELSE NULL
  END AS SLG,
  CASE
    WHEN COALESCE(s.total_payroll, 0) > 0 THEN CAST(b.HR AS DOUBLE) / (COALESCE(s.total_payroll, 0) / 1000000.0)
    ELSE NULL
  END AS HR_per_Million
FROM batting_team_year b
LEFT JOIN salaries_team_year s
  ON b.teamID = s.teamID AND b.yearID = s.yearID
ORDER BY b.yearID, b.teamID;
