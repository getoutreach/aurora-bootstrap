# Changelog

## Unreleased

## 0.2.4
- [#18](https://github.com/gaorlov/aurora-bootstrap/pull/18/) - Read passwords from vault
- [#17](https://github.com/gaorlov/aurora-bootstrap/pull/17) - `export_date_override` will check for the most recent export date (for the last 30 days) in S3 before defaulting to today's date to enable consistent dating for long running exports

## 0.2.3
- [#16](https://github.com/gaorlov/aurora-bootstrap/pull/16) - Pass in s3path to Notifier

## 0.2.2
- Fixing typo

## 0.2.1
- [#14](https://github.com/gaorlov/aurora-bootstrap/pull/14) - updating `EXPORT_DATE_OVERRIDE` behavior to be truthy if present and falsey when absent

## 0.2.0
- [#13](https://github.com/gaorlov/aurora-bootstrap/pull/13) - adding notification functionality to publish to S3 when export is complete

## 0.1.2
- [#12](https://github.com/gaorlov/aurora-bootstrap/pull/12) - adding table whitelisting

## 0.1.1.7
- [#11](https://github.com/gaorlov/aurora-bootstrap/pull/11) - fixing dashed database support
