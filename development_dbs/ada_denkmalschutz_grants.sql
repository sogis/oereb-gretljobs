-- Grant privileges on schemas
GRANT USAGE
ON SCHEMA ada_denkmalschutz, ada_denkmalschutz_oereb
TO public, gretl;

-- Grant read privileges
GRANT SELECT
ON ALL TABLES IN SCHEMA ada_denkmalschutz, ada_denkmalschutz_oereb
TO public;

-- Grant write privileges
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA ada_denkmalschutz, ada_denkmalschutz_oereb
TO gretl;
GRANT USAGE
ON ALL SEQUENCES IN SCHEMA ada_denkmalschutz, ada_denkmalschutz_oereb
TO gretl;
