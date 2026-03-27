# Docker Container for Org‑MCP Server

A ready‑to‑run Docker container for the [org‑mcp](https://github.com/laurynas-biveinis/org-mcp) Emacs package, which implements a Model Context Protocol (MCP) server for Org‑mode files.

This image provides configurable directory scanning and file filtering for the upstream org‑mcp server, making it easy to deploy without manual Emacs setup.

## Features

- **Zero‑configuration Emacs environment** – includes Emacs, org‑mcp, and all dependencies
- **Configurable scanning** – specify directories via the `ORG_FILES_DIRS` environment variable
- **Flexible filtering** – exclude files using an Emacs‑style regex via `ORG_FILE_IGNORE`
- **Ready for MCP clients** – exposes the filtered Org files to Claude Desktop, Cursor, etc.
- **Based on [org‑mcp](https://github.com/laurynas-biveinis/org-mcp)** – uses the upstream server implementation

## Quick Start

### 1. Build the Docker image

```bash
docker build -t org-mcp-server .
```

### 2. Run the container

```bash
docker run -d \
  -p 3000:3000 \
  -v /path/to/your/org/files:/home/user/org \
  -e ORG_FILES_DIRS=/home/user/org \
  -e ORG_FILE_IGNORE='README\|archive' \
  --name org-mcp \
  org-mcp-server
```

### 3. Test the connection

```bash
echo '{"jsonrpc":"2.0","method":"tools/call", "params": {"name": "org-get-allowed-files", "arguments": {}}, "id":"req128"}' \
  | nc -N localhost 3000 \
  | jq .
```

## Configuration

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `ORG_FILES_DIRS` | Colon‑separated directories to scan for `.org` files | `/home/user/org:/home/user/notes` |
| `ORG_FILE_IGNORE` | Emacs‑style regex of file paths to **exclude** | `'README\|archive\|private'` |

### Examples

#### Scan two directories

```bash
ORG_FILES_DIRS=/home/user/work:/home/user/personal
```

#### Ignore multiple patterns

The regex uses Emacs syntax. To ignore files containing `README`, `archive`, or `draft`:

```bash
ORG_FILE_IGNORE='README\|archive\|draft'
```

#### Ignore whole subdirectories

To skip an entire subdirectory `private/`:

```bash
ORG_FILE_IGNORE='private/'
```

#### More complex pattern

Ignore files that are either in `tmp/` or end with `_backup.org`:

```bash
ORG_FILE_IGNORE='tmp/\|_backup\.org$'
```

## How It Works

This container runs the official [org‑mcp](https://github.com/laurynas-biveinis/org-mcp) Emacs package inside a pre‑configured environment:

1. At startup, it reads `ORG_FILES_DIRS` and collects all `.org` files recursively from each listed directory.
2. If `ORG_FILE_IGNORE` is set, any file whose full path matches the regex is removed from the list.
3. The remaining files are exposed via the MCP tool `org-get-allowed-files`.
4. Other MCP tools (e.g., `org-open-file`, `org-search-headings`) operate only on this allowed set.

All MCP functionality is provided by the upstream org‑mcp package; this container merely packages it with sensible defaults and environment‑based configuration.

## Notes

- If `ORG_FILES_DIRS` is not set, **no files** will be exposed.
- If `ORG_FILE_IGNORE` is not set, **all** found `.org` files are allowed.
- The regex follows Emacs’s `string-match-p` syntax. Use `\|` for alternation, `\.` for a literal dot, `$` for end‑of‑string.
- The container must have the directories mounted at the same paths specified in `ORG_FILES_DIRS`.

## Relationship to Upstream

This Docker image is **not** a standalone MCP server. It is a containerized wrapper around the [org‑mcp](https://github.com/laurynas-biveinis/org-mcp) Emacs package, which does the actual MCP work. The image adds:

- Automatic installation of Emacs and required packages
- Environment‑variable based configuration
- A pre‑configured entrypoint that starts the server
- Easy volume mounting for your Org files

If you need to modify MCP behavior or add new tools, please refer to the [org‑mcp repository](https://github.com/laurynas-biveinis/org-mcp).

## License

MIT – same as the upstream org‑mcp package.
