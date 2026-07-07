# Legacy Realm Fixture

Place a copied legacy `default.realm` file here to run the external import test:

`OrbitTests/Fixtures/LegacyRealm/default.realm`

Realm files can contain personal diary data, so `*.realm` files in this folder are intentionally ignored by git.

You can also keep the file outside the repository and pass its path through the test environment:

`DOTNOTE_LEGACY_REALM_FILE=/absolute/path/to/default.realm`
