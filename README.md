# Org MCP Server

A Model Context Protocol (MCP) server for Emacs Org‑mode files, with configurable directory scanning and file filtering.

## Features

- Scan multiple directories for `.org` files via the `ORG_FILES_DIRS` environment variable
- Filter out unwanted files using an Emacs‑style regex via `ORG_FILE_IGNORE`
- Expose the filtered list of Org files to MCP clients (e.g., Claude Desktop, Cursor)

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

1. The server reads `ORG_FILES_DIRS` and collects all `.org` files recursively from each listed directory.
2. If `ORG_FILE_IGNORE` is set, any file whose full path matches the regex is removed from the list.
3. The remaining files are exposed via the MCP tool `org-get-allowed-files`.
4. Other MCP tools (e.g., `org-open-file`, `org-search-headings`) operate only on this allowed set.

## Notes

- If `ORG_FILES_DIRS` is not set, **no files** will be exposed.
- If `ORG_FILE_IGNORE` is not set, **all** found `.org` files are allowed.
- The regex follows Emacs’s `string-match-p` syntax. Use `\|` for alternation, `\.` for a literal dot, `$` for end‑of‑string.
- The container must have the directories mounted at the same paths specified in `ORG_FILES_DIRS`.

## License

MIT
