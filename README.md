# Popmenu Restaurantes API

An API-first Rails application for browsing restaurants, their menus, and menu items, complete with an import pipeline that ingests partner JSON feeds. The project embraces production practices: JWT-backed authentication, layered architecture, Sidekiq background jobs, comprehensive test coverage with RSpec, and contract documentation via Swagger. Seeds provide representative data so you can explore the catalog immediately.

---

## Table of Contents

- [Built With](#built-with)
- [Getting Started](#getting-started)
- [Setup](#setup)
- [Installation](#installation)
- [Usage](#usage)
- [Running Tests](#running-tests)
- [Documentation](#documentation)
- [Project Highlights](#project-highlights)
- [Future Aspects of Enhancements](#future-aspects-of-enhancements)
- [Authors](#authors)
- [Contributing](#contributing)
- [Show Your Support](#show-your-support)
- [Acknowledgments](#acknowledgments)
- [License](#license)

---

## Built With

- **Ruby on Rails** 7.2 (API mode)
- **PostgreSQL** (MySQL compatible with config changes)
- **Devise** + **devise-jwt** for stateless auth
- **Sidekiq** + Redis for background work
- **RSpec** for request/service/model specs
- **RuboCop Rails Omakase** for linting
- **YARD** for inline docs
- **Swagger (rswag)** for API documentation

---

## Getting Started

Clone the repository and configure environment variables to explore the API locally or run the test suite. The instructions below assume macOS/Linux; adjust commands for Windows if required.

### Prerequisites

- Ruby 3.2.4
- Bundler
- PostgreSQL (or MySQL if you prefer — update `config/database.yml` accordingly)
- Redis (for Sidekiq background jobs)

---

## Setup

### Clone the Repository

```bash
git clone https://github.com/basem909/popmenu-restaurantes.git
cd popmenu-restaurantes
```

### Configure the Environment

1. **Environment Variables** – copy `.env.sample` to `.env` (or export via your shell) and set values such as:
   ```env
   DEVISE_JWT_SECRET_KEY=change-me
   REDIS_URL=redis://127.0.0.1:6379/0
   ```

2. **Database Credentials** – update `config/database.yml` with your PostgreSQL (or MySQL) username/password and host information.

3. **Admin / Import Permissions** – importer endpoints require a user with the `import` permission. Seeds include suitable accounts; to promote another user, use the Rails console to adjust the `page_auth` JSON column:
   ```ruby
   user = User.find_by(email: "importer@example.com")
   user.update!(page_auth: ["import"])
   ```

---

## Installation

```bash
bundle install
bin/rails db:create db:migrate db:seed
```

Seeds populate sample restaurants, menus, menu items, and users (including an account with import permissions) so you can exercise the API immediately.

---

## Usage

### Start the API

```bash
bin/rails server
```

The application serves JSON on `http://localhost:3000`. Use the authentication endpoints to obtain a JWT and include it on protected routes:

```bash
curl -X POST http://localhost:3000/api/v1/users/sign_in \
     -H "Content-Type: application/json" \
     -d '{"user":{"email":"user@example.com","password":"Password1!"}}'
```

Copy the returned token and pass it as `Authorization: Bearer <token>` on subsequent calls.

### Background Jobs

Sidekiq handles long-running imports and notification emails. Run it alongside the server:

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

### Importing Partner JSON

The Level 3 importer accepts partner payloads (e.g., `restaurant_data.json`):

```bash
curl -X POST http://localhost:3000/api/v1/imports/restaurants \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d @restaurant_data.json
```

Successful calls enqueue `Imports::RestaurantTreeWorker`, which processes the file and emails a summary to the initiating user.

---

## Running Tests

Run the full suite (Swagger specs included):

```bash
bundle exec rspec
```

Common subsets:

```bash
bundle exec rspec spec/models
bundle exec rspec spec/services
bundle exec rspec spec/requests --exclude-pattern "spec/requests/swagger/**/*_spec.rb"
```

Static analysis & docs:

```bash
bundle exec rubocop
bundle exec yard doc
```

---

## Documentation

- **Swagger** – generate/update the OpenAPI definition:
  ```bash
  bundle exec rake rswag:specs:swaggerize
  ```
  Visit `/api-docs` while the server is running for the interactive UI.

- **YARD** – regenerate developer documentation:
  ```bash
  bundle exec yard doc
  open doc/index.html
  ```


---

## Project Highlights

- **Spree-inspired layering** – base resource controller + serializer registry keep endpoints lean and extensible.
- **Importer instrumentation** – notifications, structured logging, and summary emails make bulk imports observable.
- **Comprehensive test suite** – model, service, and request specs cover critical behaviours; Swagger specs keep contracts honest.
- **Production-ready defaults** – UUID primary keys, JWT auth, Sidekiq for background work, seeds for easy demos.

---

## Future Aspects of Enhancements

- Extend the importer to support delta updates (marking menu items inactive when dropped from partner feeds).
- Introduce caching + ETag support on read endpoints to reduce payload transfer for large menu catalogs.
- Add rate limiting / throttling for the import endpoint to guard against runaway partner integrations.
- Integrate webhooks so partners get notified after successful imports.
- Improve auditability with per-item change logs and diffable history for menu items.

---

## Authors

👤 **Bassem Shams**

- GitHub: [@basem909](https://github.com/basem909)
- Twitter: [@ShamsBassem](https://twitter.com/ShamsBassem)
- LinkedIn: [Bassem Abdelrahman](https://www.linkedin.com/in/bassem-abdelrahman)

---

## Contributing

Bug reports, feature ideas, and pull requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m "Add amazing feature"`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See the [issues page](https://github.com/yourusername/popmenu-restaurantes/issues) for open discussions.

---

## Show Your Support

If this project helps you, give it a ⭐️ or share it with a friend.

---

## Acknowledgments

- Thanks to the Rails and open-source communities for their tooling and inspiration.
- Architecture patterns draw on lessons learned from production restaurant/menu platforms.

---

## License

This project is [MIT](./MIT.md) licensed.

---
