from pyspark.sql import SparkSession, functions as F
from pyspark.sql import types as T

spark = SparkSession.builder.appName("landing-to-curated").getOrCreate()

# S3 base paths keep the job portable across environments.
# RAW_BASE = "s3://__RAW_BUCKET__/landing"
# CURATED_BASE = "s3://__CURATED_BUCKET__/curated"
# CHECKPOINT_BASE = "s3://__CURATED_BUCKET__/checkpoints"

## for running locally
RAW_BASE = "file:///workspaces/data/raw"
CURATED_BASE = "file:///workspaces/output/curated"
CHECKPOINT_BASE = "file:///workspaces/output/checkpoints"

# Table config keeps schema + DQ rules close to the data they govern.
# These five CSVs are expected under the S3 landing prefix.
TABLES = {
    "batting": {
        "path": f"{RAW_BASE}/Batting.csv",
        "schema": T.StructType(
            [
                T.StructField("playerID", T.StringType(), False),
                T.StructField("yearID", T.IntegerType(), False),
                T.StructField("stint", T.IntegerType(), True),
                T.StructField("teamID", T.StringType(), True),
                T.StructField("lgID", T.StringType(), True),
                T.StructField("G", T.IntegerType(), True),
                T.StructField("AB", T.IntegerType(), True),
                T.StructField("R", T.IntegerType(), True),
                T.StructField("H", T.IntegerType(), True),
                T.StructField("2B", T.IntegerType(), True),
                T.StructField("3B", T.IntegerType(), True),
                T.StructField("HR", T.IntegerType(), True),
                T.StructField("RBI", T.IntegerType(), True),
                T.StructField("SB", T.IntegerType(), True),
                T.StructField("CS", T.IntegerType(), True),
                T.StructField("BB", T.IntegerType(), True),
                T.StructField("SO", T.IntegerType(), True),
                T.StructField("IBB", T.IntegerType(), True),
                T.StructField("HBP", T.IntegerType(), True),
                T.StructField("SH", T.IntegerType(), True),
                T.StructField("SF", T.IntegerType(), True),
                T.StructField("GIDP", T.IntegerType(), True)
            ]
        ),
        "keys": ["playerID", "yearID"],
        "partition_cols": ["yearID"]
    },
    "collegeplaying": {
        "path": f"{RAW_BASE}/CollegePlaying.csv",
        "schema": T.StructType(
            [
                T.StructField("playerID", T.StringType(), False),
                T.StructField("schoolID", T.StringType(), False),
                T.StructField("yearID", T.IntegerType(), False)
            ]
        ),
        "keys": ["playerID", "schoolID", "yearID"],
        "partition_cols": ["yearID"]
    },
    "people": {
        "path": f"{RAW_BASE}/People.csv",
        "schema": T.StructType(
            [
                T.StructField("playerID", T.StringType(), False),
                T.StructField("birthYear", T.IntegerType(), True),
                T.StructField("birthMonth", T.IntegerType(), True),
                T.StructField("birthDay", T.IntegerType(), True),
                T.StructField("birthCountry", T.StringType(), True),
                T.StructField("birthState", T.StringType(), True),
                T.StructField("birthCity", T.StringType(), True),
                T.StructField("deathYear", T.IntegerType(), True),
                T.StructField("deathMonth", T.IntegerType(), True),
                T.StructField("deathDay", T.IntegerType(), True),
                T.StructField("deathCountry", T.StringType(), True),
                T.StructField("deathState", T.StringType(), True),
                T.StructField("deathCity", T.StringType(), True),
                T.StructField("nameFirst", T.StringType(), True),
                T.StructField("nameLast", T.StringType(), True),
                T.StructField("nameGiven", T.StringType(), True),
                T.StructField("weight", T.IntegerType(), True),
                T.StructField("height", T.IntegerType(), True),
                T.StructField("bats", T.StringType(), True),
                T.StructField("throws", T.StringType(), True),
                T.StructField("debut", T.StringType(), True),
                T.StructField("finalGame", T.StringType(), True),
                T.StructField("retroID", T.StringType(), True),
                T.StructField("bbrefID", T.StringType(), True)
            ]
        ),
        "keys": ["playerID"],
        "partition_cols": []
    },
    "salaries": {
        "path": f"{RAW_BASE}/Salaries.csv",
        "schema": T.StructType(
            [
                T.StructField("yearID", T.IntegerType(), False),
                T.StructField("teamID", T.StringType(), False),
                T.StructField("lgID", T.StringType(), True),
                T.StructField("playerID", T.StringType(), False),
                T.StructField("salary", T.LongType(), True)
            ]
        ),
        "keys": ["playerID", "teamID", "yearID"],
        "partition_cols": ["yearID"]
    },
    "schools": {
        "path": f"{RAW_BASE}/Schools.csv",
        "schema": T.StructType(
            [
                T.StructField("schoolID", T.StringType(), False),
                T.StructField("name_full", T.StringType(), True),
                T.StructField("city", T.StringType(), True),
                T.StructField("state", T.StringType(), True),
                T.StructField("country", T.StringType(), True)
            ]
        ),
        "keys": ["schoolID"],
        "partition_cols": []
    }
}


def read_csv(path, schema):
    # Explicit schema avoids costly inference and makes data types predictable.
    return (
        spark.read.format("csv")
        .option("header", "true")
        .schema(schema)
        .load(path)
    )


def run_dq_checks(df, keys, min_year=1871, max_year=2100):
    # Minimal checks: drop rows missing business keys and clamp year ranges.
    for key in keys:
        df = df.filter(F.col(key).isNotNull())

    if "yearID" in df.columns:
        df = df.filter((F.col("yearID") >= min_year) & (F.col("yearID") <= max_year))

    return df


def write_delta(df, table_name, partition_cols):
    # Local test path uses Parquet to avoid Delta dependencies.
    target_path = f"{CURATED_BASE}/{table_name}"

    writer = (
        df.write
        .format("parquet")
        .mode("overwrite")
    )

    if partition_cols:
        writer = writer.partitionBy(*partition_cols)

    writer.save(target_path)


# Iterate deterministically over configured tables.
for table_name, cfg in TABLES.items():
    source_df = read_csv(cfg["path"], cfg["schema"])
    cleaned_df = run_dq_checks(source_df, cfg["keys"])
    write_delta(cleaned_df, table_name, cfg["partition_cols"])
