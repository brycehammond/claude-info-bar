# claude-info-bar

A Claude Code status line extension that displays the active model, working directory, and context window usage at a glance.

```
Opus 4.6 │ Dev/my-project │ main │ ███░░░░░░░ 32% (22.4k tokens)
```

## What it shows

- **Model** — the current model's display name (e.g. Opus 4.6, Sonnet 4.6)
- **Directory** — the last two components of your working directory
- **Git branch** — the current branch name (hidden outside git repos)
- **Context usage** — a progress bar with percentage and token count, color-coded:
  - Green: < 50%
  - Yellow: 50–79%
  - Red: 80%+

The status line updates automatically after each assistant response.

## Requirements

- [jq](https://jqlang.github.io/jq/) must be installed (`brew install jq`)

## Installation

1. Clone this repo:

   ```sh
   git clone https://github.com/anthropics/claude-info-bar.git ~/.claude-info-bar
   ```

2. Make the script executable (it should already be):

   ```sh
   chmod +x ~/.claude-info-bar/statusline.sh
   ```

3. Add to your Claude Code settings (`~/.claude/settings.json`):

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.claude-info-bar/statusline.sh",
       "padding": 1
     }
   }
   ```

4. Restart Claude Code or start a new session.

## Testing

You can test the script locally with mock data:

```sh
echo '{
  "model": {"display_name": "Opus 4.6"},
  "workspace": {"current_dir": "/Users/you/Dev/my-project"},
  "context_window": {
    "used_percentage": 42,
    "current_usage": {
      "input_tokens": 5000,
      "cache_creation_input_tokens": 10000,
      "cache_read_input_tokens": 27000
    }
  }
}' | ./statusline.sh
```

## Customization

The script is a single bash file — edit `statusline.sh` to adjust colors, progress bar width, directory truncation, or add additional fields. Claude Code passes a JSON object via stdin with fields including `model`, `workspace`, `context_window`, `cost`, `session_id`, `version`, and more.

## License

MIT
