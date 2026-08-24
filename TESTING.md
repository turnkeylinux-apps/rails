# Rails 19.0 acceptance

## Source decision

Rails 19.0 uses Debian 13 Trixie packages for Ruby 3.3, Rails 7.2,
Phusion Passenger 6, Apache, MariaDB and Node.js 20. The sample application's
Bundler lock is generated with `bundle lock --local`, so the shipped stack does
not download application gems or language runtimes from upstream. Webmin and
its Apache and MariaDB modules continue to come from the signed TurnKey Trixie
repository.

The v18 common Rails build cloned rbenv and ruby-build and then installed the
latest available Ruby and gems. Trixie now supplies the complete documented
stack, so v19 replaces that changing upstream build with Debian packages.

## Acceptance command

```sh
/sandboxed-git/turnkey/tools/test-v19-appliance rails \
    --source /home/agent/.local/worktrees/turnkey-apps/rails/wish-rails-v19-trixie
```

The assigned `bin/turnkey-v19-test` path was not present in the shared harness
checkout. `tools/test-v19-appliance` is the established v19 runner and retains
the source revision, build evidence, configured root, child result, updater
result, cleanup status and verdict.

## README crosswalk

| README contract | Focused check | Required result |
| --- | --- | --- |
| Rails sample application at `/var/www/railsapp` | Request the HTTP entry path and HTTPS through Apache, then inspect the response | Both paths reach the production app; the page identifies TurnKey Rails |
| Ruby 3.3 and Rails 7.2 come from Debian | Query commands, packages and binary ownership | Versions match the Trixie packages and `/usr/local/rbenv` is absent |
| Apache Passenger deployment | Inspect loaded modules and response headers after requesting the application | Apache loads Passenger and the application response identifies Passenger |
| MariaDB production, development and test databases | Check all database names, then write, read and delete a temporary production row through Rails as `www-data` | All three databases exist and the application roundtrip succeeds |
| First boot regenerates application credentials | Check the normal inithook result, credential files, ownership and production database access | Credential files are nonempty and protected for `root:www-data`; the regenerated database password works through Rails |
| Webmin provides the documented administration surface | Check the landing-page link, HTTPS endpoint and Webmin Apache and MariaDB modules | The link points to port 12321, HTTPS responds and both modules are installed |
| Node.js 20 and build tools support development | Query the Debian Node.js package and runtime | The installed runtime reports major version 20 |
| APT maintains the packaged stack | Refresh metadata and inspect candidates for identity-defining packages | Signed Trixie metadata is accepted, every package has a candidate and installed versions remain unchanged |
| Root Webmin and SSH credentials are inherited from Core | Cite the unchanged Core layer | Core 19 baseline passed at source `24c82ee3540ce545422742b0e28ba6b687c53ec2` |

## Updater check

`tests/v19.sh` runs `apt-get update` and checks candidates for `rails`, `ruby`,
`libapache2-mod-passenger`, `mariadb-server`, `apache2` and `nodejs`. It proves
the refresh does not mutate installed versions and that no Bookworm source
remains. The sample application runs `bundle check` against its locally
resolved lock file.

## Known limitation

Docker acceptance does not exercise the installer, kernel, bootloader or
physical hardware. Rails adds no behavior at those boundaries, so the accepted
Core 19 baseline supplies that inherited evidence.

## Deferred minor issues

None recorded before the main acceptance run.
