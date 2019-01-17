# Change Log

## 0.2.0 (2019-01-17)
### Breaking Changes
* Minimum supported Elixir is now 1.4.

### Changed
* ([#3](https://github.com/TheRealReal/ecto-ulid/pull/3))
  Fix deprecation warnings regarding time units.

## 0.1.1 (2018-12-03)
### Added
* ([#2](https://github.com/TheRealReal/ecto-ulid/pull/2))
  Add support for Ecto 3.x.

## 0.1.0 (2018-06-06)
### Added
* Generate ULID in Base32 or binary format.
* Generate ULID for a given timestamp.
* Autogenerate ULID when used as a primary key.
* Supports reading and writing ULID in a database backed by its native `uuid` type (no database
  extensions required).
* Supports Ecto 2.x.
* Supports Elixir 1.2 and newer.
* Tested with PostgreSQL and MySQL.
