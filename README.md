# Claude Code Multi-Agent Development

<img width="3234" height="1904" alt="image_2025-10-27_15-05-35" src="https://github.com/user-attachments/assets/fbd8419e-8632-47d8-a0e5-143b2a7602c5" />

Run Claude Code on different AI models (Grok, Gemini, GPT or any from 500+ on OpenRouter) in parallel. Each Claude Code instance creates a separate branch from your current one, and runs in a different Docker container. 

You can also use this tool to set up Claude Code with any free model available via OpenRouter's API, and use Claude Code for free!

## Why Multi-Agent?

Get multiple models to work on the same problem, so you can merge the one with the best results. It's like being a game master for a battle royale, where each model is a contestant and you pick the winner.

I found tooling like Claude Code Router or Claude Code Proxy to be either missing parallel execution w/ containers.

**How it works:**

- Choose any 4 models from OpenRouter's 500+ options
- Run 4 models in parallel (you pick which 4)
- Each runs Claude Code in a separate docker container
- Each works on a separate git branch via worktrees
- Watch them all in tmux 2x2 grid
- Compare implementations with `mad compare`
- Merge the best one with `mad merge <model>`

*currently only macOS supported (sorry windows guys) / porting to linux is trivial

## Setup

```bash
# install docker desktop from docker.com/products/docker-desktop
# then install dependencies:
brew install bash tmux

git clone https://github.com/YOUR_USERNAME/mad.git
cd mad

cp .env.example .env
# edit .env: add your api keys

# edit docker/litellm/config.yaml: choose your 4 models from openrouter.ai/models

docker-compose build

echo 'export PATH="$PATH:'$(pwd)'/scripts"' >> ~/.zshrc
source ~/.zshrc
```

## Usage

```bash
cd ~/your-project
mad
```
```bash
mad compare      # see what each model built
mad merge gemini # merge the best one
mad cleanup      # remove branches/worktrees
```

## Workflow

```bash
cd ~/my-project
mad

# tmux opens with 4 panes
# give same task to all models
# let them work in parallel

# detach: ctrl+b then d
# reattach: tmux attach -t mad-<session-name>

mad compare
git checkout main
mad merge gpt5
mad cleanup
```

## Commands

| command             | what it does                      |
| ------------------- | --------------------------------- |
| `mad`               | start new session                 |
| `mad compare`       | compare all implementations       |
| `mad merge <model>` | merge specific model's branch     |
| `mad cleanup`       | remove all worktrees and branches |
| `mad stop`          | stop containers and tmux          |

## Changing models

edit `docker/litellm/config.yaml`:

```yaml
model_list:
  - model_name: gemini # change this to the model you want to use
    litellm_params:
      model: openrouter/google/gemini-2.5-pro # and this one, based on the link you got from openrouter.ai/models
      api_key: os.environ/OPENROUTER_API_KEY
      api_base: https://openrouter.ai/api/v1
      supports_vision: true
```

browse models at openrouter.ai/models

rebuild:

```bash
docker-compose build
docker-compose up -d
```

## Troubleshooting

**containers won't start:** `docker-compose ps` and `docker-compose logs litellm`. rebuild with `docker-compose down && docker-compose build --no-cache && docker-compose up -d`.

**auth errors:** verify keys in `.env` start with `sk-or-v1-` (openrouter) and `sk-ant-api03-` (anthropic). no special characters in comments.

**worktrees:** `git worktree list` to see all, `git worktree prune` to clean.

**disk space:** `./scripts/docker-cleanup` to remove old containers/images.

## Future ideas
- Auto pick the model from the list of OpenRouter models
- MCP/API/headless project management system to let agents collaborate despite separated branches
- Launch more than 4 models at the same time (I am not sure how needed this is with Claude Code's subagents)
