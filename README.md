# hpcadmintools

## Usage

`bin/process-accounting-log`

This command could convert the accounting log files into CSV format.

```shell
$ cat accounting-log | bin/process-accounting-log
```

`bin/filter-by-month`

This command could filter the record by month

```shell
cat ~/account-log.csv | bin/process-accounting-log | bin/filter-by-month 201608
```
