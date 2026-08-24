#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
webroot=/var/www/railsapp
response=/tmp/tkl-rails-response.$$
headers=/tmp/tkl-rails-headers.$$
database_probe=/tmp/tkl-rails-database.$$.rb
database_result=/tmp/tkl-rails-database.$$.txt
policy=/tmp/tkl-rails-policy.$$

cleanup() {
    rm -f -- "$response" "$headers" "$database_probe" \
        "$database_result" "$policy"
}
trap cleanup EXIT

systemctl --quiet is-active apache2.service mariadb.service multi-user.target
systemctl --quiet is-enabled apache2.service mariadb.service

rails_package=$(dpkg-query -W -f='${Version}' rails)
ruby_package=$(dpkg-query -W -f='${Version}' ruby)
passenger_package=$(dpkg-query -W -f='${Version}' libapache2-mod-passenger)
mariadb_package=$(dpkg-query -W -f='${Version}' mariadb-server)
apache_package=$(dpkg-query -W -f='${Version}' apache2)
node_package=$(dpkg-query -W -f='${Version}' nodejs)

ruby_version=$(ruby --version)
rails_version=$(rails --version)
passenger_version=$(passenger-config --version)
node_version=$(node --version)
grep -q '^ruby 3\.3\.' <<<"$ruby_version"
grep -Fxq 'Rails 7.2.2.2' <<<"$rails_version"
grep -q '^Phusion Passenger(R) 6\.0\.' <<<"$passenger_version"
grep -q '^v20\.' <<<"$node_version"

dpkg-query -S /usr/bin/ruby /usr/bin/rails /usr/lib/apache2/modules/mod_passenger.so \
    >/dev/null
test -s "$webroot/Gemfile.lock"
grep -q '^    rails (7\.2\.2\.2)' "$webroot/Gemfile.lock"
grep -q '^    mysql2 (0\.5\.' "$webroot/Gemfile.lock"
! test -e /usr/local/rbenv
(cd "$webroot" && bundle check)

apache2ctl -M 2>/dev/null | grep -q ' passenger_module '
curl --silent --show-error --output /dev/null \
    --write-out '%{http_code}' http://127.0.0.1/ | grep -Fxq 301
curl --insecure --fail --silent --show-error https://127.0.0.1/ >"$response"
grep -q 'TurnKey Rails' "$response"
grep -q 'https://127.0.0.1:12321' "$response"
curl --insecure --fail --silent --show-error \
    https://127.0.0.1/tkl-webcp.css >/dev/null
curl --insecure --fail --silent --show-error --head \
    https://127.0.0.1/ >"$headers"
grep -Fqi 'X-Powered-By: Phusion Passenger' "$headers"
passenger-status >"$response"
grep -q '/var/www/railsapp (production)' "$response"
grep -Eq 'Processes[[:space:]]*:[[:space:]]*[1-9]' "$response"

dpkg-query -W webmin-apache webmin-mysql >/dev/null
curl --insecure --fail --silent --show-error --head \
    https://127.0.0.1:12321/ >/dev/null

for database in railsapp_production railsapp_development railsapp_test; do
    mariadb --batch --skip-column-names --execute \
        "SHOW DATABASES LIKE '$database'" | grep -Fxq "$database"
done

cat >"$database_probe" <<'RUBY'
connection = ActiveRecord::Base.connection
table = :turnkey_v19_acceptance
connection.drop_table(table) if connection.table_exists?(table)
begin
  connection.create_table(table) { |definition| definition.string :value }
  connection.execute(
    "INSERT INTO turnkey_v19_acceptance (value) VALUES " \
    "(CHAR(100,97,116,97,98,97,115,101,45,111,107))"
  )
  value = connection.select_value(
    "SELECT value FROM turnkey_v19_acceptance LIMIT 1"
  )
  abort "database readback differed" unless value == "database-ok"
  puts "database_roundtrip=ok"
ensure
  connection.drop_table(table) if connection.table_exists?(table)
end
RUBY
chmod 0644 "$database_probe"
runuser --user www-data -- env RAILS_ENV=production \
    "$webroot/bin/rails" runner "$database_probe" >"$database_result"
grep -Fxq 'database_roundtrip=ok' "$database_result"

test -s "$webroot/config/master.key"
test -s "$webroot/config/credentials.yml.enc"
stat -c '%U:%G %a' "$webroot/config/master.key" | grep -Fxq 'root:www-data 640'

before="$rails_package|$ruby_package|$passenger_package|$mariadb_package|$apache_package|$node_package"
apt-get update >/dev/null
for package in rails ruby libapache2-mod-passenger mariadb-server apache2 nodejs; do
    apt-cache policy "$package" >"$policy"
    candidate=$(awk '/Candidate:/ {print $2}' "$policy")
    test -n "$candidate"
    test "$candidate" != '(none)'
    grep -Eq 'trixie|deb13' "$policy"
done
after="$(dpkg-query -W -f='${Version}' rails)|$(dpkg-query -W -f='${Version}' ruby)|$(dpkg-query -W -f='${Version}' libapache2-mod-passenger)|$(dpkg-query -W -f='${Version}' mariadb-server)|$(dpkg-query -W -f='${Version}' apache2)|$(dpkg-query -W -f='${Version}' nodejs)"
test "$after" = "$before"
grep -Rqs '^Suites: trixie' /etc/apt/sources.list.d
! grep -Rqi bookworm /etc/apt/sources.list.d

cat >"$result" <<EOF
package_source=Debian 13 Trixie APT repositories for Ruby, Rails, Passenger, MariaDB, Apache and Node.js; TurnKey APT for Webmin modules
installed_version=rails $rails_package ($rails_version); ruby $ruby_package ($ruby_version); passenger $passenger_package; mariadb-server $mariadb_package; apache2 $apache_package; nodejs $node_package ($node_version)
runtime_checks=normal init; Apache and MariaDB service supervision; Rails production app through HTTPS Passenger; HTTP redirect; Webmin link and endpoint; production database write/read/delete roundtrip; development and test databases; regenerated Rails credentials
updater_command=apt-get update; apt-cache policy rails ruby libapache2-mod-passenger mariadb-server apache2 nodejs
updater_result=signed metadata refreshed; eligible Trixie candidates found; installed versions unchanged
updater_channel=Debian Trixie and TurnKey Trixie APT repositories
integrity_evidence=APT accepted signed repository metadata through configured Deb822 sources and keyrings; the sample Bundler lock resolves locally from Debian-installed gems; no Bookworm source remained
EOF
