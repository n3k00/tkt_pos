Data layer structure for the Home feature (feature-first, clean-ish):

folders:
- datasources/local: Local sources (cache, storage, sqlite, shared_prefs)
- datasources/remote: Remote sources (REST, GraphQL, gRPC)
- models: Data models used by datasources/repositories
- repositories: Repository implementations that coordinate datasources
- mappers (optional): Mapping between models and domain entities

Notes:
- Keep platform- or service-specific code inside the appropriate datasource folder.
- Repositories should only depend on datasources and models, not on presentation widgets.
- Add unit tests next to implementations when you start adding logic.

