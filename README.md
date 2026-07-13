````markdown
# R2

R2 is a simple command-line interface (CLI) for interacting with [Cloudflare R2](https://developers.cloudflare.com/r2/) through the S3-compatible API.

> This is a personal side project, not an officially maintained product.
> It may contain bugs, breaking changes, or incomplete features. Use at your
> own risk, especially in production environments.

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
````

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

```text
[R2] upload -> ./report.pdf
```

#### Options

| Option      | Alias | Default   | Description                                        |
| ----------- | ----- | --------- | -------------------------------------------------- |
| `--bucket`  | `-b`  | `main`    | Target R2 bucket name                              |
| `--key`     | `-k`  | file name | Full destination object key (overrides `--prefix`) |
| `--prefix`  | `-p`  | —         | Key prefix ("folder") prepended to the file name   |
| `--verbose` | `-v`  | `false`   | Enable verbose (INFO-level) logging                |

The file is streamed to R2 (not buffered in memory) and its `Content-Type` is
detected from the file name.

**Example with custom bucket:**

```bash
r2 upload ./report.pdf --bucket my-bucket
```

**Example storing under a folder (`photos/report.pdf`):**

```bash
r2 upload ./report.pdf --prefix photos
```

**Example with an explicit key:**

```bash
r2 upload ./report.pdf --key reports/2024/report.pdf
```

**Example with verbose logging:**

```bash
r2 upload ./report.pdf --verbose
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
rake test:all
rake test:unit
rake test:e2e
```

* `test:unit` runs isolated tests for individual components.
* `test:e2e` runs end-to-end tests through the CLI binary.

Integration and e2e tests require a valid `.env` file since they interact with
a real R2 bucket.

### Debug helpers

Rake tasks for generating and cleaning local debug files. Generated files are
stored in `tmp/debug` (gitignored).

Generated debug files use the following naming format:

```text
YYYYMMDD_HHMMSS_SIZEmb.bin
```

Example:

```text
20260713_190000_10mb.bin
```

Generate a debug file:

```bash
rake debug:seed
```

Example output:

```text
[debug] seeded tmp/debug/20260713_190000_10mb.bin (10 MiB)
```

Remove generated debug files:

```bash
rake debug:clean
```

The default generated file size is `10 MiB`. The output directory can be
overridden with the `R2_DEBUG_DIR` environment variable.

Example:

```bash
R2_DEBUG_DIR=tmp/samples rake debug:seed
```

Generated debug files can be used for manual testing:

```bash
r2 upload tmp/debug/20260713_190000_10mb.bin
```

### Lint

The project uses [RuboCop](https://github.com/rubocop/rubocop) for style enforcement:

```bash
bundle exec rubocop
```

## License

This project is licensed under the [MIT License](LICENSE).