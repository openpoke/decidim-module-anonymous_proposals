# Decidim::AnonymousProposals

Transform proposals component to allow not signed in users creation of
proposals. For this the proposals created anonymously will be linked with
a special anonymous users. There is a task to create/update anonymous
users in organizations explained in Installation section.

The creation of anonymous proposals can be disabled for each proposals
component individually. Once you have installed this module and added an
anonymous user, anonymous proposals will be enabled by default on all
proposal components.

## Installation

Add this line to your application's Gemfile:

For Decidim 0.31:
```ruby
gem "decidim-anonymous_proposals", git: "https://github.com/PopulateTools/decidim-module-anonymous_proposals", branch: "release/0.31-stable"
```

For Decidim 0.30:
```ruby
gem "decidim-anonymous_proposals", git: "https://github.com/PopulateTools/decidim-module-anonymous_proposals", branch: "release/0.30-stable"
```

For Decidim 0.29:
```ruby
gem "decidim-anonymous_proposals", git: "https://github.com/PopulateTools/decidim-module-anonymous_proposals", branch: "release/0.29-stable"
```

For Decidim 0.28:
```ruby
gem "decidim-anonymous_proposals", git: "https://github.com/PopulateTools/decidim-module-anonymous_proposals", branch: "release/0.28-stable"
```

For Decidim 0.27:
```ruby
gem "decidim-anonymous_proposals", git: "https://github.com/PopulateTools/decidim-module-anonymous_proposals", branch: "release/0.27-stable"
```

For Decidim 0.26:
```ruby
gem "decidim-anonymous_proposals", git: "https://github.com/PopulateTools/decidim-module-anonymous_proposals", branch: "release/0.26-stable"
```

For Decidim 0.25:
```ruby
gem "decidim-anonymous_proposals", git: "https://github.com/PopulateTools/decidim-module-anonymous_proposals", branch: "release/0.25-stable"
```

For Decidim 0.24:
```ruby
gem "decidim-anonymous_proposals", git: "https://github.com/PopulateTools/decidim-module-anonymous_proposals", branch: "release/0.24-stable"
```

And then execute:

```bash
bundle
```

To have the functionality available there must be at least one anonymous user.
An anonymous user is a user with `{ anonymous: true }` present in the
`extended_data` attribute. There is a task to create automatically or update the
first anonymous user of organizations (or a specific organization if its id is
provided).

The task accepts the following arguments:

1. Name of the user (default: "Anonymous")
2. Nickname of the user (default: "anonymous")
3. Email of the user (default: "anonymous@example.org")
4. organization_id. This argument is optional, if not provided a user is generated
   with the previous configurations for each organization

Example of use:

```bash
rake decidim_anonymous_proposals:generate_anonymous_user["Aportaciones anónimas",anonima,anonymous@example.org]
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
