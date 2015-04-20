# Contributing

## Forking

[Fork this repository](https://github.com/rapid7/metasploit-cache/fork)

## Branching

Branch names follow the format `TYPE/ISSUE/SUMMARY`.  You can create it with `git checkout -b TYPE/ISSUE/SUMMARY`.

### `TYPE`

`TYPE` can be `bug`, `chore`, or `feature`.

### `ISSUE`

`ISSUE` is either a [Github issue](https://github.com/rapid7/metasploit-cache/issues) or an issue from some other
issue tracking software.

### `SUMMARY`

`SUMMARY` is is short summary of the purpose of the branch composed of lower case words separated by '-' so that it is a valid `PRERELEASE` for the Gem version.

## Changes

### `PRERELEASE`

1. Update `PRERELEASE` to match the `SUMMARY` in the branch name.  If you branched from `master`, and [version.rb](lib/metasploit/cache/version.rb) does not have `PRERELEASE` defined, then adding the following lines after `PATCH`:
```
# The prerelease version, scoped to the {MAJOR}, {MINOR}, and {PATCH} version number.
PRERELEASE = '<SUMMARY>'
```
2. `rake spec`
3.  Verify the specs pass, which indicates that `PRERELEASE` was updated correctly.
4. Commit the change `git commit -a`

### Your changes

Make your changes or however many commits you like, committing each with `git commit`.

### Pre-Pull Request Steps

#### Testing
1. `rake cucumber spec coverage`
2. Verify there were no failures.
3. Verify there was 100% coverage.

#### Documentation
1. `rake yard`
2. Verify there were no warnings.
2. Verify there were no undocumented objects.

### Push

Push your branch to your fork on gitub: `git push TYPE/ISSUE/SUMMARY`

### Pull Request

* [Create new Pull Request](https://github.com/rapid7/metasploit-cache/compare/)
* Add a Verification Steps to the description comment

```
# Verification Steps
- [ ] `rm Gemfile.lock`
- [ ] `bundle install`

## Test coverage

Test coverage should not differ between the database adapters.

### Postgres
- [ ] `rm Gemfile.lock`
- [ ] `bundle install --without sqlite`
- [ ] `DATABASE_ADAPTER=postgres rake cucumber spec coverage`
- [ ] VERIFY no failures
- [ ] VERIFY 100% coverage

### Sqlite3
- [ ] `rm Gemfile.lock`
- [ ] `bundle install --without postgres`
- [ ] `DATABASE_ADAPTER=sqlite3 rake cucumber spec coverage`
- [ ] VERIFY no failures
- [ ] VERIFY 100% coverage

## Documentation coverage

Documentation coverage should not differ between the database adapters.

### Postgres
- [ ] `rm Gemfile.lock`
- [ ] `bundle install --without sqlite`
- [ ] `DATABASE_ADAPTER=postgres rake yard`
- [ ] `rake yard`
- [ ] VERIFY no warnings
- [ ] VERIFY no undocumented objects

### Sqlite3
- [ ] `rm Gemfile.lock`
- [ ] `bundle install --without postgres`
- [ ] `DATABASE_ADAPTER=sqlite3 rake yard`
- [ ] `rake yard`
- [ ] VERIFY no warnings
- [ ] VERIFY no undocumented objects
```

You should also include at least one scenario to manually check the changes outside of specs.

* Add Post-merge Steps to the description comment

The 'Post-merge Steps' are a reminder to the reviewer of the Pull Request of how to update the [`PRERELEASE`](lib/metasploit/cache/version.rb) so that [version_spec.rb](spec/lib/metasploit/cache/version.rb_spec.rb) passes on the target branch after the merge.

DESTINATION is the name of the destination branch into which the merge is being made.  SOURCE_SUMMARY is the SUMMARY from TYPE/ISSUE/SUMMARY branch name for the SOURCE branch that is being made.

When merging to `master`:

```
# Post-merge Steps

Perform these steps prior to pushing to master or the build will be broken on master.

## Version
- [ ] Edit `lib/metasploit/cache/version.rb`
- [ ] Remove `PRERELEASE` and its comment as `PRERELEASE` is not defined on master.

## Gem build
- [ ] gem build *.gemspec
- [ ] VERIFY the gem has no '.pre' version suffix.

## RSpec
- [ ] `rake spec`
- [ ] VERIFY version examples pass without failures

## Commit & Push
- [ ] `git commit -a`
- [ ] `git push origin master`
```

When merging to DESTINATION other than `master`:

```
# Post-merge Steps

Perform these steps prior to pushing to DESTINATION or the build will be broken on DESTINATION.

## Version
- [ ] Edit `lib/metasploit/cache/version.rb`
- [ ] Change `PRERELEASE` from `SOURCE_SUMMARY` to `DESTINATION_SUMMARY` to match the branch (DESTINATION) summary (DESTINATION_SUMMARY)

## Gem build
- [ ] gem build metasploit-cache.gemspec
- [ ] VERIFY the prerelease suffix has change on the gem.

## RSpec
- [ ] `rake spec`
- [ ] VERIFY version examples pass without failures

## Commit & Push
- [ ] `git commit -a`
- [ ] `git push origin DESTINATION`
```

To update the [CHANGELOG.md](CHANGELOG.md) with the merged changes or release the merged code see
[RELEASING.md](RELEASING.md)
