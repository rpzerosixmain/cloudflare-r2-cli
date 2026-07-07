# R2

R2 is a simple command-line interface (CLI) for interacting with [Cloudflare R2](https://developers.cloudflare.com/r2/) through the S3-compatible API.

## Features

* Upload files to an R2 bucket

> New operations (download, delete, list) are planned for future releases.

## Requirements

* Ruby >= 3.2
* A Cloudflare account with an R2 bucket created
* S3-compatible access credentials (Access Key ID and Secret Access Key)

## Installation

Add it to your `Gemfile`:

```ruby
gem 'r2'
```

Then run:

```bash
bundle install
```

Or install it directly:

```bash
gem install r2
```

## Configuration

The R2 CLI reads credentials from environment variables. Create a `.env` file in your project root (based on `.env.example`, if available) with:

```bash
R2_ACCESS_KEY_ID=your_access_key_id
R2_SECRET_ACCESS_KEY=your_secret_access_key
R2_ENDPOINT=https://<account_id>.r2.cloudflarestorage.com
R2_REGION=auto
```

| Variable               | Required | Default | Description                    |
| ---------------------- | :------: | :-----: | ------------------------------ |
| `R2_ACCESS_KEY_ID`     |    Yes   |    —    | R2 API Access Key ID           |
| `R2_SECRET_ACCESS_KEY` |    Yes   |    —    | R2 API Secret Access Key       |
| `R2_ENDPOINT`          |    Yes   |    —    | S3 endpoint for your R2 bucket |
| `R2_REGION`            |    No    |  `auto` | Region used in requests        |

## Usage

### Upload

Uploads a local file to the configured bucket.

```bash
r2 upload PATH
```

**Example:**

```bash
r2 upload ./report.pdf
```

Expected output:

```
[R2] upload -> ./report.pdf
```

#### Options

| Option     | Alias | Default | Description           |
| ---------- | ----- | ------- | --------------------- |
| `--bucket` | `-b`  | `main`  | Target R2 bucket name |

**Example with custom bucket:**

```bash
r2 upload ./report.pdf --bucket my-bucket
```

## Development

After cloning the repository, install dependencies:

```bash
bundle install
```

### Interactive console

```bash
bin/console
```

### Tests

The project has three test levels:

```bash
rake test:all          # runs full test suite
rake test:unit         # unit tests
rake test:e2e          # end-to-end tests via CLI binary
```

Integration and e2e tests require a valid `.env` file since they interact with a real R2 bucket.

### Debug helpers

Rake tasks for quick manual debugging. Sample files are written to `tmp/debug`
(gitignored) in the supported sizes: `1mb`, `5mb`, `10mb`.

```bash
rake debug:files          # generate all sample files (1mb, 5mb, 10mb)
rake "debug:file[10mb]"   # generate a single sample file
rake "debug:upload[10mb]" # generate a file and upload it via the CLI
rake debug:clean          # remove generated debug files
```

`debug:upload` runs the real CLI, so it requires a valid `.env`. The output
directory can be overridden with the `R2_DEBUG_DIR` environment variable.

### Lint

The project uses [RuboCop](https://github.com/rubocop/rubocop) for style enforcement:

```bash
bundle exec rubocop
```

## License

This project is licensed under the [MIT License](LICENSE).