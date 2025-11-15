function jl_etl-output_scheme -d "Show schema of output"
    duckdb -c "DESCRIBE SELECT * FROM read_parquet('test_output/**/*.parquet')"
end
